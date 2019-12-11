variable "fastly-service-name" {
  type    = string
  default = "fastly-serve-stale"
}

variable "activate" {
  type    = bool
  default = true
}

variable "sites" {
  type = map(object({ origin = string, domains = list(string), static_error_path = string }))
  #type = "map"
}

variable "version_comment" {
  default = ""
}

# AWS access key used for s3 logging
variable "logging_aws_access_key" {
  type    = string
  default = "xxxx"
}

# AWS secret key used for s3 logging
variable "logging_aws_secret_key" {
  type    = string
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

variable "serve_stale" {
  type    = bool
  default = false
}

# this equates to the 'Low' health check setting
variable "health_interval" {
  type    = number
  default = 60000
}

variable "health_threshold" {
  type    = number
  default = 1
}

variable "health_window" {
  type    = number
  default = 2
}
