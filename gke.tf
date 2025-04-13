provider "google" {
  project = "custom-altar-455808-t3"  # 🔹 Your GCP Project ID
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Zonal GKE Cluster
resource "google_container_cluster" "gke_standard" {
  name     = "my-gke-cluster"
  location = "us-central1-c"  # ✅ Zonal instead of regional

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}
}

# Node Pool with Balanced Persistent Disk
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1-c"  # ✅ Same zone as cluster
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1  # ✅ Single node setup

  node_config {
    machine_type = "e2-small"        # ✅ Cost-effective VM
    disk_size_gb = 10                # ✅ Minimum allowed
    disk_type    = "pd-balanced"     # ✅ Uses zonal SSD quota
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
