provider "google" {
  project = "custom-altar-455808-t3"  # 🔹 Replace with your GCP Project ID
  region  = "us-central1"
}

# 🔹 Reserve a Static IP Address
resource "google_compute_address" "static_ip" {
  name   = "hynux-static-ip"
  region = "us-central1"
}

# 🔹 Create the VM Instance
resource "google_compute_instance" "hynux" {
  name         = "hynux"
  machine_type = "e2-micro"  # 🔹 Small, free-tier eligible
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20               # 🔹 20GB Balanced Disk
      type  = "pd-balanced"    # 🔹 Balanced SSD
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static_ip.address  # 🔹 Assign the reserved static IP
    }
  }
}
