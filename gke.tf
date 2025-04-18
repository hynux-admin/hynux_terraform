provider "google" {
  project = "keen-petal-457212-c4"
  region  = "asia-east1"
  zone    = "asia-east1-a"
}

# ✅ Custom VPC with max subnet ranges
resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "asia-east1"
  network       = google_compute_network.vpc_network.id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# ✅ GKE Service Account
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# ✅ IAM role for the service account
resource "google_project_iam_member" "gke_service_account_role" {
  project = "keen-petal-457212-c4"
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# ✅ GKE Private Cluster
resource "google_container_cluster" "gke_standard" {
  name                     = "hynux-gke-cluster"
  location                 = "asia-east1-a"
  network                  = google_compute_network.vpc_network.id
  subnetwork               = google_compute_subnetwork.gke_subnet.id
  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode          = "VPC_NATIVE"
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  release_channel {
    channel = "REGULAR"
  }
}

# ✅ Primary Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "asia-east1-a"
  cluster    = google_container_cluster.gke_standard.name
  node_count = 1

  node_config {
    machine_type    = "e2-standard-4"
    disk_size_gb    = 100
    disk_type       = "pd-balanced"
    service_account = google_service_account.gke_service_account.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}
