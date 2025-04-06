terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "custom-altar-455808-t3"
  region  = "us-central1"
}

resource "google_container_cluster" "gke_standard" {
  name     = "gke-standard-cluster"
  location = "us-central1"

  enable_autopilot = false

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  initial_node_count = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1

  node_config {
    machine_type = "e2-small"  # 🔹 Changed from e2-medium to e2-small to reduce resource usage
    disk_size_gb = 20          # 🔹 Reduced disk size from 50GB to 20GB to fit within quota
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
