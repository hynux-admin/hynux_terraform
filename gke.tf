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

  enable_autopilot = false  # Standard Cluster Mode

  # IP allocation for VPC-native networking
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  initial_node_count = 1  # FIX: Set to 1 to avoid the error
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
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
