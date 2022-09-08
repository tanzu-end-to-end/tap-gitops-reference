#!/bin/bash -e
START="$(date +%s)"

# Retrieve the list of output commands from terraform output.  This is map of cluster name as keys with command as value
#APPLY_TMC_CMDS=$(cat clusters.json | jq -c .clusters)
: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}


# remote repo for install cluster essentials.
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:e00f33b92d418f49b1af79f42cb13d6765f1c8c731f4528dfff8343af042dc3e
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$(yq eval '.tap.tanzunet.username' $PARAMS_YAML)
export INSTALL_REGISTRY_PASSWORD=$(yq eval '.tap.tanzunet.password' $PARAMS_YAML)

convertsecs() {
  printf '%dh:%dm:%ds\n' $(($1/3600)) $(($1%3600/60)) $(($1%60))
}

function buildcluster {
        cluster=$1
        config=$2
        region=$3
        purpose=$4
        eksctl create cluster --config-file ${config} --dry-run
        aws eks update-kubeconfig --region ${region} --name $cluster

        export CONTEXT=$(cat ~/.kube/config | grep "current-context:" | sed "s/current-context: //")
        yq e -i '.clusters.'$purpose'.context = env(CONTEXT)' servers.yaml

        # add cluster essentials
        pushd $HOME/tanzu-cluster-essentials
                ./install.sh --yes
        # add repos for tanzu standard
        popd

        kubectl apply -f tanzu-standard.yaml
        # allow packages to reconcile
        sleep 20
        # add metrics
        tanzu package install metrics-server --package-name metrics-server.tanzu.vmware.com --version 0.5.1+vmware.1-tkg.1
}

im=$(yq e -I=0 -o=j '.clusters.build' servers.yaml)
name=$(echo $im | jq -r '.name' -)
config=$(echo $im | jq -r '.config' -)
region=$(echo $im | jq -r '.region' -)

buildcluster $name $config $region build

im=$(yq e -I=0 -o=j '.clusters.view' servers.yaml)
name=$(echo $im | jq -r '.name' -)
config=$(echo $im | jq -r '.config' -)
region=$(echo $im | jq -r '.region' -)

buildcluster $name $config $region view

DURATION=$[ $(date +%s) - ${START} ]

convertsecs ${DURATION}