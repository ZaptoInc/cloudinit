#!/bin/bash

source /etc/cloudinit/variables.sh

CI_IMAGE_NAME="debian-12-genericcloud-amd64.raw"

echo "TODO"

DownloadImage() {
    mkdir -p "$CI_TEMPLATE_DIR"
    wget -O "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"
}

if [[ ! -e "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" || "$CI_UPDATE_OS" -eq 1 ]]; then
    DownloadImage
fi

echo "CI_VM_ID: $CI_VM_ID"
echo "CI_VM_NAME: $CI_VM_NAME"
echo "CI_OS_NAME: $CI_OS_NAME"
echo "CI_OS_SCRIPT: $CI_OS_SCRIPT"
echo "CI_CPU: $CI_CPU"
echo "CI_RAM: $CI_RAM"
echo "CI_RAM_MB: $CI_RAM_MB"
echo "CI_DISK: $CI_DISK"
echo "CI_CHOICE: $CI_CHOICE"
echo "CI_NETWORK: $CI_NETWORK"
echo "CI_CIDR: $CI_CIDR"
echo "CI_IP_ADDRESS: $CI_IP_ADDRESS"