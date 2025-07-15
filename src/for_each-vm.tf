#считываем данные об образе ОС
data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}

variable "each_vm" {
    type = list(object({
      vm_name = string
      cpu = number
      disk_volume = number
      fraction = number
    }))
    default = [ {
      vm_name = "main"
      cpu = 2
      disk_volume = 1
      fraction = 5
    },
    {
        vm_name = "replica"
        cpu = 4
        disk_volume = 2
        fraction = 5
    } ]
}


resource "yandex_compute_instance" "for_each" {
    for_each   = {for i in var.each_vm: "${i.vm_name}" => i}
    name       = each.value.vm_name
    hostname   = each.value.vm_name
    platform_id = "standard-v1"

    resources {
      cores = each.value.cpu
      memory = each.value.disk_volume
      core_fraction = each.value.fraction
    }
    boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
    }
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = local.ssh_keys
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
        yandex_vpc_security_group.example.id
    ]
  }
  allow_stopping_for_update = true
}