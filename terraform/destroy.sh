#!/bin/bash -ex

function deletecluster {

        clusterkey=".clusters.$1"
        im=$(yq e -I=0 -o=j $clusterkey servers.yaml)
        cluster=$(echo $im | jq -r '.name' -)
        config=$(echo $im | jq -r '.config' -)
        region=$(echo $im | jq -r '.region' -)

        eksctl delete cluster  --region=${region} --name ${cluster}  --disable-nodegroup-eviction --pod-eviction-wait-period 1s

}


urls=(
  'build'
  'view'
 )

export -f deletecluster
parallel -j 40 --group --keep-order deletecluster ::: "${urls[@]}"




