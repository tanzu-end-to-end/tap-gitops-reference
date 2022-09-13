#!/bin/bash -e
START="$(date +%s)"

convertsecs() {
  printf 'RUNTIME %dh:%dm:%ds\n' $(($1/3600)) $(($1%3600/60)) $(($1%60))
}

function deletecluster {

        clusterkey=".clusters.$1"
        im=$(yq e -I=0 -o=j $clusterkey $BASEDIR/servers.yaml)
        cluster=$(echo $im | jq -r '.name' -)
        config=$(echo $im | jq -r '.config' -)
        region=$(echo $im | jq -r '.region' -)

        eksctl delete cluster  --region=${region} --name ${cluster}  --disable-nodegroup-eviction --pod-eviction-wait-period 1s
        rm "${BASEDIR}/${cluster}.yaml"

}


urls=(
  'build'
  'view'
 )
export BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export -f deletecluster
parallel -j 40 --group --keep-order deletecluster ::: "${urls[@]}"

DURATION=$[ $(date +%s) - ${START} ]

convertsecs ${DURATION}



