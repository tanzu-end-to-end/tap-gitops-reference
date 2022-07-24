#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

if [ ! $# -eq 1 ]; then
  echo "Must cluster name as args"
  exit 1
fi

CLUSTER_NAME=$1

kubectl config use-context $CLUSTER_NAME

ADJUSTED_CLUSTER_NAME=${CLUSTER_NAME#*@*}
ADJUSTED_CLUSTER_NAME=${ADJUSTED_CLUSTER_NAME//-/_}

export API_SERVER_URL=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')
yq e -i '.clusters.[0].cluster.server = env(API_SERVER_URL)' kubeconfig.yaml

export API_SERVER_CA=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
yq e -i '.clusters[0].cluster.certificate-authority-data = env(API_SERVER_CA)' kubeconfig.yaml
#
export SA_TOKEN=$(kubectl -n tap-gui get secret $(kubectl -n tap-gui get sa  tap-gui-viewer-tapview -o=json | jq -r '.secrets[0].name') -o=json | jq -r '.data["token"]' | base64 --decode)
echo $SA_TOKEN
yq e -i '.users[0].user.token = env(SA_TOKEN)' kubeconfig.yaml

#echo "View cluster config updated, now you have to apply updates"
