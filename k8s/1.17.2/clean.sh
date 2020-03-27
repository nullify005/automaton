#!/bin/bash

# blat the install
set -x
export KUBECONFIG=salt/tmp/kubectl.conf
NAMESPACES=(
  test
  istio-system
  istio-operator
)
for ns in ${NAMESPACES[@]}; do
  kubectl delete ns ${ns}
done
helm list | grep -v NAME | awk '{print $1}' | xargs -n 1 helm delete --purge
