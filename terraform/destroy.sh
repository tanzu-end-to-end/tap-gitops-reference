#!/bin/bash -ex
for im in $(yq e -I=0 -o=j '.clusters[]' servers.yaml); do
      cluster=$(echo $im | jq -r '.name' -)
      config=$(echo $im | jq -r '.config' -)    
      region=$(echo $im | jq -r '.region' -)
      eksctl delete cluster  --region=${region} --name ${cluster}  --disable-nodegroup-eviction --pod-eviction-wait-period 1s   
done

