# Sets global variables for this Terraform project.

variable "app_name" {
    default = "video-streaming"
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
  #profile = var.profile  Uncomment causes failure with Terraform Cloud infrastructure
}

variable "instance_type" {
  description = "Type of EC2 instance to run Terraform CLoud; value in Terraform UI"
}

variable "instance_name" {
  description = "Name of EC2 instance to run Terraform CLoud; value created by Terrform"
}
