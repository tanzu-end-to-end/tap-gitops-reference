#!/bin/bash -e
# This script only works on mac

: ${PARAMS_YAML?"Need to set PARAMS_YAML environment variable"}

# configure insight

VIEW_CLUSTER_NAME=tap-view

kubectl config use-context $VIEW_CLUSTER_NAME

METADATE_STORE_URL=https://metadata-store.$(yq e .clusters.view.domain $PARAMS_YAML)

tanzu insight config set-target $METADATE_STORE_URL \
    --ca-cert <(kubectl get secret -n metadata-store ingress-cert -ojsonpath="{.data.ca\.crt}" | base64 --decode) \
    --access-token $(kubectl get secret $(kubectl get sa -n metadata-store metadata-store-read-write-client -o json | jq -r '.secrets[0].name') -n metadata-store -o json | jq -r '.data.token' | base64 -d)

tanzu insight health
