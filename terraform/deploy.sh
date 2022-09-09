#!/bin/bash -x

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}


export build_cluster=$(yq eval '.clusters.build.context' servers.yaml)
export view_cluster=$(yq eval '.clusters.view.context' servers.yaml)

getTapUICreds(){

  scripts/enable-tap-gui-visibility.sh $1  $2

}

getMetaStoreCreds(){
  scripts/enable-meta-datastore-access.sh $1
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
cd ..
applyCluster
getTapUICreds $view_cluster appref_1
getTapUICreds $build_cluster appref_2
getMetaStoreCreds $view_cluster
applyCluster

