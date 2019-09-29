##This terraform file creates k8s mutli-zonal cluster 
##using a multi-zonal cluster, additional_zones should not contain the original 'zone'

# Terraform file
terraform {
  # version of  terraform
  required_version = "~>0.11.7"
}


resource "google_container_cluster" "reddit-cluster" {
  name     = "${var.app}-cluster"
  location = "${var.zone}"
  node_locations = [
#    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c"
  ]

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true

  network  = "default"
  initial_node_count = "${var.initial_node_count}"


# Enable the Kubernetes Dashboard for this cluster
  addons_config {
    kubernetes_dashboard {
      disabled = false
    }

# Disable Horizontal Pod Autoscaling 
    horizontal_pod_autoscaling {
      disabled = true             # change to false to enable autoscaling
    }
  }

  master_auth {
    username = "${var.username}"
    password = "${var.psw}"

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "cluster_preemptible_nodes" {
  name               = "${var.app}-node-pool"
  location           = "${var.zone}"
  cluster            = "${google_container_cluster.reddit-cluster.name}"
  node_count         = "${var.min_node_count}"

  autoscaling {
    min_node_count   = "${var.min_node_count}"
    max_node_count   = "${var.max_node_count}"
  }

  management {     
    auto_repair      = "true"
    auto_upgrade     = "true"
  }


  node_config {
    preemptible      = true
    machine_type     = "${var.machine_type}"
    disk_size_gb     = "${var.disk_size}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Needed for correctly functioning cluster, see 
    # https://www.terraform.io/docs/providers/google/r/container_cluster.html#oauth_scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}

resource "google_compute_address" "k8s-external-ip" {
  name = "kubernetes-cluster-ip"
}


# Firewall rules for access  
resource "google_compute_firewall" "fw_cluster_reddit" {
  name          = "allow-cluster-vip"
  network       = "default"
  allow {
    protocol    = "tcp"
    ports       = ["30000-32767"]
  }
  source_ranges = ["0.0.0.0/0"]
}

