variable "region" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_oidc_provider" {
  type = string
}

variable "dockerCreds" {
  type = string
}

variable "postgresUser" {
  type    = string
  default = "piyush"
}

variable "eks_instance_role_arn" {
  type = string
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
