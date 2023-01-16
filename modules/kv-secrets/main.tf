resource "vault_policy" "access_policy" {
  name   = "kv-secrets-acl"
  policy = file("${path.module}/acl.hcl")
}

resource "vault_mount" "kv_mount" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "kv_secrets" {
  mount        = vault_mount.kv_mount.path
  max_versions = 15
  cas_required = false
}

output "vault_policy_name" {
  value       = vault_policy.access_policy.name
  description = "The name of the Vault ACL to reference in auth methods."
}
