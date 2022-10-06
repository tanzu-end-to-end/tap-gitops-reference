#!/bin/bash -e

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

INFRA_LAB_CONFIG_YAML=local-config/infra-lab-values.yaml

export VSPHERE_WITH_TANZU_PASSWORD=$(yq e .h2o.password $PARAMS_YAML)

# if first argument is "admin" then use the H2O login info
#if [ "$1" = "admin" ]; then
#    export USER=$(yq e .vsphere.admin_username $INFRA_LAB_CONFIG_YAML)
#    export KUBECTL_VSPHERE_PASSWORD=$(yq e .vsphere.admin_password $INFRA_LAB_CONFIG_YAML)
#else
#    export USER=$1@vsphere.local
#    export KUBECTL_VSPHERE_PASSWORD=$(yq e .vsphere.standard_user_password $INFRA_LAB_CONFIG_YAML)
#fi

export SUPERVISOR_CLUSTER=$(yq e .h2o.supervisor.host $PARAMS_YAML)

# if there is no second argument, then assumed just trying to loginto the supervisor cluster, else log into TKC
if [ -z "$2" ]; then

   KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c "
    spawn kubectl vsphere  login --server=$SUPERVISOR_CLUSTER -u $USER --insecure-skip-tls-verify
    expect \"*?assword:*\"
    send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\"
    expect eof
    ")

    #kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --insecure-skip-tls-verify

    kubectl config use-context $SUPERVISOR_CLUSTER

elif [ "$2" = "all" ]; then
     echo "not supported"
#    kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-name tap-build --tanzu-kubernetes-cluster-namespace tap-services --insecure-skip-tls-verify
#
#    kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-name tap-run-test --tanzu-kubernetes-cluster-namespace dev --insecure-skip-tls-verify
#
#    kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-name tap-iterate --tanzu-kubernetes-cluster-namespace dev --insecure-skip-tls-verify
#
#    kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-name tap-view --tanzu-kubernetes-cluster-namespace tap-services --insecure-skip-tls-verify
#
#    kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --insecure-skip-tls-verify
#
#    kubectl config use-context $SUPERVISOR_CLUSTER

else
    export TKC_NAME=$3
    export VSPHERE_NAMESPACE_NAME=$2
    KUBECTL_VSPHERE_LOGIN_COMMAND=$(expect -c "
    spawn kubectl vsphere  login --server=$SUPERVISOR_CLUSTER --vsphere-username $USER --tanzu-kubernetes-cluster-name $TKC_NAME --tanzu-kubernetes-cluster-namespace $VSPHERE_NAMESPACE_NAME --insecure-skip-tls-verify
    expect \"*?assword:*\"
    send -- \"$VSPHERE_WITH_TANZU_PASSWORD\r\"
    expect eof
    ")
    #//kubectl vsphere login --server $SUPERVISOR_CLUSTER -u $USER --tanzu-kubernetes-cluster-name $TKC_NAME --tanzu-kubernetes-cluster-namespace $VSPHERE_NAMESPACE_NAME --insecure-skip-tls-verify

    kubectl config use-context $TKC_NAME

fi