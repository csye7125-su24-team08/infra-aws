# Terraform README

This README provides an overview of how we are using Terraform to set up an EKS cluster on AWS using the eks/aws module.

## Prerequisites

Before getting started, make sure you have the following prerequisites:

- AWS account with appropriate permissions
- Terraform installed on your local machine
- AWS CLI configured with your AWS credentials

## Getting Started

To set up the EKS cluster, follow these steps:

1. Clone the repository to your local machine.
2. Navigate to the `infra-aws` directory.
3. Update the `variables.tf` file with your desired configurations.
4. Run `terraform init` to initialize the Terraform workspace.
5. Run `terraform plan` to see the execution plan.
6. If the plan looks good, run `terraform apply` to create the resources.
7. Wait for the resources to be provisioned. This may take a few minutes.
8. Once the cluster is up and running, you can access it using the AWS CLI or Kubernetes tools.

## Deploying Kafka and PostgreSQL

To deploy Kafka and PostgreSQL using Terraform, follow these steps:

1. Make sure you have the `kafka-values.yaml` and `postgres-values.yaml` files available in the `infra-aws` directory.

2. Open the `kafka-values.yaml` file and update the desired configurations for Kafka. This file contains the settings for topics, partitions, replication factor, and other Kafka-specific configurations.

3. Open the `postgres-values.yaml` file and update the desired configurations for PostgreSQL. This file contains the settings for database name, username, password, and other PostgreSQL-specific configurations.

4. Run `terraform apply` to create the Kafka and PostgreSQL resources based on the updated configurations in the YAML files.

5. Wait for the resources to be provisioned. This may take a few minutes.

6. Once the deployment is complete, you can access Kafka and PostgreSQL using the appropriate connection details specified in the YAML files.

Remember to update the YAML files whenever you need to change the configurations for Kafka and PostgreSQL.

For more information on deploying Kafka and PostgreSQL with Terraform, refer to the documentation provided for each service.


## Additional Resources

For more information on Terraform and EKS, refer to the following resources:

- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [AWS EKS Documentation](https://aws.amazon.com/eks/)

## Changing Context to AWS EKS

To change the context to the AWS EKS cluster, follow these steps:

1. Open your terminal or command prompt.
2. Navigate to the directory where you have the Terraform configuration files.
3. Run the following command to change the context:

```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --profile profile-name
```

Make sure to replace `$(terraform output -raw region)` with the actual region output from Terraform, and `$(terraform output -raw cluster_name)` with the actual cluster name output from Terraform.

4. After running the command, your kubeconfig file will be updated with the necessary configurations to connect to the AWS EKS cluster.

Now you can use Kubernetes tools or the AWS CLI to interact with the EKS cluster.

For more information on managing EKS clusters, refer to the [AWS EKS Documentation](https://aws.amazon.com/eks/).

## Installing Git Plugin for Helm

Before you can install `eks-autoscaler` from a private Git repository using Helm, you need to install the Git plugin for Helm. Follow these steps to install the Git plugin:

1. Open your terminal or command prompt.
2. Run the following command to add the Helm stable repository:

  ```bash
  helm repo add stable https://charts.helm.sh/stable
  ```

3. Run the following command to update the Helm repositories:

  ```bash
  helm repo update
  ```

4. Run the following command to install the Git plugin for Helm:

  ```bash
  helm plugin install https://github.com/aslafy-z/helm-git.git
  ```

  This will install the Git plugin for Helm, allowing you to install charts from private Git repositories.

Once you have installed the Git plugin for Helm, you can proceed with installing `eks-autoscaler` from your private Git repository.

For more information on using Helm with private Git repositories, refer to the [Helm documentation](https://helm.sh/docs/).
