resource "google_compute_instance" "instances" {
  count         = var.count
  name          = "${var.instance_name_prefix}-${count.index + 1}"
  zone          = var.zones[count.index % length(var.zones)]
  machine_type  = var.machine_type
  instance_tags = var.instance_tags

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20241210"
    }
  }

  dynamic "attached_disk" {
    for_each = var.additional_disk ? [1] : []
    content {
      source      = google_compute_disk.additional_disk[count.index].id
      device_name = google_compute_disk.additional_disk[count.index].name
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata = {
    ssh-keys = var.ssh_keys
  }

  metadata_startup_script = var.startup_script != "" ? file(var.startup_script) : null
}

resource "google_compute_disk" "additional_disk" {
  count = var.additional_disk ? var.count : 0
  name  = "${var.instance_name_prefix}-disk-${count.index + 1}"
  type  = "pd-ssd"
  zone  = var.zones[count.index % length(var.zones)]
  size  = var.additional_disk_size
}