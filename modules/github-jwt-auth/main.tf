locals {
  github_actions_oidc_discovery_url = "https://token.actions.githubusercontent.com"
  github_actions_bound_issuer       = "https://token.actions.githubusercontent.com"
}

resource "vault_jwt_auth_backend" "github_jwt_auth" {
  description        = "GitHub JWT authentication method"
  path               = "jwt"
  oidc_discovery_url = local.github_actions_oidc_discovery_url
  bound_issuer       = local.github_actions_bound_issuer
}

variable "org_url" {
  type        = string
  description = "The GitHub organization URL endpoint."
}

variable "vault_policies" {
  type        = list(string)
  description = "A list of Vault ACL names to attach to the GitHub Actions runner role."
  default     = []
}

# Allows all repository belonging to the var.github_org_url access to the policy
resource "vault_jwt_auth_backend_role" "actions_runner_role" {
  backend           = vault_jwt_auth_backend.github_jwt_auth.path
  role_name         = "actions-runner-role"
  token_policies    = var.vault_policies
  bound_audiences   = [var.org_url]
  bound_claims_type = "string"
  bound_claims = {
    aud = var.org_url
  }
  user_claim = "aud"
  role_type  = "jwt"
}
