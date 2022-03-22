# Example-2

This example uses Terraform to create a Kubernetes cluster and deploys a database and **RabbitMQ** to it. We've kept the author's Azure solution intact, and added a parallel directory
'aws' analogous to the Azure 'scripts' directory.   The Terraform files in this example differ from example-1 only with the addition of the rabbitmq.tf file.

Run this example on Azure using:

```bash
cd example-2/scripts
terraform apply
```

or on AWS using:

```bash
cd example-2/aws
terraform init
terraform apply
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --profile microservices
```
