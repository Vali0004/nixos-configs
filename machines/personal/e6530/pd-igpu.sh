#!/usr/bin/env bash
# move the HD 4000 (00:02.0) between the host's i915 and vfio-pci for PD VMs
set -euo pipefail

dev=0000:00:02.0
sys=/sys/bus/pci/devices/$dev

usage() {
	echo "usage: pd-igpu vfio|host|status|rom <file>" >&2
	exit 2
}

driver() {
	basename "$(readlink -f "$sys/driver" 2>/dev/null)" 2>/dev/null || echo none
}

# the text console sits on i915's framebuffer, release it before unbinding
consoles() {
	for vt in /sys/class/vtconsole/vtcon*; do
		grep -q "frame buffer" "$vt/name" && echo "$1" > "$vt/bind"
	done
	return 0
}

case "${1:-}" in
vfio)
	[ "$(driver)" = vfio-pci ] && { echo "already on vfio-pci"; exit 0; }
	modprobe vfio-pci
	consoles 0
	[ "$(driver)" != none ] && echo "$dev" > "$sys/driver/unbind"
	echo vfio-pci > "$sys/driver_override"
	echo "$dev" > /sys/bus/pci/drivers/vfio-pci/bind
	echo "00:02.0 now on $(driver)"
	;;
host)
	[ "$(driver)" = i915 ] && { echo "already on i915"; exit 0; }
	[ "$(driver)" != none ] && echo "$dev" > "$sys/driver/unbind"
	echo > "$sys/driver_override"
	modprobe i915
	echo "$dev" > /sys/bus/pci/drivers/i915/bind
	# fbcon oopses rebinding to an i915 with no lit display, a guest can leave it dark
	if grep -qx connected /sys/class/drm/card*-*/status 2>/dev/null; then
		consoles 1
	else
		echo "no connected display after the guest, console left unbound"
	fi
	echo "00:02.0 now on $(driver)"
	;;
status)
	echo "00:02.0 driver: $(driver)"
	echo "iommu group: $(basename "$(readlink -f "$sys/iommu_group")")"
	;;
rom)
	# the VGA BIOS the firmware shadowed, for qemu's romfile=
	[ -n "${2:-}" ] || usage
	echo 1 > "$sys/rom"
	cat "$sys/rom" > "$2"
	echo 0 > "$sys/rom"
	ls -l "$2"
	;;
*)
	usage
	;;
esac
