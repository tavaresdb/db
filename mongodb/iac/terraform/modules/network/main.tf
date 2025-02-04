resource "google_compute_network" "network" {
  name                    = "my-custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.network.name
  region        = var.region
}

resource "google_compute_firewall" "rules_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags   = ["personal-project"]
}

resource "google_compute_firewall" "rules_ssh_iap" {
  name    = "allow-ssh-iap"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "rules_ssh_db" {
  name    = "allow-ssh-db"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_tags   = ["mongodb", "personal-project"]
  target_tags   = ["mongodb"]
}