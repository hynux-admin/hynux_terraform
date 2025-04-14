provider "google" {
  project = "custom-altar-455808-t3"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# ✅ Create a Service Account for GKE Nodes
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# ✅ Grant IAM role to GKE Service Account
resource "google_project_iam_member" "gke_service_account_role" {
  project = "custom-altar-455808-t3"
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# ✅ GKE Cluster (Zonal)
resource "google_container_cluster" "gke_standard" {
  name     = "hynux-gke-cluster"
  location = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  # ✅ Logging and Monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # ✅ Private Cluster Configuration (optional, secure)
  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  release_channel {
    channel = "REGULAR"
  }
}

# ✅ Primary Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    disk_type    = "pd-balanced"
    service_account = google_service_account.gke_service_account.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "MODE_UNSPECIFIED"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}

# ✅ Optional: Special Node Pool (for high-memory or custom workloads)
resource "google_container_node_pool" "special_nodes" {
  name       = "special-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 0  # Start with zero nodes

  node_config {
    machine_type = "n1-highmem-2"
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    service_account = google_service_account.gke_service_account.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }
}
