provider "google" {
  project = "custom-altar-455808-t3"  # 🔹 Replace with your GCP Project ID
  region  = "us-central1"
}

# GKE Cluster (no default node pool)
resource "google_container_cluster" "gke_standard" {
  name     = "my-gke-cluster"
  location = "us-central1"

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}
}

# Node Pool with 1 Node and Balanced Persistent Disk
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1  # ✅ Single node

  node_config {
    machine_type = "e2-small"        # ✅ Budget-friendly VM
    disk_size_gb = 10                # ✅ Minimum allowed
    disk_type    = "pd-balanced"     # ✅ Balanced Persistent Disk
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
