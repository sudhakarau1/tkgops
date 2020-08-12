set -x
node=${1}
echo executing on node ${node} with kubeconfig ${TKCKUBECONFIG}
TKCKUBECMD="kubectl --kubeconfig=${TKCKUBECONFIG} --insecure-skip-tls-verify "
nodeName=$($TKCKUBECMD get node ${node} -o template --template='{{index .metadata.labels "kubernetes.io/hostname"}}')
nodeSelector='"nodeSelector": { "kubernetes.io/hostname": "'${nodeName:?}'" },'
podName=${USER}-nsenter-${node}

$TKCKUBECMD run ${podName:?} --restart=Never --image overriden --overrides '
{
  "spec": {
    "hostPID": true,
    "hostNetwork": true,
    '"${nodeSelector?}"'
    "tolerations": [{
        "operator": "Exists"
    }],
    "containers": [
      {
        "name": "nsenter",
        "image": "alexeiled/nsenter:2.34",
        "command": [
          "/nsenter", "--all", "--target=1", "--", "bash", "-c", "curl -k https://192.168.2.2/api/systeminfo/getcert -o harbor.ca.cert && cat harbor.ca.cert >> /etc/pki/tls/certs/ca-bundle.crt && systemctl restart containerd.service"
        ],
        "stdin": true,
        "tty": true,
        "securityContext": {
          "privileged": true
        }
      }
    ]
  }
}'
sleep 30
echo deleting pod ${podName}
$TKCKUBECMD delete pod ${podName}

