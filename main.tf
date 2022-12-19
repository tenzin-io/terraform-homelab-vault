terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.11.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

#
# GitHub JWT auth method
#
resource "vault_jwt_auth_backend" "github_jwt_auth" {
  description        = "GitHub JWT authentication method"
  path               = "jwt"
  oidc_discovery_url = var.oidc_discovery_url
  bound_issuer       = var.bound_issuer
}

# A policy that allows reading of any secret and generating publish access tokens from Artifactory
resource "vault_policy" "github_actions_runner_policy" {
  name   = "github-actions-runner-policy"
  policy = <<EOT
path "secret/*" {
  capabilities = ["read"]
}
path "artifactory/token/publish"
{
 capabilities = ["read"]
}
EOT
}

# Allows all repository belonging to the var.github_org_url access to the policy
resource "vault_jwt_auth_backend_role" "github_actions_runner_role" {
  backend           = vault_jwt_auth_backend.github_jwt_auth.path
  role_name         = "github-actions-runner-role"
  token_policies    = ["github-actions-runner-policy"]
  bound_audiences   = [var.github_org_url]
  bound_claims_type = "string"
  bound_claims = {
    aud = var.github_org_url
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
  kubernetes_host           = var.kubernetes_host
  kubernetes_ca_cert        = var.kubernetes_ca_cert
  service_account_jwt       = var.service_account_jwt
  disable_local_ca_jwt      = false
}

# The backend role is mapped to a Kubernetes cluster role called admin
resource "vault_kubernetes_secret_backend_role" "admin_role" {
  backend                       = vault_kubernetes_secret_backend.homelab_kubernetes_secrets.path
  name                          = "admin-role"
  allowed_kubernetes_namespaces = ["*"]
  token_max_ttl                 = 43200
  token_default_ttl             = 21600
  kubernetes_role_name          = "admin"
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
  "sha_256": "${var.artifactory_plugin_sha256sum}",
  "args":"-tls-skip-verify=true"
}
EOT
}

resource "vault_generic_endpoint" "artifactory_config" {
  ignore_absent_fields = true
  path                 = "artifactory/config/admin"
  data_json            = <<EOT
{
  "url": "${var.artifactory_url}",
  "access_token": "${var.artifactory_access_token}"
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
