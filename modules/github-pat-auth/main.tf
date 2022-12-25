#
# GitHub users auth method
#

variable "vault_policies" {
  type        = list(string)
  description = "A list of Vault policies to attach to the GitHub users."
  default     = []
}

variable "users" {
  type        = list(string)
  description = "A list of allowed GitHub users to Vault."
}

variable "org_name" {
  type        = string
  description = "GitHub organization name."
}

resource "vault_github_auth_backend" "github_user_auth" {
  description  = "GitHub user authentication method."
  organization = var.org_name
}

resource "vault_github_user" "github_user" {
  for_each = toset(var.users)
  backend  = vault_github_auth_backend.github_user_auth.id
  user     = each.value
  policies = var.vault_policies
}
