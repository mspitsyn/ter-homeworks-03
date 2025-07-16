resource "local_file" "hosts_cfg" {
    
    filename = "${abspath(path.module)}/hosts.cfg"
    content = templatefile(
        "${path.module}/hosts.tftpl",
      {
        webservers = yandex_compute_instance.example
        databases = yandex_compute_instance.for_each
        storage = [ yandex_compute_instance.storage ]
      }
    )
}