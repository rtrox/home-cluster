FROM ghcr.io/siderolabs/installer:v1.3.0-alpha.2-64-g9a5f4c08a
COPY --from=ghcr.io/rtrox/kernel:v1.4.0-alpha.0-5-g165dff6 /boot/vmlinuz /usr/install/${TARGETARCH}/vmlinuz
COPY --from=ghcr.io/rtrox/nonfree-kmod-nvidia:v1.4.0-alpha.0-5-g165dff6 /lib/modules /lib/modules
