# Sets global variables for this Terraform project.

variable "app_name" {
    default = "supermetaflix"
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

variable "secret_arn" {
}

data "aws_secretsmanager_secret" "secrets" {
  arn = var.secret_arn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
