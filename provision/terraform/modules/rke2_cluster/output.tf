output "api_fqdn"{
    value = local.api_fqdn
    description = "Kubernetes API FQDN"
}

output "api_vip" {
    value = var.api_vip
    description = "Kubernetes API VIP"
}

output "rke2_bootstrap_config" {
    value = data.template_file.rke2-config[0].rendered
    description = "RKE Bootstrap Node config"
}

output "rke2_joiner_config" {
    value = data.template_file.rke2-config[1].rendered
    description = "RKE First Joiner Node config"
}
