#
# Vault provider variables 
#
variable "vault_token" {
  type        = string
  description = "Vault token to perform administrative actions"
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
}
