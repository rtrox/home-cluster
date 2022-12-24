// Configure the matchbox provider
provider "matchbox" {
  endpoint    = var.matchbox_rpc_endpoint
  client_cert = file("~/.matchbox/client.crt")
  client_key  = file("~/.matchbox/client.key")
  ca          = file("~/.matchbox/ca.crt")
}

terraform {
    required_providers {
        ct = {
            source  = "poseidon/ct"
            version = "0.11.0"
        }
        matchbox = {
            source  = "poseidon/matchbox"
            version = "0.5.2"
        }
    }
}

module "chongus" {
    source = "./modules/rke2_cluster"

    matchbox_http_endpoint = var.matchbox_http_endpoint

    machines = [
        {
            name = "node01",
            mac = "44:a8:42:3e:b9:27",
            ip = "172.18.2.1"
            install-device = "/dev/disk/by-id/ata-PNY_CS900_250GB_SSD_PNY2238220921011732D"
        },
        {
            name = "node02",
            mac = "b0:83:fe:cf:91:f7",
            ip = "172.18.2.2"
            install-device = "/dev/disk/by-id/ata-PNY_CS900_250GB_SSD_PNY22382209210117335"
        },
        {
            name = "node03",
            mac = "b0:83:fe:cf:d7:ee",
            ip = "172.18.2.3"
            install-device = "/dev/disk/by-id/ata-PNY_CS900_250GB_SSD_PNY2238220921011732E"
        }
    ]

    api_vip = "172.18.2.252"
    api_vip_iface = "eno1"
    # pod_cidr_v6 = "2001:470:e899:43::/52"
    # service_cidr_v6 = "2001:470:e899:44::/112"
    pod_cidr_v6 = "fd01::/52"
    service_cidr_v6 = "fd98::/112"
    rke2_token = "SUgK6pki1yzcdO40JmSGnzacN3KUrrmOm80Np2rgLyPXgVyG9ho8UtnhXNVKHKJl"
    cluster_name = "chongus"

    cluster_domain = "rtrox.com"

    ssh_authorized_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/PGRFPtotZqTnOcErult8kOch36EHPD/I5pPztI5g5KXgHz7DQ8aM3y/zWA1mckaFTH5YzlVieDV+c13UpPioCZN2uSDdXhN4L/CAv+Ox/n3z9PGTVATMecWpuPCwfrpHI3edBAPBt2+BLDDPQvSlXfhnL7VQbAj64txYklkUsRaOphz4qC21GpiDzmSjnCrdJsVd7lXrH53l97xT56FKq/bXV54HHK3yEwTIm+ZpzGJ8UMms7U0G6ErugX81TKAtO+qKbwRsatLGxFrWvuE5pPFgOlVBbhTaDalxW609jssBVxge2MbwGK27B0CYauUw7e9PCmxYgWbNKSnKsjoFGZQlUvrysR52x3QV1JH3qMQkJwKE9thFG8/b+vgraQyG+XT4lSg3RVhjOPiozYhUl37BTUn7uLSa8faEbBSzstAZsrc/8J8n/oBWVPmt+4uMMDMCx8pfexCDMrLz+0CsFSpsYwlvEpWkINky+i0jOivor1ZtwdNQBK4+t/oiXpzgmX18ucKaTfNtXOi8sdFQve72SwCsBgyZf+58jH1w043T0NhsjlhIl2frOF2Y3/86cBu0uoR7jrxbRNEA3sBn5pRC+VYu5gCTCHL2OHSmKxkiGbXQtyKR3eDJ+wqzWwMMolKOtWZWrhyy7DlIVaKZwV1GqYybmDizDJM0aJuatw=="
    ]
}

output "rke2-bootstrap-config" {
    value = module.chongus.rke2_bootstrap_config
    description = "RKE2 Config"
}

output "rke2-joiner-config" {
    value = module.chongus.rke2_joiner_config
    description = "RKE2 Config"
}

output "rke2-api-fqdn" {
    value = module.chongus.api_fqdn
    description = "RKE2 API FQDN"
}

output "rke2-api-vip" {
    value = module.chongus.api_vip
    description = "RKE2 API VIP"
}
