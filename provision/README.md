# Provisioning New Clusters

## Sidero

Sidero Directory contains the x86 cluster's definition (in [clusters](./sidero/clusters). Provisioning a new cluster just requires copying and editing this directory, and then applying the manifests to the rpi4-sidero cluster. Then follow steps in NOTES.md to actually provision to the nodes.

## Terraform

Terraform Directory contains the terraform definitions for Matchbox for the chongus cluster. Provisioning uses normal terraform tools.
