terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.11.0"
    }
  }
}

provider "vault" {
  address = var.vault.address
  token   = var.vault.token
}

locals {
  github_actions_oidc_discovery_url = "https://token.actions.githubusercontent.com"
  github_actions_bound_issuer       = "https://token.actions.githubusercontent.com"
}

#
# GitHub auth method
#
resource "vault_github_auth_backend" "github_user_auth" {
  description  = "GitHub user authentication method"
  organization = var.github.org_name
}

resource "vault_github_user" "github_user" {
  for_each = toset(var.github.users)
  backend  = vault_github_auth_backend.github_user_auth.id
  user     = each.value
  policies = [vault_policy.github_access_policy.name]
}

#
# GitHub JWT auth method
#
resource "vault_jwt_auth_backend" "github_jwt_auth" {
  description        = "GitHub JWT authentication method"
  path               = "jwt"
  oidc_discovery_url = local.github_actions_oidc_discovery_url
  bound_issuer       = local.github_actions_bound_issuer
}

# A policy that allows reading of any secret and generating publish access tokens from Artifactory
resource "vault_policy" "github_access_policy" {
  name   = "github-access-policy"
  policy = <<EOT
path "secret/*" {
  capabilities = ["read"]
}
path "artifactory/token/publish"
{
 capabilities = ["read"]
}
path "kubernetes/creds/admin-role"
{
 capabilities = ["read","update"]
}
EOT
}

# Allows all repository belonging to the var.github_org_url access to the policy
resource "vault_jwt_auth_backend_role" "github_actions_runner_role" {
  backend           = vault_jwt_auth_backend.github_jwt_auth.path
  role_name         = "github-actions-runner-role"
  token_policies    = [vault_policy.github_access_policy.name]
  bound_audiences   = [var.github.org_url]
  bound_claims_type = "string"
  bound_claims = {
    aud = var.github.org_url
  }
  user_claim = "aud"
  role_type  = "jwt"
}

#
# Kubernetes secrets backend
#
resource "vault_kubernetes_secret_backend" "homelab_kubernetes_secrets" {
  path                      = "kubernetes"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400
  kubernetes_host           = var.kubernetes.host
  kubernetes_ca_cert        = var.kubernetes.ca_cert
  service_account_jwt       = var.kubernetes.service_account_jwt
  disable_local_ca_jwt      = false
}

# The backend role is mapped to a Kubernetes cluster role called admin
resource "vault_kubernetes_secret_backend_role" "admin_role" {
  backend                       = vault_kubernetes_secret_backend.homelab_kubernetes_secrets.path
  name                          = "admin-role"
  token_max_ttl                 = 43200
  token_default_ttl             = 21600
  kubernetes_role_name          = "cluster-admin"
  kubernetes_role_type          = "ClusterRole"
  allowed_kubernetes_namespaces = ["*"]
}

#
# Artifactory secrets backend
#

resource "vault_generic_endpoint" "artifactory_plugin" {
  ignore_absent_fields = true
  path                 = "sys/plugins/catalog/secret/artifactory"
  data_json            = <<EOT
{
  "command": "artifactory",
  "sha_256": "${var.artifactory.plugin_sha256sum}",
  "args":"-tls-skip-verify=true"
}
EOT
}

resource "vault_generic_endpoint" "artifactory_config" {
  ignore_absent_fields = true
  path                 = "artifactory/config/admin"
  data_json            = <<EOT
{
  "url": "${var.artifactory.url}",
  "access_token": "${var.artifactory.access_token}"
}
EOT
}

resource "vault_generic_endpoint" "artifactory_publish_role" {
  ignore_absent_fields = true
  path                 = "artifactory/roles/publish"
  data_json            = <<EOT
{
  "username": "publisher",
  "scope":"applied-permissions/groups:publish",
  "default_ttl": "8h",
  "max_ttl":"24h"
}
EOT
}
