# tapp-gitops-ref
## Kubectx

You will need two contexts,  one for appref-1 (Build/View) and one for appref-2 (Run/Iterate).  It is assumed that the context names will be of the format `user@clustername`a

## Params.

copy `params-REDACTED.yaml` to `params.yaml` and export the location of `params.yaml`

```bash
export PARAMS_YAML=~/dev/tap/tapp-gitops-ref/params.yaml
```


## Apply tap to to both clusters.
```
scripts/apply.sh default@appref-1                
scripts/apply.sh default@appref-2                  
```

Verify everything is fully reconciled in both clusters.

```
kubect get apps -n tap-install
```

## Get Cluter Access information

The view cluster requires access to the run/iterate cluter and the metastore.

Run the following two scripts to update params.yaml with the correct values. Then apply the access updates to the clusters.

```bash
scripts/enable-meta-datastore-access.sh default@appref-1
scripts/enable-tap-gui-visibility.sh default@appref-1   
scripts/apply.sh default@appref-1
scripts/apply.sh default@appref-2                 
```

## Test it out

tanzu apps workload create tanzu-java-web-app \
   --git-repo https://github.com/jeffellin/tanzu-java-web-app \
   --git-branch main \
   --type web \
   --label app.kubernetes.io/part-of=tanzu-java-web-app \
   --label apps.tanzu.vmware.com/has-tests=true \
   --yes \
   --namespace canary