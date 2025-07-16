resource "yandex_compute_disk" "vm_disks" {
    name = "disk-${count.index + 1}"
    type = "network-hdd"
    size = 1
    count = 3
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
    cores = var.storage_resources.cores
    memory = var.storage_resources.memory
    core_fraction = var.storage_resources.core_fraction
  }

  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  dynamic "secondary_disk" {
   for_each = yandex_compute_disk.vm_disks.*.id
   content {
     disk_id = secondary_disk.value
   }
  }
  network_interface {
     subnet_id = yandex_vpc_subnet.develop.id
     nat     = true
  }

  metadata = var.metadata
}

