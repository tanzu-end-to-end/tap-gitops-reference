# tapp-gitops-ref

Before beginning installation it is assumed that you will have two clusters ready with contexts available. 

Ensure the Cluster meets the following requirements.
* Uses ContainerD as runtime ( EKS with Docker Runtime poses some challenges)
* Cluster Essentials ( you will need kapp controller and secretgen )
* Access to crate a DNS host
* Vault environment to create certificates for the desired hostnames

For an reference of how to create two clusters in h2o see the following link for inspiration.

https://dev.azure.com/kirkware/h2o-tap-lab/_git/gitops-platform

## Kubectx

You will need two contexts,  one for appref-1 (Build/View) and one for appref-2 (Run/Iterate).  

## Params.

copy `params-REDACTED.yaml` to `params.yaml` and export the location of `params.yaml` Details of the required params 
are at the end of this document.

```bash
export PARAMS_YAML=~/dev/tap/tapp-gitops-ref/params.yaml
```


## Apply tap to to both clusters.
```
scripts/apply.sh cluster1context> appref-1                
scripts/apply.sh cluster1context appref-2                  
```

Verify everything is fully reconciled in both clusters.

```
kubect get apps -n tap-install
```

## Get Cluster Access information

The view cluster requires access to the run/iterate cluter and the metastore.

Run the following two scripts to update params.yaml with the correct values. Then apply the access updates to the clusters.

```bash
scripts/enable-meta-datastore-access.sh default@appref-1
scripts/enable-tap-gui-visibility.sh default@appref-1   
scripts/apply.sh cluster1context> appref-1                
scripts/apply.sh cluster1context appref-2                 
```

## Changes

From here on out changing configuration can be done by commiting the desired yaml.  For instance if you wish 
to add an additional developer namespace add it to the <clusters/appref-1/workloads> directory

## Params

| Syntax                                |                           Description                            |                            Test Text |
|:--------------------------------------|:----------------------------------------------------------------:|-------------------------------------:|
| h2o.dns_subdomain                     |                      Subdomain of the hosts                      |            h2o-4-1396.h2o.vmware.com |
| vault.token                           |                    Token used to access Vault                    |                                      |
| vault.role                            |                  PKI Location in Vault for cert                  |                                      |  
| appsso.clientId                       |                          OIDC client ID                          |                                      |     
| appsso.clientSecret                   |                        OIDC Client Secret                        |                                      |     
| appsso.audience                       |                       URL of OIDC Provider                       |       https://dev-32828523.okta.com/ |
| s3.secret_key                         |       AWS Key that has read access to s3 bucket with docs        |                                      |  
| s3.access_key                         |                      AWS Access key for s3                       |                                      |  
| s3.region                             |                            S3 region                             |                            us-east-1 |  
| s3.bucket                             |                  s3 bucket with published docs                   |                                      |  
| tap.tanzunet.username                 |                      Username for Tanzunet                       |                                      |  
| tap.tanzuenet.password                |                      Password for Tanzunet                       |                                      |  
| tap.registry.ca_cert_data             |                         CA for registory                         |                                      |  
| tap.registry.username                 |      Username for registry   (for buildpacks, buiders etc)       |                                      |  
| tap.registry.pasword                  |                      Password for registry                       |                                      |  
| tap.supplychain.registry.ca_cert_data |                   CA for Supply Chain registry                   |                                      |  
| tap.supplychain.registry.username     | Username for Supply Chain registry   (for build images from TBS) |                                      |  
| tap.supplychain.registry.pasword      |                Password for Supply Chain registry                |                                      |  
| common.sso.issuer_uri                 |                       URL of OIDC Provider                       | https://dev-32828523.okta.com/oauth2 |  
| common.sso.client_id                  |                          OIDC Client ID                          |                                      |  
| common.sso.client_secret              |                        OIDC Client Secret                        |                                      |  
| repos.ssl.host                        |                         Github SSL Host                          |                   https://github.com |  
| repos.ssl.user                        |                         GitHub SSL User                          |                                 -ID- |  
| repos.ssl.password                    |                       Github SSL Password                        |                              -token- |  
| repos.ssh.host                        |                         Github SSH Host                          |                                      |  
| repos.ssh.privatekey                  |                      Github SSH Private Key                      |                                      |  
