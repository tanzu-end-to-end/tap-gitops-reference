#!/bin/bash -ex
START="$(date +%s)"

# Retrieve the list of output commands from terraform output.  This is map of cluster name as keys with command as value
#APPLY_TMC_CMDS=$(cat clusters.json | jq -c .clusters)
: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}


# remote repo for install cluster essentials.
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:e00f33b92d418f49b1af79f42cb13d6765f1c8c731f4528dfff8343af042dc3e
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$(yq eval '.tap.tanzunet.username' $PARAMS_YAML)
export INSTALL_REGISTRY_PASSWORD=$(yq eval '.tap.tanzunet.password' $PARAMS_YAML)
export BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


convertsecs() {
  printf 'RUNTIME %dh:%dm:%ds\n' $(($1/3600)) $(($1%3600/60)) $(($1%60))
}

function buildcluster {
        config=$1


        eksctl create cluster --config-file $BASEDIR/${config}


}

function installstuff(){

          clusterkey=".clusters.$1"
          im=$(yq e -I=0 -o=j $clusterkey "${BASEDIR}/servers.yaml")
          echo $im
          name=$(echo $im | jq -r '.name' -)
          config=$(echo $im | jq -r '.config' -)
          region=$(echo $im | jq -r '.region' -)
          purpose=$1

          aws eks update-kubeconfig --region ${region} --name $name --kubeconfig  "${BASEDIR}/${name}.yaml"

          export CONTEXT=$(cat ${BASEDIR}/${name}.yaml | grep "current-context:" | sed "s/current-context: //")
          yq e -i '.clusters.'$purpose'.context = env(CONTEXT)' "${BASEDIR}/servers.yaml"

          # add cluster essentials
          pushd $HOME/tanzu-cluster-essentials
          export KUBECONFIG="$BASEDIR/${name}.yaml"  &&  ./install.sh --yes
          # add repos for tanzu standard
          popd

          kubectl apply -f ${BASEDIR}/tanzu-standard.yaml
          # allow packages to reconcile
          #sleep 20
          # add metrics
          #tanzu package install metrics-server --package-name metrics-server.tanzu.vmware.com --version 0.5.1+vmware.1-tkg.1
}

function getclusterparams(){
  cluster=".clusters.$1"
  im=$(yq e -I=0 -o=j $cluster "${BASEDIR}/servers.yaml")
  name=$(echo $im | jq -r '.name' -)
  config=$(echo $im | jq -r '.config' -)
  region=$(echo $im | jq -r '.region' -)
  buildcluster $config

}

urls=(
  'build'
  'view'
 )
export -f getclusterparams
export -f buildcluster
export -f installstuff

#getclusterparams build
parallel -j 40 getclusterparams ::: "${urls[@]}"
parallel -j 40 installstuff ::: "${urls[@]}"


DURATION=$[ $(date +%s) - ${START} ]

convertsecs ${DURATION}