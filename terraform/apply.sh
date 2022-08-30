#!/bin/bash -ex

# Retrieve the list of output commands from terraform output.  This is map of cluster name as keys with command as value
#APPLY_TMC_CMDS=$(cat clusters.json | jq -c .clusters)

for im in $(yq eval -o=j servers.yaml | jq -cr '.servers[]'); do
      cluster=$(echo $im | jq -r '.name' -)
      # eksctl create cluster --config-file eks-${cluster}.yaml
      #aws eks update-kubeconfig --region us-east-2 --name $cluster
      # add cluster essentials
      export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:e00f33b92d418f49b1af79f42cb13d6765f1c8c731f4528dfff8343af042dc3e
      export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
      export INSTALL_REGISTRY_USERNAME=jellin@pivotal.io
      export INSTALL_REGISTRY_PASSWORD=<wrong>
      cd $HOME/tanzu-cluster-essentials
              ./install.sh --yes
      # add repos for tanzu standard
      kubectl apply -f ../../tanzu-standard.yaml --dry-run=client
      # add metrics
      tanzu package install metrics-server --package-name metrics-server.tanzu.vmware.com --version 0.5.1+vmware.1-tkg.1
done

