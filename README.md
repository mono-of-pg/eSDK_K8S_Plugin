# CSI Driver for Huawei Storage

![GitHub](https://img.shields.io/github/license/Huawei/eSDK_K8S_Plugin)
[![Go Report Card](https://goreportcard.com/badge/github.com/huawei/esdk_k8s_plugin)](https://goreportcard.com/report/github.com/huawei/esdk_k8s_plugin)
![GitHub go.mod Go version (subdirectory of monorepo)](https://img.shields.io/github/go-mod/go-version/Huawei/eSDK_K8S_Plugin)
![GitHub Release Date](https://img.shields.io/github/release-date/Huawei/eSDK_K8S_Plugin)
![GitHub release (latest by date)](https://img.shields.io/github/downloads/Huawei/eSDK_K8S_Plugin/latest/total)
## Description

Container Storage Interface (CSI) is an industry standard used to expose block and file storage systems to container workloads on container orchestration systems (COs) such as Kubernetes, RedHat OpenShift, etc.

Huawei CSI plug-in is used to communicate with Huawei enterprise storage and distributed storage products and provide storage services for Kubernetes container workloads. It is a mandatory plug-in used by Huawei enterprise storage and distributed storage in the Kubernetes environment.

## Container Images

Container images are now built and pushed to the GitHub Container Registry (GHCR) automatically via GitHub Actions. 

### Creating New Versions with Tags

To create a new version with a tag:

1. **Tag your commit** with a semantic version (following the v* pattern):
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```

2. **GitHub Actions** will automatically:
   - Build all container images
   - Tag them with the version (e.g., `v1.2.3`)
   - Push to GHCR with proper naming:
     - `ghcr.io/mono-of-pg/esdk-k8s-plugin/huawei-csi:v1.2.3`
     - `ghcr.io/mono-of-pg/esdk-k8s-plugin/storage-backend-controller:v1.2.3`
     - `ghcr.io/mono-of-pg/esdk-k8s-plugin/storage-backend-sidecar:v1.2.3`
     - `ghcr.io/mono-of-pg/esdk-k8s-plugin/huawei-csi-extender:v1.2.3`

To use custom images in your deployments:
1. Build images with your preferred registry:
   ```bash
   make IMG_REGISTRY=myregistry.com/myorg build-images
   ```

2. Push images to your registry:
   ```bash
   make IMG_REGISTRY=myregistry.com/myorg push-images
   ```

3. Deploy using Helm with custom image registry:
   ```bash
   helm install esdk ./helm/esdk \
     --set images.registry=myregistry.com/myorg \
     --set-string images.huaweiCSIService=myregistry.com/myorg/huawei-csi:v1.2.3 \
     --set-string images.storageBackendController=myregistry.com/myorg/storage-backend-controller:v1.2.3 \
     --set-string images.storageBackendSidecar=myregistry.com/myorg/storage-backend-sidecar:v1.2.3 \
     --set-string images.huaweiCSIExtender=myregistry.com/myorg/huawei-csi-extender:v1.2.3
   ```

For development purposes, you can also build and push images manually:
```bash
# Build images with custom registry
make IMG_REGISTRY=myregistry.com/myorg build-images

# Push images to registry
make IMG_REGISTRY=myregistry.com/myorg push-images
```

The project also provides a build script that creates binaries and images in the standard packaging format:
```bash
# Build with standard packaging
./build.sh v1.2.3 X86
```

## Documentation

You can click [Release](https://github.com/Huawei/eSDK_K8S_Plugin/releases) to obtain the released Huawei CSI package.

For details, see the user guide in the docs directory.
