variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "default_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}

variable "PUBLIC_SUBNETS" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "PRIVATE_SUBNETS" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "eks_cluster_min_size" {
  type    = number
  default = 3
}

variable "eks_cluster_max_size" {
  type    = number
  default = 6
}

variable "eks_cluster_desired_capacity" {
  type    = number
  default = 3
}

variable "postgresUser" {
  type    = string
  default = "piyush"
}

variable "autoscaler_repo" {
  type    = string
  default = "../helm-eks-autoscaler"
}
