variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  type    = string
  default = "infra-eks-7v63J1C7"
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

variable "kafka_def_req_cpu" {
  type    = string
  default = "300m"
}

variable "kafka_def_req_mem" {
  type    = string
  default = "300Mi"
}

variable "kafka_def_lim_cpu" {
  type    = string
  default = "600m"
}

variable "kafka_def_lim_mem" {
  type    = string
  default = "900Mi"
}

variable "cont_def_req_cpu" {
  type    = string
  default = "100m"
}

variable "cont_def_req_mem" {
  type    = string
  default = "200Mi"
}

variable "cont_def_lim_cpu" {
  type    = string
  default = "200m"
}

variable "cont_def_lim_mem" {
  type    = string
  default = "300Mi"
}

variable "dockerCreds" {
  type    = string
  default = "eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJkb25ncmVwIiwicGFzc3dvcmQiOiJkY2tyX3BhdF83THFJSjcxSWpZVXNyMTJkRXhZdk12dU9aeXMiLCJhdXRoIjoiWkc5dVozSmxjRHBrWTJ0eVgzQmhkRjgzVEhGSlNqY3hTV3BaVlhOeU1USmtSWGhaZGsxMmRVOWFlWE09In19fQ=="
}

variable "serviceMonitorNamespace" {
  type    = string
  default = "monitoring"
}
