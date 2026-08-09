resource "yandex_vpc_security_group" "cluster_node_traffic" {
  name        = "${var.project_name}-cluster-node-traffic"
  description = "Service traffic shared by the Kubernetes control plane and worker nodes"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description       = "Network Load Balancer health checks"
    from_port         = 0
    to_port           = 65535
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "Control plane and worker node communication"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "Node health checks from private cloud networks"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    description       = "Control plane and worker node communication"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}

resource "yandex_vpc_security_group" "cluster_api" {
  name        = "${var.project_name}-cluster-api"
  description = "Public Kubernetes API and control plane egress"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description    = "Kubernetes API over HTTPS"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = var.api_access_cidrs
  }

  ingress {
    description    = "Kubernetes API"
    port           = 6443
    protocol       = "TCP"
    v4_cidr_blocks = var.api_access_cidrs
  }

  egress {
    description    = "Control plane access to pods and admission webhooks"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = [local.cluster_ipv4_range]
  }

  egress {
    description    = "Control plane access to NTP"
    port           = 123
    protocol       = "UDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "node_traffic" {
  name        = "${var.project_name}-node-traffic"
  description = "Pod, service and outbound traffic for worker nodes"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description    = "Pod and service traffic"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = [local.cluster_ipv4_range, local.service_ipv4_range]
  }

  egress {
    description    = "Worker access to registries and external services"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "services" {
  name        = "${var.project_name}-services"
  description = "External access to Kubernetes NodePort services"
  network_id  = yandex_vpc_network.main.id

  ingress {
    description    = "Kubernetes NodePort range"
    from_port      = 30000
    to_port        = 32767
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
