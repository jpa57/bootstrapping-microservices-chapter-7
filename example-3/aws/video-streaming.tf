# Deploys the Video streaming microservice to the Kubernetes cluster.

variable "secret_arn" {
}

data "aws_secretsmanager_secret" "secrets" {
  arn = var.secret_arn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

locals {
    service_name = "video-streaming"
    account_id = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["ACCOUNT_ID"]
    username =   jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["USER_NAME"]
    password =   jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string))["PASSWORD"]
    login_server = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
    image_tag = "${local.login_server}/${var.app_name}:${var.app_version}"
}

resource "null_resource" "docker_build" {

    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        command = "docker build -t ${local.image_tag} --file ../${var.app_name}/Dockerfile-prod ../${var.app_name}"
    }
}

resource "null_resource" "docker_login" {

    depends_on = [ null_resource.docker_build ]

    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
      # command to authenticate docker to our environment uses get-login-password.
      # Combined with --profile, we don't have to put any login info on the command
      # line or in source.  Granted it is in our ~/.aws/credentials file
      command = "aws ecr get-login-password --region ${var.region} --profile microservices | docker login --username AWS --password-stdin ${local.login_server}"
    }
}

resource "null_resource" "docker_push" {

    depends_on = [ null_resource.docker_login ]

    triggers = {
        always_run = timestamp()
    }

    provisioner "local-exec" {
        command = "docker push ${local.image_tag}"
    }
}

locals {
    dockercreds = {
        auths = {
            "${local.login_server}" = {
                auth = base64encode("${local.username}:${local.password}")
            }
        }
    }
}

resource "kubernetes_secret" "docker_credentials" {
    metadata {
        name = "docker-credentials"
    }

    data = {
        ".dockerconfigjson" = jsonencode(local.dockercreds)
    }

    type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_deployment" "service_deployment" {

    depends_on = [ null_resource.docker_push ]

    metadata {
        name = local.service_name

    labels = {
            pod = local.service_name
        }
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                pod = local.service_name
            }
        }

        template {
            metadata {
                labels = {
                    pod = local.service_name
                }
            }

            spec {
                container {
                    image = local.image_tag
                    name  = local.service_name

                    env {
                        name = "PORT"
                        value = "80"
                    }
                }

                image_pull_secrets {
                    name = kubernetes_secret.docker_credentials.metadata[0].name
                }
            }
        }
    }
}

resource "kubernetes_service" "service" {
    metadata {
        name = local.service_name
    }

    spec {

        port {
            port        = 80
            target_port = 80
        }
        type             = "LoadBalancer"
    }
}

# Create a local variable for the load balancer name.
locals {
  lb_name = split("-", split(".", kubernetes_service.service.status.0.load_balancer.0.ingress.0.hostname).0).0
}

# Read information about the load balancer using the AWS provider.
data "aws_elb" "video-streaming" {
  name = local.lb_name
}

output "load_balancer_name" {
  value = local.lb_name
}

output "load_balancer_hostname" {
  value = kubernetes_service.service.status.0.load_balancer.0.ingress.0.hostname
}

output "load_balancer_info" {
  value = data.aws_elb.video-streaming
}
