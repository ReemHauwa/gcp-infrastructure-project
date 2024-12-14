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

# Add these to your existing configuration

# Enable Cloud Monitoring
resource "google_monitoring_alert_policy" "vm_cpu_alert" {
  display_name = "VM CPU Utilization Alert"
  combiner     = "AND"
  conditions {
    display_name = "VM CPU Utilization"
    condition_threshold {
      filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.80 # 80% CPU usage
      duration        = "60s"
    }
  }

  # Note: You'll need to configure a notification channel separately
}

# Create a Managed Instance Group for Auto-scaling
resource "google_compute_instance_group_manager" "web_server_group" {
  name = "web-server-group"

  base_instance_name = "nginx-server"
  zone               = "us-central1-a"

  version {
    instance_template = google_compute_instance_template.nginx_template.id
  }
}

# Create an Instance Template
resource "google_compute_instance_template" "nginx_template" {
  name        = "nginx-server-template"
  description = "Template for Nginx servers"

  machine_type = "e2-micro"

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  # Startup script to install Nginx
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF

  tags = ["http-server"]
}

# Add Auto-scaler
resource "google_compute_autoscaler" "web_server_autoscaler" {
  name   = "web-server-autoscaler"
  zone   = "us-central1-a"
  target = google_compute_instance_group_manager.web_server_group.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6 # Scales when CPU hits 60%
    }
  }
}

# Enhance Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}