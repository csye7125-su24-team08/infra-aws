resource "aws_kms_key" "ebs" {
  description = "KMS key for EKS volume encryption"
  key_usage   = "ENCRYPT_DECRYPT"
  is_enabled  = true
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/eks-volume-encryption"
  target_key_id = aws_kms_key.ebs.key_id
}
