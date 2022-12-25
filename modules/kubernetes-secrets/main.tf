#
# Kubernetes secrets backend to generate dynacmic service accounts and access token
#

variable "host" {
  type        = string
  description = "Kubernetes API endpoint"
}

variable "ca_cert" {
  type        = string
  description = "Kubernetes cluster CA certificate"
}

variable "service_account_jwt" {
  type        = string
  description = "Kubernetes service account JWT"
}

resource "vault_kubernetes_secret_backend" "secrets_engine" {
  path                      = "kubernetes"
  default_lease_ttl_seconds = 43200
  max_lease_ttl_seconds     = 86400
  kubernetes_host           = var.host
  kubernetes_ca_cert        = var.ca_cert
  service_account_jwt       = var.service_account_jwt
  disable_local_ca_jwt      = false
}

# The backend role is mapped to a Kubernetes cluster role called admin
resource "vault_kubernetes_secret_backend_role" "admin_role" {
  backend                       = vault_kubernetes_secret_backend.secrets_engine.path
  name                          = "admin-role"
  token_max_ttl                 = 43200
  token_default_ttl             = 21600
  kubernetes_role_name          = "cluster-admin"
  kubernetes_role_type          = "ClusterRole"
  allowed_kubernetes_namespaces = ["*"]
}

resource "vault_policy" "access_policy" {
  name   = "kubernetes-secrets-acl"
  policy = file("${path.module}/acl.hcl")
}

output "vault_policy_name" {
  value       = vault_policy.access_policy.name
  description = "The name of the Vault ACL to reference in auth methods."
}

output "secrets_engine_path" {
  value       = vault_kubernetes_secret_backend.secrets_engine.path
  description = "The mount path of the Kubernetes secrets engine."
}
