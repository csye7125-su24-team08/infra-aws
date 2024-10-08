resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = "c3.large"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 40
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ebs.arn
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    vpc-cni = {
      most_recent          = true
      configuration_values = jsonencode({ "enableNetworkPolicy" : "true" })
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    amazon-cloudwatch-observability = {
      most_recent = true
    }
  }

  cluster_enabled_log_types = ["scheduler", "controllerManager", "api", "audit", "authenticator"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    # iam_role_additional_policies = {
    #   AmazonRoute53ReadOnlyAccess = {
    #     policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
    #   }
    # }
    one = {
      name                     = "node-group-1"
      iam_role_use_name_prefix = false
      iam_role_name            = "node-group-role"

      instance_types = ["c7a.xlarge", "c3.large"]

      min_size     = var.eks_cluster_min_size
      max_size     = var.eks_cluster_max_size
      desired_size = 5
      launch_template = {
        id      = aws_launch_template.my_launch_template.id
        version = "$Latest"
      }
    }
  }
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
}

data "aws_route53_zone" "hosted_zone" {
  name = "dev.clustering.ninja."
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true

  enable_external_dns   = true
  enable_karpenter      = true
  enable_metrics_server = true

  cert_manager_route53_hosted_zone_arns = [
    data.aws_route53_zone.hosted_zone.arn
  ]

  tags = {
    Environment = "dev"
  }

  depends_on = [module.eks]
}

data "aws_ami" "eks_worker" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.29-*"]
  }

  owners = ["602401143452"] # Amazon EKS AMI account ID
}

resource "aws_iam_instance_profile" "eks_instance_profile" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.eks_instance_role.name
}

resource "aws_iam_role" "eks_instance_role" {
  name = "${var.cluster_name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
  ]
}

data "aws_iam_policy_document" "logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "logging_policy" {
  name        = "logger-policy"
  description = "Policy for auto-scaler"
  policy      = data.aws_iam_policy_document.logging_policy.json
}

resource "aws_iam_role_policy_attachment" "logging_policy_attachment" {
  role       = aws_iam_role.eks_instance_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "logging_policy_attachment_node_role" {
  role       = module.eks.cluster_iam_role_name
  policy_arn = aws_iam_policy.logging_policy.arn
}



# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
