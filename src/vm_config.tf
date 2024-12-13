provider "google" {
  project = "elfin-project"
  region  = "us-central1"
}

resource "google_compute_instance" "nginx_vm" {
  name         = "nginx-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}