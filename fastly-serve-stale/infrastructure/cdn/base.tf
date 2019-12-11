# Fastly Provider
provider "fastly" {
  version = "~> 0.9"
}

provider "aws" {
  version = "~> 2.28"
  region  = "ap-southeast-2"
}

module "logging" {
  #source = "s3::https://s3-ap-southeast-2.amazonaws.com/infrastructure-cdn-fastly-terraform-playpen.apse2.ffx.io/modules/logging.tgz"
  source = "/Users/lee.webb/Workspaces/ffxblue/infrastructure-cdn-module-logging"
}

#module "debug" {
#  source = "s3::https://s3-ap-southeast-2.amazonaws.com/infrastructure-cdn-fastly-terraform-playpen.apse2.ffx.io/modules/debug.tgz"
#}

# S3 State Backend
terraform {
  backend "s3" {
    region = "ap-southeast-2"
    bucket = "infrastructure-cdn-fastly-terraform-playpen.apse2.ffx.io"
    key    = "fastly-serve-stale/terraform.tfstate"
  }
}
