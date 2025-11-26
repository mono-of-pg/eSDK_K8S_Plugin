# GitHub Container Registry Integration

This document describes how to build and push container images to the GitHub Container Registry (GHCR) and use them with the Helm chart.

## Prerequisites

- Docker installed
- Helm 3+ installed
- GitHub account with appropriate permissions
- Make installed

## Building Images

### Using Default Settings

```bash
make build-images
```

This will build images with the default registry (`ghcr.io/$(USER)/esdk-k8s-plugin`) and tag them with the version from the Makefile.

### Using Custom Registry

```bash
make IMG_REGISTRY=myregistry.com/myorg build-images
```

This will build images with your custom registry prefix.

### Building Specific Images

You can also build individual images:

```bash
# Build just the Huawei CSI driver
docker build --target huawei-csi-driver --platform linux/amd64 --build-arg VERSION=$(VER) --build-arg REGISTRY=$(IMG_REGISTRY) -f Dockerfile -t $(IMG_REGISTRY)/huawei-csi:$(IMG_TAG) .

# Build just the storage backend controller
docker build --target storage-backend-controller --platform linux/amd64 --build-arg VERSION=$(VER) --build-arg REGISTRY=$(IMG_REGISTRY) -f Dockerfile -t $(IMG_REGISTRY)/storage-backend-controller:$(IMG_TAG) .
```

## Pushing Images

### Pushing to Default Registry

```bash
make push-images
```

### Pushing to Custom Registry

```bash
make IMG_REGISTRY=myregistry.com/myorg push-images
```

### Pushing All Images

```bash
make build-push-images
```

## Using Images with Helm Chart

### Deploy with Default Images

```bash
helm install esdk ./helm/esdk
```

### Deploy with Custom Registry Images

```bash
helm install esdk ./helm/esdk \
  --set images.registry=myregistry.com/myorg \
  --set-string images.huaweiCSIService=myregistry.com/myorg/huawei-csi:latest \
  --set-string images.storageBackendController=myregistry.com/myorg/storage-backend-controller:latest \
  --set-string images.storageBackendSidecar=myregistry.com/myorg/storage-backend-sidecar:latest \
  --set-string images.huaweiCSIExtender=myregistry.com/myorg/huawei-csi-extender:latest
```

### Deploy with Only Registry Prefix

If you only want to change the registry prefix for all images:

```bash
helm install esdk ./helm/esdk \
  --set images.registry=myregistry.com/myorg
```

This will automatically prefix all Huawei images with `myregistry.com/myorg/`.

## GitHub Actions Integration

Container images are automatically built and pushed to GHCR via GitHub Actions when:

1. A push occurs to the `main` branch
2. A tag is created (following the `v*` pattern)

The workflow is defined in `.github/workflows/container-images.yml`.

## Dockerfile Configuration

The Dockerfile supports a `REGISTRY` build argument:

```bash
docker build --target huawei-csi-driver --build-arg VERSION=1.0.0 --build-arg REGISTRY=ghcr.io/myorg/myproject -f Dockerfile -t myregistry.com/myproject/huawei-csi:1.0.0 .
```

When `REGISTRY` is not specified, images are built with default names (e.g., `huawei-csi:1.0.0`).

## Security Considerations

1. Ensure that your GitHub token has appropriate permissions to push to the container registry
2. For production deployments, always pin to specific image tags rather than using `latest`
3. Use image pull secrets for private registries:

```yaml
imagePullSecrets:
  - name: my-registry-secret
```

## Troubleshooting

### Authentication Issues

If you encounter authentication issues when pushing to GHCR:

```bash
# Login to GHCR manually
docker login ghcr.io
```

### Image Not Found

Ensure that the image tags match exactly. When using custom registries, make sure the full image names are correct in your Helm values.

### Build Failures

Verify that your Dockerfile build arguments are properly set and that all required binaries are built before attempting to create images.
