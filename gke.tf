provider "google" {
  project = "custom-altar-455808-t3"  # Replace with your GCP Project ID
  region  = "us-central1"
}

resource "google_container_cluster" "gke_standard" {
  name     = "my-gke-cluster"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1  # Required but won't create default nodes

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1  

  node_config {
    machine_type = "e2-small"  # Small instance to fit quotas
    disk_size_gb = 20          # ✅ Reduced to fit within your 250 GB quota
    disk_type    = "pd-ssd"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
