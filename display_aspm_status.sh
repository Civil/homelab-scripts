#!/usr/bin/env bash

# Script checks and outputs if PCIe device supports ASPM and if it is enabled

sudo lspci -vvv 2>&1 | awk '
BEGIN{
	reset_color="\033[0m"
	not_supported_color="\033[31m" # Red
	disabled_color="\033[33m" # Yellow
	ok_color="\033[32m" # Green
}
{
	# Find PCI ID first, as we need PCI ID and device name.
	if ($1 ~ /^([0-9a-z][0-9a-z]:)+/) {id=$1; $1=""; dev=$0; next}
	# Get if device is ASPM-capable...
	if ($1 == "LnkCap:") {
		aspm_cap=$9
		for (i = 10; i <= $NF; i++) {
			if ($i == "Exit") {
				break
			}
			aspm_cap=aspm_cap "," $i
		}
		next
	}
	# Check what is actually enabled...
	if ($1 == "LnkCtl:") {
		aspm_status=$3

		color=ok_color
		if ($3 == "Disabled;") {
			if (aspm_cap == "not") { color=not_supported_color }
			else { color=disabled_color }
		} else {
			for (i = 4; i <= NF; i++) {
				if ($i == "Enabled;") {
					break
				}
				aspm_status=aspm_status "," $i
			}
		}
		print color"pci_id="id" device_name=\""dev"\" ASPM_CAP="aspm_cap" ASPM_STATUS="aspm_status reset_color
	}
}'
