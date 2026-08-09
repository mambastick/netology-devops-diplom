locals {
  state_bucket_name = coalesce(
    var.state_bucket_name,
    "${var.project_name}-tfstate-${var.folder_id}",
  )

  terraform_roles = toset([
    "container-registry.admin",
    "k8s.admin",
    "kms.admin",
    "load-balancer.admin",
    "storage.admin",
    "vpc.admin",
  ])

  kubernetes_roles = toset([
    "container-registry.images.puller",
    "k8s.clusters.agent",
    "kms.keys.encrypterDecrypter",
    "load-balancer.admin",
    "vpc.publicAdmin",
  ])
}

resource "yandex_iam_service_account" "terraform" {
  name        = "${var.project_name}-terraform"
  description = "Terraform service account for the diploma project"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform" {
  for_each = local.terraform_roles

  folder_id   = var.folder_id
  role        = each.value
  member      = "serviceAccount:${yandex_iam_service_account.terraform.id}"
  sleep_after = 5
}

resource "yandex_resourcemanager_cloud_iam_member" "terraform_cloud_member" {
  cloud_id    = var.cloud_id
  role        = "resource-manager.clouds.member"
  member      = "serviceAccount:${yandex_iam_service_account.terraform.id}"
  sleep_after = 5
}

resource "yandex_iam_service_account" "kubernetes" {
  name        = "${var.project_name}-kubernetes"
  description = "Service account for the Managed Kubernetes cluster and nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "kubernetes" {
  for_each = local.kubernetes_roles

  folder_id   = var.folder_id
  role        = each.value
  member      = "serviceAccount:${yandex_iam_service_account.kubernetes.id}"
  sleep_after = 5
}

resource "yandex_iam_service_account_iam_member" "terraform_uses_kubernetes" {
  service_account_id = yandex_iam_service_account.kubernetes.id
  role               = "iam.serviceAccounts.user"
  member             = "serviceAccount:${yandex_iam_service_account.terraform.id}"
  sleep_after        = 5
}

resource "yandex_iam_service_account_static_access_key" "terraform" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "S3 credentials for the diploma Terraform backend"

  depends_on = [yandex_resourcemanager_folder_iam_member.terraform]
}

resource "yandex_iam_service_account_key" "terraform" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Authorized key for diploma Terraform automation"
  key_algorithm      = "RSA_2048"
}

resource "yandex_kms_symmetric_key" "state" {
  name              = "${var.project_name}-tfstate"
  description       = "Encryption key for the diploma Terraform state"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"

  depends_on = [yandex_resourcemanager_folder_iam_member.terraform]
}

resource "yandex_storage_bucket" "state" {
  bucket     = local.state_bucket_name
  folder_id  = var.folder_id
  access_key = yandex_iam_service_account_static_access_key.terraform.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform.secret_key

  force_destroy = false

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.state.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.terraform]
}
