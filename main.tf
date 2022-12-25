terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

#
# GitHub auth method
#
variable "enable_github_pat_auth" {
  type        = bool
  description = "Enable the GitHub personal access token auth method."
  default     = false
}

module "github_pat_auth" {
  count    = var.enable_github_pat_auth ? 1 : 0
  source   = "./modules/github-pat-auth"
  org_name = var.github.org_name
  users    = var.github.users
  vault_policies = compact([
    var.enable_kubernetes_secrets ? module.kubernetes_secrets[0].vault_policy_name : null,
    var.enable_kv_secrets ? module.kv_secrets[0].vault_policy_name : null,
    var.enable_artifactory_secrets ? module.artifactory_secrets[0].vault_policy_name : null
  ])
}

#
# GitHub JWT auth method
#

variable "enable_github_jwt_auth" {
  type        = bool
  description = "Enable the GitHub JWT auth method."
  default     = false
}

module "github_jwt_auth" {
  count   = var.enable_github_jwt_auth ? 1 : 0
  source  = "./modules/github-jwt-auth"
  org_url = var.github.org_url
  vault_policies = compact([
    var.enable_kubernetes_secrets ? module.kubernetes_secrets[0].vault_policy_name : null,
    var.enable_kv_secrets ? module.kv_secrets[0].vault_policy_name : null,
    var.enable_artifactory_secrets ? module.artifactory_secrets[0].vault_policy_name : null
  ])
}

#
# KV secrets backend
#
variable "enable_kv_secrets" {
  type        = bool
  description = "Enable the KeyVault secrets engine."
  default     = false
}

module "kv_secrets" {
  count  = var.enable_kv_secrets ? 1 : 0
  source = "./modules/kv-secrets"
}

#
# Kubernetes secrets backend
#
variable "enable_kubernetes_secrets" {
  type        = bool
  description = "Enable the Kubernetes secrets engine."
  default     = false
}

module "kubernetes_secrets" {
  count               = var.enable_kubernetes_secrets ? 1 : 0
  source              = "./modules/kubernetes-secrets"
  host                = var.kubernetes.host
  ca_cert             = var.kubernetes.ca_cert
  service_account_jwt = var.kubernetes.service_account_jwt
}

#
# Artifactory secrets backend
#

variable "enable_artifactory_secrets" {
  type        = bool
  description = "Enable the Artifactory secrets engine."
  default     = false
}

module "artifactory_secrets" {
  count              = var.enable_artifactory_secrets ? 1 : 0
  source             = "./modules/artifactory-secrets"
  artifactory_url    = var.artifactory.url
  plugin_sha256sum   = var.artifactory.plugin_sha256sum
  admin_access_token = var.artifactory.access_token
}
