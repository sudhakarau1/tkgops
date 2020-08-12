#!/bin/bash
## use jmanzaneque@vmware.com snippets to get the SC Kubeconfig
## from https://github.com/josemzr/vsphere-k8s-scripts
SV_IP='192.168.2.1' #VIP for the Supervisor Cluster
VC_IP='vcsa-wcp.me.com' #URL for the vCenter
SV_MASTER_IP=192.168.1.60
VC_ADMIN_USER='administrator@vsphere.local' #User for the Supervisor Cluster
VC_ADMIN_PASSWORD='VMware1!' #Password for the Supervisor Cluster user

# Logging function that will redirect to stderr with timestamp:
logerr() { echo "$(date) ERROR: $@" 1>&2; }
# Logging function that will redirect to stdout with timestamp
loginfo() { echo "$(date) INFO: $@" ;}

# Exit the script if the supervisor cluster is not up
if [ $(curl -m 15 -k -s -o /dev/null -w "%{http_code}" https://"${SV_IP}") -ne "200" ]; then
    logerr "Supervisor cluster not ready. Exiting..."
    exit 2
fi
#SSH into vCenter to get credentials for the supervisor cluster master VMs
sshpass -p "${VC_ADMIN_PASSWORD}" ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@"${VC_IP}" com.vmware.shell /usr/lib/vmware-wcp/decryptK8Pwd.py > ./sv-cluster-creds 2>&1
if [ $? -eq 0 ] ;
then
      loginfo "Connecting to the vCenter to get the supervisor cluster VM credentials..."
      SV_MASTER_PASSWORD=$(cat ./sv-cluster-creds | sed -n -e 's/^.*PWD: //p')
      echo  "${SV_MASTER_PASSWORD}" > ./sc.masterpass
else
      logerr "There was an error logging into the vCenter. Exiting..."
      exit 2
fi
# Transfer the SC kubeconfig from the Supervisor Cluster Master VM
loginfo "Getting the SC kubeconfig"

sshpass -f  ./sc.masterpass scp -vvv -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q root@"${SV_MASTER_IP}":./.kube/config ./sc.kubeconfig
if [ $? -eq 0 ] ;
then
      loginfo "SC kubeconfig acquired at ./sc.kubeconfig!"
else
      logerr "There was an error acquiring the SC kubeconfig. Exiting..."
      exit 2
fi
##End jose snippet
sed -i "s/127\.0\.0\.1/${SV_MASTER_IP}/g" ./sc.kubeconfig