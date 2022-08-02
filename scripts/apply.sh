#!/bin/bash -ex

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

if [ ! $# -eq 2 ]; then
  echo "Must cluster name as args"
  exit 1
fi

CLUSTER_NAME=$1

kubectl config use-context $CLUSTER_NAME
ADJUSTED_CLUSTER_NAME=$2
echo $ADJUSTED_CLUSTER_NAME
kapp deploy -a something -f <(ytt -f gitops --data-values-file=config-$ADJUSTED_CLUSTER_NAME.yaml --data-values-file $PARAMS_YAML) -y
#ytt -f gitops --data-values-file=config-$ADJUSTED_CLUSTER_NAME.yaml --data-values-file $PARAMS_YAML
