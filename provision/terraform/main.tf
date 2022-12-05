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
  source = "./modules/k3s_cluster"

  matchbox_http_endpoint = var.matchbox_http_endpoint

  machines = [
      {
          name = "node01",
          mac = "44:a8:42:3e:b9:27"
      },
      {
          name = "node02",
          mac = "b0:83:fe:cf:91:f7"
      },
      {
          name = "node03",
          mac = "b0:83:fe:cf:d7:ee"
      }

  ]

  k3s_token = "SUgK6pki1yzcdO40JmSGnzacN3KUrrmOm80Np2rgLyPXgVyG9ho8UtnhXNVKHKJl"
  cluster_name = "chongus"

  cluster_domain = "rtrox.com"

  ssh_authorized_keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/PGRFPtotZqTnOcErult8kOch36EHPD/I5pPztI5g5KXgHz7DQ8aM3y/zWA1mckaFTH5YzlVieDV+c13UpPioCZN2uSDdXhN4L/CAv+Ox/n3z9PGTVATMecWpuPCwfrpHI3edBAPBt2+BLDDPQvSlXfhnL7VQbAj64txYklkUsRaOphz4qC21GpiDzmSjnCrdJsVd7lXrH53l97xT56FKq/bXV54HHK3yEwTIm+ZpzGJ8UMms7U0G6ErugX81TKAtO+qKbwRsatLGxFrWvuE5pPFgOlVBbhTaDalxW609jssBVxge2MbwGK27B0CYauUw7e9PCmxYgWbNKSnKsjoFGZQlUvrysR52x3QV1JH3qMQkJwKE9thFG8/b+vgraQyG+XT4lSg3RVhjOPiozYhUl37BTUn7uLSa8faEbBSzstAZsrc/8J8n/oBWVPmt+4uMMDMCx8pfexCDMrLz+0CsFSpsYwlvEpWkINky+i0jOivor1ZtwdNQBK4+t/oiXpzgmX18ucKaTfNtXOi8sdFQve72SwCsBgyZf+58jH1w043T0NhsjlhIl2frOF2Y3/86cBu0uoR7jrxbRNEA3sBn5pRC+VYu5gCTCHL2OHSmKxkiGbXQtyKR3eDJ+wqzWwMMolKOtWZWrhyy7DlIVaKZwV1GqYybmDizDJM0aJuatw=="
  ]

  install_device = "/dev/sda"
}
