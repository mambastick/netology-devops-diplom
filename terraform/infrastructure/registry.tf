resource "yandex_container_registry" "main" {
  name      = var.project_name
  folder_id = var.folder_id
}

resource "yandex_kms_symmetric_key" "kubernetes" {
  name              = "${var.project_name}-kubernetes"
  description       = "Encryption key for Kubernetes secrets"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}
