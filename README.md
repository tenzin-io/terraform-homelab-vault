# README
A Terraform module that helps manage my home lab Vault server.

| feature flag | description |
| - | - | 
| `enable_github_jwt_auth` | Enables the GitHub JWT auth method.  Primarily for use by GitHub Actions runner accessing Vault secrets. |
| `enable_github_pat_auth` | Enables the GitHub personal access token auth method.  Primarily for interactive Vault UI sessions and access to the Vault CLI in the Vault UI. |
| `enable_kubernetes_secrets` | Enables the Kubernetes secrets engine.  Used to create short lived service accounts on Kubernetes cluster. |
| `enable_kv_secrets` | Enables the KV secrets engine.  This feature flag will require the use of `terraform import` if the default KV secrets engine exists. |
| `enable_artifactory_secrets` | Enables the Artifactory secrets engine.  Use to create short lived scoped access tokens from Artifactory.  This will allow automation to get access to Artifactory and publish artifacts to it. |
