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

  remove_default_node_pool = true  # This is allowed only when Autopilot is disabled
  enable_autopilot         = false # Ensuring it's a Standard GKE cluster

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}
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
    preemptible  = false
    auto_repair  = true
    auto_upgrade = true
  }
}
