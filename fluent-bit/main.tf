data "aws_caller_identity" "current" {}

resource "aws_iam_role" "logger_role" {
  name = "eks-logger-role"

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
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.eks_oidc_provider}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:fluentbit-ns:fluent-bit"
          }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "logger_instance_profile" {
  name = "eks-logger-profile"
  role = aws_iam_role.logger_role.name
}

data "aws_iam_policy_document" "logger_policy" {
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

resource "aws_iam_policy" "logger_policy" {
  name        = "fluentbit-logger-policy"
  description = "Policy for logger"
  policy      = data.aws_iam_policy_document.logger_policy.json
}

resource "aws_iam_role_policy_attachment" "logger_policy_attachment" {
  role       = aws_iam_role.logger_role.name
  policy_arn = aws_iam_policy.logger_policy.arn
}


resource "helm_release" "fluent-bit" {

  repository = "oci://registry-1.docker.io/bitnamicharts/"
  chart      = "fluent-bit"
  version    = "2.3.15"
  name       = "fluent-bit"

  create_namespace = true
  namespace        = "fluentbit-ns"

  values = ["${file("./fluent-bit/fluent-bit-values.yaml")}"]

  set {
    name  = "config.outputs"
    value = <<EOF
[OUTPUT]
    Name cloudwatch_logs
    Match *
    region ${var.region}
    log_group_name /aws/containerinsights/${var.eks_cluster_name}/application
    log_stream_prefix from-fluent-bit-
    auto_create_group true
EOF
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.logger_role.arn
  }
}
