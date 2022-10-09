# NOTES

## Sidero
Sidero Metal is a PXE boot environment for installing Talos, a security first Kubernetes Distribution.

[Installing Sidero on a Raspberry Pi 4](https://www.sidero.dev/v0.5/guides/sidero-on-rpi4/)

In the instructions, the Sidero Install step failed when I did this, I needed to follow these instructions, taken from [here](https://www.sidero.dev/v0.5/getting-started/install-clusterapi/).


> Note: If you encounter the following error, this is caused by a rename of our GitHub org from talos-systems to siderolabs.

```
$ clusterctl init -b talos -c talos -i sidero
Fetching providers
Error: failed to get provider components for the "talos" provider: target namespace can't be defaulted. Please specify a target namespace
```
> This can be worked around by adding the following to ~/.cluster-api/clusterctl.yaml and rerunning the init command:
```
providers:
  - name: "talos"
    url: "https://github.com/siderolabs/cluster-api-bootstrap-provider-talos/releases/latest/bootstrap-components.yaml"
    type: "BootstrapProvider"
  - name: "talos"
    url: "https://github.com/siderolabs/cluster-api-control-plane-provider-talos/releases/latest/control-plane-components.yaml"
    type: "ControlPlaneProvider"
  - name: "sidero"
    url: "https://github.com/siderolabs/sidero/releases/latest/infrastructure-components.yaml"
    type: "InfrastructureProvider"
```
### Accepting a server
In Sidero, a server must be accepted before it can be provisioned. If it's not accepted, sidero will do nothing to it. Once accepted, it will be immediately wiped, and it will be made available for provisioning to a cluster.
```bash
 kubectl patch server e5d4686c-23df-1631-71e1-1c697a6e861f --type='json' -p='[{"op": "add", "path": "/spec/accepted", "value": true}]'
```
### Labeling Servers as controlplane
We're using `ServerClasses` to put nodes into groups for each cluster by hardware type. For controlplane, we're using a label selector. To label a server:
```bash
kubectl label server 5265c900-2516-11e7-9ea4-f8fe6d592f00 controlplane=true
```

### Server Specific Changes
For right now, you can only specific one `ServerClass` for Workers, and one for Control Plane. As such, it's tough to override settings for specific servers (but not impossible). When you need to do this, edit the server object directly. Our NUC, for example, needs to be told to install to the nvme drive:
```yaml
spec:
  accepted: true
  configPatches:
  - op: replace
    path: /machine/install/disk
    value: /dev/nvme0n1
```
I applied this via `kubectl edit server <id>`, but you can also built and apply a patch file.

### Collecting TalosConfig
   ```bash
   # Retrieve the TalosConfig from the Sidero Cluster
   kubectl get secret x86-talosconfig -o jsonpath='{.data.talosconfig}' | base64 -d > x86-talosconfig
   # Merge the new talos config into our local talos config
   talosctl config merge x86-talosconfig
   # By default, no nodes are specified, add all our nodes
   talosctl config node 172.16.2.1 172.16.2.2 172.16.2.3 172.16.2.4 172.16.2.6
```

### Retrieving KubeConfig
Using your new TalosConfig:
```bash
talosctl -n 172.16.2.1 kubeconfig
```
no need to adjust endpoint, it uses the one we specified in our ClusterConfig.

## Bootstrapping Work Cluster
1. Delete & Recreate Talos Cluster
```bash
kubectx admin@rpi4-sidero
kubectl delete cluster x86
kubectl apply -f provision/clusters/x86-cluster/x86-cluster.yaml
```
2. Collect TalosConfig & KubeConfig as outlined above
3. reapply sops-age secret
```bash
sops -d cluster-cd/clusters/x86/sops-age.x86.yaml | kubectl apply -f -
```
4. Rebootstrap cluster from this repo using [Flux's Instructions](https://fluxcd.io/flux/installation/#github-and-github-enterprise)
```bash
export GITHUB_TOKEN=<personal-access-token>
flux bootstrap github \
  --owner=rtrox \
  --repository=home-cluster \
  --path=cluster-cd/clusters/x86 \
  --personal \
  --reconcile
```

## CNI Setup Hack
I need to find a better way to do this, but right now, this is a little hacky. Since we're installing Cilium during the install, it's already present on the machine, but without all the proper configs (quick install is stripped down to prevent leaking certificates via this repo). In gitops, there is a helm chart which deploys cilium with all the right options. This is done because the Talos docs say that the talos machines will reboot every 10 minutes if the nodes don't become `Ready`, and `Ready` state relies on an initialized CNI.  So once Flux is bootstrapped, it's necessary to:
1. Uninstall Cilium
```bash
cilium uninstall
```
2. The Helm Chart likely failed to deploy due to resources with the same name already being present, so delete the helm release:
```bash
flux delete hr -n kube-system cilium
```
3. Trigger a reconcile
```
flux reconcile kustomization system
```

# Network

## Management
172.16.254.1 Router
172.16.254.2 CloudKey
172.16.254.3 Sidero

172.16.254.11 NAS
172.16.254.21 Ender3

## Cluster IPs
172.16.1.0/24 Pi Cluster
172.16.2.0/24 ThinkKube
172.16.3.0/24 Rockkube

## Loadbalancers
172.17.1.0/24 Pi Load Balancers
172.17.2.0/24 ThinkKube Load Balancers
172.17.3.0/24 Rockkube Load Balancers

# Ingresses
