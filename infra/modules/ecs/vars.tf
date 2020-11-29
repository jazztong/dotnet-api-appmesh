variable "name" {
  type        = string
  description = "Service name"
}

variable "paths" {
  type        = list(string)
  description = "Service ALB Paths"
  default     = []
}

variable "create_lb" {
  type    = bool
  default = true
}

variable "lb_listener_arn" {
  type        = string
  description = "LB listerner arn"
}

variable "image" {
  type        = string
  description = "Container image url"
}

variable "cluster" {
  type        = string
  description = "Cluster name"
}

variable "sg_id" {
  type        = string
  description = "Security group id"
}

variable "task_role_arn" {
  type        = string
  description = "Task role arn"
}

variable "service_discovery_namespace" {
  type        = string
  description = "Service discovery namespace"
}

variable "mesh_name" {
  type        = string
  description = "Mesh name"
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Service discovery namespace id"
}

variable "inject_env" {
  type        = map(string)
  description = "Environment variable"
}

variable "mesh_backend" {
  type        = list(string)
  description = "Mesh backend for this service"
  default     = []
}

variable "port" {
  type        = number
  description = "Application port"
  default     = 80
}

variable "protocol" {
  type        = string
  description = "Protocol for listener"
  default     = "http"
}
