# Example-3

This example uses Terraform to create a Kubernetes cluster and deploys a database, RabbitMQ and the **Video streaming microservice** to it.

The difference from Example 2 is the removal of the LoadBalancer type in the database and rabbit definitions, and the addition of an interesting
'provider "null"' entry in providers.tf, all the action is in the video-streaming.tf file which is somewhat different for AWS.  
We removed the 'provider "null"' entry from the collection -- trying it in kubernetes.tf caused a failure.

Run this example using:

```bash
cd example-3/scripts
terraform apply
```


or on AWS using:

```bash
cd example-2/aws
terraform init
terraform apply -var="app_version=1" --auto-approve
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --profile microservices
```
