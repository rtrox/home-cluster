
variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

variable "machines" {
  type = list(object({
    name = string
    mac  = string
    ip = string
  }))
  description = "List of machines to provision"
}

variable "k3s_token" {
    type        = string
    description = "K3s token to use for cluster"
}

variable "cluster_name" {
    type = string
    description = "Name of the cluster"
}

variable "cluster_domain" {
    type = string
    description = "Domain of the cluster"
}

variable "ssh_authorized_keys" {
    type = list(string)
    description = "SSH public keys to set as an authorized_key on machines"
}

variable "install_device" {
    type = string
    description = "Device to install Flatcar on"
}

variable "api_vip" {
    type = string
    description = "VIP for Kubernetes API"
}

variable "api_vip_iface" {
    type = string
    description = "VIP Interface for Kubernetes API"
}
