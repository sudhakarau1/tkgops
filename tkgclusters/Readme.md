## Creating TKG clusters with Kustomize
### Make sure to set the right SC context
` kubectl config use-context <ns>`

### Edit  [tkg-cluster.yaml](tkg-cluster.yaml) and change 
```yaml
  namespace: services
  name: test
```
as needed.

### To change the VM class and node counts change 
```yaml
spec/topology/controlPlane/count
spec/topology/controlPlane/class
spec/topology/workers/count
spec/topology/workers/class
spec/distribution/version
```
as needed.

