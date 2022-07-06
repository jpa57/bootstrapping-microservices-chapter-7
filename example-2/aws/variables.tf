# Sets global variables for this Terraform project.

variable "app_name" {
    default = "supermetaflix"
}

variable app_version { # Can't be called version! That's a reserved word.
}


variable "region" {
  default     = "us-west-2"
  description = "AWS region"
}

variable "profile" {
  default = "microservices"
  description = "AWS profile for use by Terraform "
}

provider "aws" {
  region = var.region
  profile = var.profile
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

variable "secret_arn" {
}

data "aws_secretsmanager_secret" "secrets" {
  arn = var.secret_arn
}
