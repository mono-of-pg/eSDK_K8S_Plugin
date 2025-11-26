# eg: docker build --target huawei-csi-driver --platform linux/amd64 --build-arg VERSION=${VER} -f Dockerfile -t huawei-csi:${VER} .
ARG VERSION
ARG REGISTRY=""

# Base image for building binaries
FROM golang:1.24.1 AS builder

WORKDIR /workspace
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build all binaries
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o huawei-csi -ldflags="-s -w -X 'github.com/Huawei/eSDK_K8S_Plugin/v4/pkg/constants.CSIVersion=${VERSION}'" ./csi
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o storage-backend-controller -ldflags="-s -w -X 'github.com/Huawei/eSDK_K8S_Plugin/v4/pkg/constants.CSIVersion=${VERSION}'" ./cmd/storage-backend-controller
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o storage-backend-sidecar -ldflags="-s -w -X 'github.com/Huawei/eSDK_K8S_Plugin/v4/pkg/constants.CSIVersion=${VERSION}'" ./cmd/storage-backend-sidecar
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o huawei-csi-extender -ldflags="-s -w -X 'github.com/Huawei/eSDK_K8S_Plugin/v4/pkg/constants.CSIVersion=${VERSION}'" ./cmd/huawei-csi-extender

# Final stage for huawei-csi-driver
FROM busybox:stable-glibc as huawei-csi-driver

LABEL version="${VERSION}"
LABEL maintainers="Huawei eSDK CSI development team"
LABEL description="Kubernetes CSI Driver for Huawei Storage: $VERSION"

# Copy the binary from builder stage
COPY --from=builder /workspace/huawei-csi huawei-csi
ENTRYPOINT ["/huawei-csi"]


# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/base:latest as storage-backend-controller
LABEL version="${VERSION}"
LABEL maintainers="Huawei eSDK CSI development team"
LABEL description="Storage Backend Controller"

# Copy the binary from builder stage
COPY --from=builder /workspace/storage-backend-controller storage-backend-controller
ENTRYPOINT ["/storage-backend-controller"]


FROM gcr.io/distroless/base:latest as storage-backend-sidecar
LABEL version="${VERSION}"
LABEL maintainers="Huawei eSDK CSI development team"
LABEL description="Storage Backend Sidecar"

# Copy the binary from builder stage
COPY --from=builder /workspace/storage-backend-sidecar storage-backend-sidecar
ENTRYPOINT ["/storage-backend-sidecar"]


FROM gcr.io/distroless/base:latest as huawei-csi-extender
LABEL version="${VERSION}"
LABEL maintainers="Huawei eSDK CSI development team"
LABEL description="Huawei CSI Extender"

# Copy the binary from builder stage
COPY --from=builder /workspace/huawei-csi-extender huawei-csi-extender
ENTRYPOINT ["/huawei-csi-extender"]
