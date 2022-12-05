output "api_fqdn"{
    value = local.api_fqdn
    description = "Kubernetes API FQDN"
}

output "api_vip" {
    value = var.api_vip
    description = "Kubernetes API VIP"
}

output "k3s_config" {
    value = data.template_file.k3s-config.rendered
    description = "K3s config"
}