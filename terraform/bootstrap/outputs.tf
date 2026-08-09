output "state_bucket_name" {
  description = "Object Storage bucket used by the main Terraform configuration"
  value       = yandex_storage_bucket.state.bucket
}

output "state_kms_key_id" {
  description = "KMS key used to encrypt the Terraform state bucket"
  value       = yandex_kms_symmetric_key.state.id
}

output "terraform_service_account_id" {
  description = "Service account used by Terraform locally and in CI"
  value       = yandex_iam_service_account.terraform.id
}

output "kubernetes_service_account_id" {
  description = "Service account used by the Managed Kubernetes cluster and nodes"
  value       = yandex_iam_service_account.kubernetes.id
}

output "backend_access_key" {
  description = "Access key for the S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform.access_key
  sensitive   = true
}

output "backend_secret_key" {
  description = "Secret key for the S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform.secret_key
  sensitive   = true
}

output "authorized_key_json" {
  description = "Authorized key JSON for Terraform automation"
  sensitive   = true
  value = jsonencode({
    id                 = yandex_iam_service_account_key.terraform.id
    service_account_id = yandex_iam_service_account.terraform.id
    created_at         = yandex_iam_service_account_key.terraform.created_at
    key_algorithm      = yandex_iam_service_account_key.terraform.key_algorithm
    public_key         = yandex_iam_service_account_key.terraform.public_key
    private_key        = yandex_iam_service_account_key.terraform.private_key
  })
}
