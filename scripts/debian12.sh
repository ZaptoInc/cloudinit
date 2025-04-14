#!/bin/bash

source /etc/cloudinit/variables.sh

CI_IMAGE_NAME="debian-12-genericcloud-amd64.raw"

DownloadImage() {
    mkdir -p "$CI_TEMPLATE_DIR"
    wget -O "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"
}

if [[ ! -e "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" || "$CI_UPDATE_OS" -eq 1 ]]; then
    DownloadImage
fi

CI_ROOT_PASSWORD_HASH=$(openssl passwd -6 "$CI_ROOT_PASSWORD")
CI_USER_PASSWORD_HASH=$(openssl passwd -6 "$CI_USER_PASSWORD")

echo "Creating VM ${CI_VM_NAME} with ID ${CI_VM_ID}"
# Creating VM
qm create ${CI_VM_ID} --name "${CI_VM_NAME}" --memory ${CI_RAM_MB} --sockets 1 --cores ${CPU} --net0 virtio,bridge=${CI_NETWORK_BRIDGE}
# Importing disk
qm importdisk ${CI_VM_ID} "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" "$CI_STORAGE"
# Configuring type of disk
qm set ${CI_VM_ID} --scsihw virtio-scsi-pci --scsi0 "${CI_STORAGE}:vm-${CI_VM_ID}-disk-0"
# Rezising disk
qm resize ${CI_VM_ID} scsi0 ${CI_DISK}
# Cloudinit disk
qm set ${CI_VM_ID} --ide2 "$CI_STORAGE:cloudinit"
# Networking
qm set ${CI_VM_ID} --ipconfig0 ip=${CI_IP_ADDRESS},gw=${CI_GATEWAY}
qm set ${NEW_VM_ID} --nameserver "${CI_DNS}"

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