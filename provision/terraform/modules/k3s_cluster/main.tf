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
        cluster_name = var.cluster_name
        cluster_domain = var.cluster_domain
        bootstrap = count.index == 0 ? true : false
        k3s_token = var.k3s_token
        k3s_config = file("${path.module}/templates/k3s_config.yaml")
    })
    strict = true
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
