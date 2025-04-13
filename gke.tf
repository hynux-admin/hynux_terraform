provider "google" {
  project = "custom-altar-455808-t3"  # 🔹 Your GCP Project ID
  region  = "us-central1"
  zone    = "us-central1-c"  # 🔹 Zonal setup (you can switch to regional if needed)
}

# Create GKE Cluster with best practices for organizations
resource "google_container_cluster" "gke_standard" {
  name               = "hynux-gke-cluster"
  location           = "us-central1-c"  # ✅ Zonal (or you can set this to a regional cluster)
  remove_default_node_pool = true
  initial_node_count  = 1  # Initial node count before the node pool is created

  networking_mode     = "VPC_NATIVE"  # VPC-native for networking
  ip_allocation_policy {}

  # Enable GKE Cluster Autoscaler
  enable_autoscaling = true
  min_master_version = "latest"

  # Enable features like workload identity and private clusters
  private_cluster_config {
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  # Logging and monitoring (default enabled)
  enable_logging        = true
  enable_monitoring     = true
}

# Node Pool for General Workloads
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "us-central1-c"  # Same zone as the cluster
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1

  node_config {
    machine_type  = "e2-medium"         # ✅ More powerful, cost-effective nodes
    disk_size_gb = 10                  # ✅ 10 GB Balanced Persistent Disk
    disk_type    = "pd-balanced"       # ✅ Balanced disk type for cost-efficiency
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Enable GKE's internal workload identity support (optional)
    workload_metadata_config {
      node_metadata = "GKE_METADATA"
    }
  }

  # Autoscaler (to automatically scale nodes based on demand)
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}

# Optionally: Create another node pool for special workloads (GPU, high-memory, etc.)
resource "google_container_node_pool" "special_nodes" {
  name       = "special-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 0  # No nodes initially

  node_config {
    machine_type  = "n1-highmem-2"  # For higher memory usage
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Autoscaler for this special pool (expand for specialized workloads if needed)
  autoscaling {
    min_node_count = 0  # Start with 0 nodes and scale on-demand
    max_node_count = 5
  }
}

# Create IAM roles and service account if needed
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_service_account_role" {
  role   = "roles/container.clusterViewer"
  member = "serviceAccount:${google_service_account.gke_service_account.email}"
}

