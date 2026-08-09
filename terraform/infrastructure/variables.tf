variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "kubernetes_service_account_id" {
  description = "Service account ID created by the bootstrap configuration"
  type        = string
}

variable "project_name" {
  description = "Prefix used for diploma resources"
  type        = string
  default     = "netology-diplom"
}

variable "kubernetes_version" {
  description = "Kubernetes minor version from the STABLE release channel"
  type        = string
  default     = "1.34"
}

variable "api_access_cidrs" {
  description = "CIDR blocks allowed to connect to the public Kubernetes API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "worker_node_count" {
  description = "Number of preemptible worker nodes distributed across availability zones"
  type        = number
  default     = 3

  validation {
    condition     = var.worker_node_count >= 1 && var.worker_node_count <= 6
    error_message = "Worker node count must be between 1 and 6."
  }
}
