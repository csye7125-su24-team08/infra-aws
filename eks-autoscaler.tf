data "aws_caller_identity" "current" {}


resource "aws_iam_role" "autoscaler_role" {
  name = "eks-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:autoscaler-ns:eks-autoscaler-aws-cluster-autoscaler" }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "autoscaler_instance_profile" {
  name = "eks-autoscaler-instance-profile"
  role = aws_iam_role.autoscaler_role.name
}

data "aws_iam_policy_document" "auto_scaler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "auto_scaler_policy" {
  name        = "auto-scaler-policy"
  description = "Policy for auto-scaler"
  policy      = data.aws_iam_policy_document.auto_scaler_policy.json
}

resource "aws_iam_role_policy_attachment" "auto_scaler_policy_attachment" {
  role       = aws_iam_role.autoscaler_role.name
  policy_arn = aws_iam_policy.auto_scaler_policy.arn
}

resource "helm_release" "eks-autoscaler" {
  depends_on = [module.eks]

  name                = "eks-autoscaler"
  repository          = "git+https://github.com/csye7125-su24-team08/helm-eks-autoscaler.git"
  chart               = "helm-eks-autoscaler" # Relative path to the chart directory in the repo
  version             = "0.1.0"               # Specify the version of the Helm chart
  
  repository_username = "dongrep"
  repository_password = var.github_token

  create_namespace = true
  namespace        = "autoscaler-ns"

  set {
    name  = "cluster-autoscaler.autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "cluster-autoscaler.autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "cluster-autoscaler.rbac.create"
    value = "true"
  }

  set {
    name  = "cluster-autoscaler.rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.autoscaler_role.arn
  }

}
