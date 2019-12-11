variable "fastly-service-name" {
  type    = string
  default = "fastly-serve-stale"
}

variable "activate" {
  type    = bool
  default = true
}

variable "origin" {
  type = string
}

variable "domains" {
  type = list
}

variable "version_comment" {
  default = ""
}

# AWS access key used for s3 logging
variable "logging_aws_access_key" {
  type = string
  default = "xxxx"
}

# AWS secret key used for s3 logging
variable "logging_aws_secret_key" {
  type = string
  default = "xxxx"
}

variable "has_waf" {
  type    = bool
  default = false
}

variable "debugging" {
  type    = bool
  default = false
}
