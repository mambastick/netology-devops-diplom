output "network_id" {
  description = "VPC network ID"
  value       = yandex_vpc_network.main.id
}

output "subnets" {
  description = "Public subnets used by the cluster"
  value = {
    for key, subnet in yandex_vpc_subnet.public : key => {
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.v4_cidr_blocks[0]
    }
  }
}

output "kubernetes_cluster_id" {
  description = "Managed Kubernetes cluster ID"
  value       = yandex_kubernetes_cluster.main.id
}

output "kubernetes_external_endpoint" {
  description = "Public Kubernetes API endpoint"
  value       = yandex_kubernetes_cluster.main.master[0].external_v4_endpoint
}

output "worker_node_group_id" {
  description = "Worker node group ID"
  value       = yandex_kubernetes_node_group.workers.id
}

output "container_registry_id" {
  description = "Container Registry ID"
  value       = yandex_container_registry.main.id
}

output "container_registry_url" {
  description = "Container Registry path prefix"
  value       = "cr.yandex/${yandex_container_registry.main.id}"
}

output "get_credentials_command" {
  description = "Command that configures kubectl access"
  value       = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.main.id} --external --force"
}
