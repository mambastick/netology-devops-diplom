resource "yandex_kubernetes_cluster" "main" {
  name        = var.project_name
  description = "Regional Managed Kubernetes cluster for the diploma project"
  network_id  = yandex_vpc_network.main.id

  cluster_ipv4_range = local.cluster_ipv4_range
  service_ipv4_range = local.service_ipv4_range

  master {
    version = var.kubernetes_version

    regional {
      region = "ru-central1"

      dynamic "location" {
        for_each = yandex_vpc_subnet.public
        content {
          zone      = location.value.zone
          subnet_id = location.value.id
        }
      }
    }

    public_ip = true
    security_group_ids = [
      yandex_vpc_security_group.cluster_node_traffic.id,
      yandex_vpc_security_group.cluster_api.id,
    ]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "sunday"
        start_time = "01:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.kubernetes_service_account_id
  node_service_account_id = var.kubernetes_service_account_id
  release_channel         = "STABLE"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kubernetes.id
  }

  labels = {
    project = var.project_name
    purpose = "netology-diplom"
  }

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}

resource "yandex_kubernetes_node_group" "workers" {
  cluster_id  = yandex_kubernetes_cluster.main.id
  name        = "${var.project_name}-workers"
  description = "Preemptible worker nodes distributed across three availability zones"
  version     = var.kubernetes_version

  instance_template {
    name        = "${var.project_name}-worker-{instance.zone_id}-{instance.index_in_zone}"
    platform_id = "standard-v3"

    network_interface {
      nat        = true
      subnet_ids = [for subnet in yandex_vpc_subnet.public : subnet.id]
      security_group_ids = [
        yandex_vpc_security_group.cluster_node_traffic.id,
        yandex_vpc_security_group.node_traffic.id,
        yandex_vpc_security_group.services.id,
      ]
    }

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.worker_node_count
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.public
      content {
        zone = location.value.zone
      }
    }
  }

  deploy_policy {
    max_expansion   = 1
    max_unavailable = 1
  }

  maintenance_policy {
    auto_repair  = true
    auto_upgrade = true

    maintenance_window {
      day        = "sunday"
      start_time = "04:00"
      duration   = "3h"
    }
  }

  node_labels = {
    project = var.project_name
  }

  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}
