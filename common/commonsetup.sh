cd tkgclusters
# run yet another script to get the Supervisor CLuster kubeconfig
if [ -s "./sc.kubeconfig" ]
then
    echo "Using ./sc.kubeconfig"
else
    ../common/getsckubeconfig.sh
fi
#save the ns, cluster name and cluster version for later use
KUBE_NAMESPACE=$(cat  tkg-cluster.yaml | yq r - 'metadata.namespace')
TCL_NAME=$( cat  tkg-cluster.yaml | yq r - 'metadata.name')
TCL_VER=$( cat  tkg-cluster.yaml | yq r - 'spec.distribution.version')
