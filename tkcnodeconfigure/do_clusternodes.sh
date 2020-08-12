#!/bin/bash
SCKUBECONFIG='./sc.kubeconfig'
if [ -f "$SCKUBECONFIG" ]
then
      SCKUBECMD="kubectl --kubeconfig=$SCKUBECONFIG --insecure-skip-tls-verify "
      NAMESPACE=demo
      CLUSTERNAME=goapp
      echo getting nodenames for TKC cluster $CLUSTERNAME in namespace $NAMESPACE
      NODENAMES=$($SCKUBECMD -n $NAMESPACE get virtualmachine -l "capw.vmware.com/cluster.name in ($CLUSTERNAME),capw.vmware.com/cluster.role in (node)" -o jsonpath='{.items[*].metadata.name}')
      echo $NODENAMES
      echo getting the kubeconfig for the TKC
      $SCKUBECMD --insecure-skip-tls-verify  -n $NAMESPACE get secret $CLUSTERNAME-kubeconfig -o jsonpath='{.data.value}'  | base64 --decode > ./${CLUSTERNAME}.kubeconfig
      TKCKUBECONFIG=./$CLUSTERNAME.kubeconfig
      if [ -s "${TKCKUBECONFIG}" ]
      then
            #iterate though nodes
            for x in $NODENAMES; do
                  echo Executing on node $x
                  . ./nsenter-node.sh $x
            done
      else
            echo " ${TKCKUBECONFIG} is empty."
      fi
fi