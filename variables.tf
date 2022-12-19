#
# Vault provider variables 
#
variable "vault_token" {
  type        = string
  description = "Vault access token to perform administrative actions"
}

variable "vault_address" {
  type        = string
  description = "Vault server address"
}

#
# Kubernetes secrets engine
#
variable "kubernetes_host" {
  type        = string
  description = "Kubernetes API endpoint"
  default     = ""
}

variable "kubernetes_ca_cert" {
  type        = string
  description = "Kubernetes CA certificate"
  default     = ""
}

variable "service_account_jwt" {
  type    = string
  default = ""
  description = "Kubernetes service account token for Vault"
}

#
# GitHub JWT auth
#
variable "oidc_discovery_url" {
  type = string
  default = "https://token.actions.githubusercontent.com"
}

variable "bound_issuer" {
  type = string
  default = "https://token.actions.githubusercontent.com"
}

variable "github_org_url" {
  type = string
  default = ""
  description = "The GitHub organization URL"
}

#
# Artifactory secrets engine
#
variable "artifactory_url" {
  type = string
  description = "Artifactory repository URL"
}

variable "artifactory_access_token" {
  type = string
  description = "An access token from which scoped access tokens can be created"
}

variable "artifactory_plugin_sha256sum" {
  type = string
  description = "The sha256sum of the Artifactory plugin.  Needed for plugin registration"
}
