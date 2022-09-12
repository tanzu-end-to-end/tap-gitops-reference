#!/bin/bash -x

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}



getTapUICreds(){

  scripts/enable-tap-gui-visibility.sh $1  $2

}

getMetaStoreCreds(){
  scripts/enable-meta-datastore-access.sh $1
}
getKubeConfigs(){
  clusterkey=".clusters.$1"
  im=$(yq e -I=0 -o=j $clusterkey "${BASEDIR}/servers.yaml")
  echo $im
  name=$(echo $im | jq -r '.name' -)
  config=$(echo $im | jq -r '.config' -)
  region=$(echo $im | jq -r '.region' -)
  aws eks update-kubeconfig --region ${region} --name $name --kubeconfig  "${BASEDIR}/${name}.yaml"
  export KUBECONFIG=$KUBECONFIG:${BASEDIR}/${name}.yaml
}
applyCluster(){
  if ! ./scripts/apply.sh $view_cluster appref-1; then
      echo "Some Error Applying YAML run, it will most likely finish on its own\n"
      echo "run kubectl get apps -A\n"

  fi

  if ! ./scripts/apply.sh $build_cluster appref-2; then
       echo "Some Error Applying YAML run, it will most likely finish on its own\n"
        echo "run kubectl get apps -A\n"
  fi
}
echo $BASH_SOURCE[0]
export BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export build_cluster=$(yq eval '.clusters.build.context' $BASEDIR/servers.yaml)
export view_cluster=$(yq eval '.clusters.view.context' $BASEDIR/servers.yaml)

getKubeConfigs build
getKubeConfigs view

cd $BASEDIR/../
pwd

applyCluster
getTapUICreds $view_cluster appref_1
getTapUICreds $build_cluster appref_2
getMetaStoreCreds $view_cluster
applyCluster

