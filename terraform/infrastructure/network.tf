locals {
  subnets = {
    a = {
      zone = "ru-central1-a"
      cidr = "10.10.10.0/24"
    }
    b = {
      zone = "ru-central1-b"
      cidr = "10.10.20.0/24"
    }
    d = {
      zone = "ru-central1-d"
      cidr = "10.10.30.0/24"
    }
  }

  cluster_ipv4_range = "10.20.0.0/16"
  service_ipv4_range = "10.30.0.0/16"
}

resource "yandex_vpc_network" "main" {
  name        = var.project_name
  description = "Network for the diploma Kubernetes cluster"
}

resource "yandex_vpc_subnet" "public" {
  for_each = local.subnets

  name           = "${var.project_name}-${each.key}"
  description    = "Public subnet for Kubernetes resources in ${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
}
