#
# Artifactory secrets backend
#

variable "artifactory_url" {
  type = string
  description = "The Artifactory URL endpoint."
}

variable "plugin_sha256sum" {
  type = string
  description = "The Artifactory secrets plugin's SHA256 hash"
}

variable "admin_access_token" {
  type = string
  description = "The Artifactory admin access token to generate scoped access tokens."
  sensitive = true
}

resource "vault_generic_endpoint" "artifactory_plugin" {
  ignore_absent_fields = true
  path                 = "sys/plugins/catalog/secret/artifactory"
  data_json            = data.template_file.plugin_config.rendered
}

data "template_file" "plugin_config" {
  template = file("${path.module}/plugin-config.json")
  vars = {
    plugin_sha256sum = var.plugin_sha256sum
  }
}

resource "vault_generic_endpoint" "artifactory_config" {
  depends_on = [vault_generic_endpoint.artifactory_plugin]
  ignore_absent_fields = true
  path                 = "artifactory/config/admin"
  data_json            = data.template_file.admin_config.rendered
}

data "template_file" "admin_config" {
  template = file("${path.module}/admin-config.json")
  vars = {
    artifactory_url = var.artifactory_url
    admin_access_token = var.admin_access_token
  }
}

resource "vault_generic_endpoint" "artifactory_publish_role" {
  depends_on = [vault_generic_endpoint.artifactory_config]
  ignore_absent_fields = true
  path                 = "artifactory/roles/publish"
  data_json            =  file("${path.module}/publish-role.json")
}

resource "vault_policy" "access_policy" {
  depends_on = [vault_generic_endpoint.artifactory_config]
  name   = "artifactory-secrets-acl"
  policy = file("${path.module}/acl.hcl")
}

output "vault_policy_name" {
  value = vault_policy.access_policy.name
  description = "The name of the Vault ACL to reference in auth methods."
}

