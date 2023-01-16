variable "kubernetes" {
  type = object({
    host                = string
    ca_cert             = string
    service_account_jwt = string
  })
  description = "Kubernetes configuration parameters"
  default     = null
}

variable "github" {
  type = object({
    org_name = string
    org_url  = string
    users    = list(string)
  })
  description = "GitHub configuration parameters"
  default     = null
}
