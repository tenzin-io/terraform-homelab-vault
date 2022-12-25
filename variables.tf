variable "kubernetes" {
  type = object({
    host                = string
    ca_cert             = string
    service_account_jwt = string
  })
  description = "Kubernetes configuration parameters"

}

variable "github" {
  type = object({
    org_name = string
    org_url  = string
    users    = list(string)
  })
  description = "GitHub configuration parameters"
}

variable "artifactory" {
  type = object({
    url              = string
    access_token     = string
    plugin_sha256sum = string
  })
  description = "Artifactory configuration parameters"
}

