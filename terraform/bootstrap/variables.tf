variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string

  validation {
    condition     = length(var.cloud_id) > 0
    error_message = "Cloud ID must not be empty."
  }
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string

  validation {
    condition     = length(var.folder_id) > 0
    error_message = "Folder ID must not be empty."
  }
}

variable "default_zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "project_name" {
  description = "Prefix used for diploma resources"
  type        = string
  default     = "netology-diplom"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}[a-z0-9]$", var.project_name))
    error_message = "Project name must contain 4-32 lowercase letters, numbers or hyphens and start with a letter."
  }
}

variable "state_bucket_name" {
  description = "Globally unique Object Storage bucket name; generated from the folder ID when omitted"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.state_bucket_name == null ||
      can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    )
    error_message = "Bucket name must be a valid 3-63 character Object Storage name."
  }
}
