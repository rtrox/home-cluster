// Install Profile
resource "matchbox_profile" "flatcar-install" {
    count  = length(var.machines)
    name   = "flatcar-install-${var.machines[count.index].name}"
    kernel = "http://stable.release.flatcar-linux.net/amd64-usr/3374.2.0/flatcar_production_pxe.vmlinuz"
    initrd = [
        "http://stable.release.flatcar-linux.net/amd64-usr/3374.2.0/flatcar_production_pxe_image.cpio.gz",
    ]

    args = [
        "initrd=flatcar_production_pxe_image.cpio.gz",
        "flatcar.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
        "flatcar.first_boot=yes",
    ]

    raw_ignition = data.ct_config.install[count.index].rendered
}

data "ct_config" "install" {
    count = length(var.machines)
    content = templatefile("${path.module}/butane/flatcar-install.yaml", {
        matchbox_http_endpoint = var.matchbox_http_endpoint
        ssh_authorized_keys     = jsonencode(var.ssh_authorized_keys)
        install_device         = var.install_device
        node_name              = var.machines[count.index].name
    })
    strict = true
}

// Worker Profiles
// TODO: need to pull out initial node for bootstrap
resource "matchbox_profile" "worker" {
    count        = length(var.machines)
    name         = "worker-${var.machines[count.index].name}"
    raw_ignition = data.ct_config.worker[count.index].rendered
}

data "ct_config" "worker" {
    count = length(var.machines)
    content = templatefile("${path.module}/butane/flatcar.yaml", {
        ssh_authorized_keys = jsonencode(var.ssh_authorized_keys)
        node_name = var.machines[count.index].name
        cluster_fqdn = local.cluster_fqdn
        bootstrap = count.index == 0 ? true : false
        k3s_token = var.k3s_token
        k3s_config = data.template_file.k3s-config.rendered
        cilium_install = data.template_file.cilium-install.rendered
        api_vip = var.api_vip
        api_vip_iface = var.api_vip_iface
        kube_vip = data.template_file.kube-vip[count.index].rendered
    })
    strict = true
}

data "template_file" "kube-vip" {
    count = length(var.machines)
    template = file("${path.module}/templates/kube-vip.yaml")
    vars = {
        api_vip = var.api_vip
        api_vip_iface = var.api_vip_iface
        router_id = var.machines[count.index].ip
        cluster_domain = local.cluster_fqdn
    }
}

data "template_file" "k3s-config" {
    template = file("${path.module}/templates/k3s-config.yaml")
    vars = {
        api_vip = var.api_vip
        api_fqdn = local.api_fqdn
    }
}

data "template_file" "cilium-install" {
    template = file("${path.module}/templates/cilium-install.yaml")
    vars = {
        api_vip = var.api_vip
        cluster_name = var.cluster_name
    }
}

// Install Group
resource "matchbox_group" "flatcar-install" {
    count = length(var.machines)
    name  = "flatcar-install-${var.machines[count.index].name}"
    profile= matchbox_profile.flatcar-install[count.index].name

    selector = {
        mac = var.machines[count.index].mac
    }
}

// Worker Group
resource "matchbox_group" "worker" {
    count = length(var.machines)
    name  = "worker-${var.machines[count.index].name}"
    profile = matchbox_profile.worker[count.index].name

    selector = {
        os = "installed"
        node = var.machines[count.index].name
    }
}

locals {
    cluster_fqdn = "${substr(var.cluster_name, 0, 3)}.${var.cluster_domain}"
    api_fqdn = "api.${local.cluster_fqdn}"
}
