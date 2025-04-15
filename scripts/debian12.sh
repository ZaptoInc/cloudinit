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
echo "qm create ${CI_VM_ID} --name ${CI_VM_NAME} --memory ${CI_RAM_MB} --sockets 1 --cores ${CI_CPU} --net0 virtio,bridge=${CI_NETWORK_BRIDGE}"
qm create ${CI_VM_ID} --name "${CI_VM_NAME}" --memory ${CI_RAM_MB} --sockets 1 --cores ${CI_CPU} --net0 virtio,bridge=${CI_NETWORK_BRIDGE}
# Importing disk
echo "qm importdisk ${CI_VM_ID} $CI_TEMPLATE_DIR/$CI_IMAGE_NAME $CI_STORAGE"
qm importdisk ${CI_VM_ID} "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" "$CI_STORAGE"
# Configuring type of disk
echo "qm set ${CI_VM_ID} --scsihw virtio-scsi-pci --scsi0 ${CI_STORAGE}:vm-${CI_VM_ID}-disk-0"
qm set ${CI_VM_ID} --scsihw virtio-scsi-pci --scsi0 "${CI_STORAGE}:vm-${CI_VM_ID}-disk-0"
# Rezising disk
echo "qm resize ${CI_VM_ID} scsi0 ${CI_DISK}"
qm resize ${CI_VM_ID} scsi0 ${CI_DISK}
# Cloudinit disk
echo "qm set ${CI_VM_ID} --ide2 $CI_STORAGE:cloudinit"
qm set ${CI_VM_ID} --ide2 "$CI_STORAGE:cloudinit"
# Networking
echo "qm set ${CI_VM_ID} --ipconfig0 ip=${CI_IP_ADDRESS}/${CI_CIDR},gw=${CI_GATEWAY}"
qm set ${CI_VM_ID} --ipconfig0 ip=${CI_IP_ADDRESS}/${CI_CIDR},gw=${CI_GATEWAY}
echo "qm set ${CI_VM_ID} --nameserver ${CI_DNS}"
qm set ${CI_VM_ID} --nameserver "${CI_DNS}"
echo "qm set ${CI_VM_ID} --serial0 socket --vga serial0"
qm set ${CI_VM_ID} --serial0 socket --vga serial0

# Creating Cloud Init config
mkdir -p ${CI_SNIPPETS}
echo "cat <<EOF > ${CI_SNIPPETS}/cloudinit-user-data-${CI_VM_ID}.yml"
cat <<EOF > "${CI_SNIPPETS}/cloudinit-user-data-${CI_VM_ID}.yml"
#cloud-config
hostname: ${CI_VM_NAME}
users:
  - name: $CI_USER_NAME
    primary_group: $CI_USER_NAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: "$CI_USER_PASSWORD_HASH"
  - name: root
    shell: /bin/bash
    lock_passwd: false
    passwd: "$CI_ROOT_PASSWORD_HASH"
ssh_pwauth: true

package_update: true
packages:
  - sudo
  - curl
  - wget
  - htop
  - nano
  - bash-completion
  - cron
  - net-tools
  - iputils-ping
  - vim
  - systemd-timesyncd
  - rsync
  - git

  write_files:
  - path: /etc/resolv.conf
    content: |
      nameserver ${DNS}
    permissions: '0644'
    owner: root:root

runcmd:
  - mkdir -p /var/log/journal
  - echo "Storage=persistent" >> /etc/systemd/journald.conf
  - systemctl restart systemd-journald
  - echo "${CI_VM_NAME}" > /etc/hostname
  - hostnamectl set-hostname ${VM_NAME}
  - echo "$(echo "$CI_IP_ADDRESS" | cut -d'/' -f1) ${CI_VM_NAME}" >> /etc/hosts
  - echo "$(echo "$CI_IP_ADDRESS" | cut -d'/' -f1) ${CI_VM_NAME}.${CI_DOMAIN_NAME}" >> /etc/hosts
  - sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  - sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - echo '' >> /etc/ssh/sshd_config
  - echo 'Match User root' >> /etc/ssh/sshd_config
  - echo '  PasswordAuthentication no' >> /etc/ssh/sshd_config
  - systemctl restart ssh
  - systemctl stop openipmi || true
  - systemctl disable openipmi || true
  - systemctl mask openipmi || true
  - apt remove --purge -y openipmi ipmitool || true
  - apt update && apt full-upgrade -y
  - apt autoremove -y && apt clean
  - echo 'root:$CI_ROOT_PASSWORD' | chpasswd
  - passwd -u root
  - sysctl -w net.ipv6.conf.all.disable_ipv6=1
  - sysctl -w net.ipv6.conf.default.disable_ipv6=1
  - echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
  - echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
  - echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
  - sysctl -p
  - systemctl daemon-reexec
EOF

# Applying Cloud Init config
echo "qm set ${CI_VM_ID} --cicustom user=local:snippets/cloudinit-user-data-${CI_VM_ID}.yml"
qm set ${CI_VM_ID} --cicustom "user=local:snippets/cloudinit-user-data-${CI_VM_ID}.yml"
echo "qm cloudinit update ${CI_VM_ID}"
qm cloudinit update ${CI_VM_ID}

# Setting boot order
echo "qm set ${CI_VM_ID} --boot order=scsi0 --bootdisk scsi0"
qm set ${CI_VM_ID} --boot order=scsi0 --bootdisk scsi0

# Setting start on boot
if [[ $CI_ON_BOOT -eq 1 ]]; then
    qm set ${CI_VM_ID} --onboot 1
fi

# Starting VM
if [[ $CI_START -eq 1 ]]; then
    qm start ${NEW_VM_ID}
fi

CI_NETWORK=$($CI_UTILS/networking.sh "$CI_NETWORK/$CI_CIDR" NETWORK)
mkdir -p $CI_NETWORKS
mkdir -p "$CI_NETWORKS/$CI_NETWORK"
echo "$CI_VM_ID" > "$CI_NETWORKS/$CI_NETWORK/$CI_IP_ADDRESS"

echo "END"

# echo "CI_VM_ID: $CI_VM_ID"
# echo "CI_VM_NAME: $CI_VM_NAME"
# echo "CI_OS_NAME: $CI_OS_NAME"
# echo "CI_OS_SCRIPT: $CI_OS_SCRIPT"
# echo "CI_CPU: $CI_CPU"
# echo "CI_RAM: $CI_RAM"
# echo "CI_RAM_MB: $CI_RAM_MB"
# echo "CI_DISK: $CI_DISK"
# echo "CI_CHOICE: $CI_CHOICE"
# echo "CI_NETWORK: $CI_NETWORK"
# echo "CI_CIDR: $CI_CIDR"
# echo "CI_IP_ADDRESS: $CI_IP_ADDRESS"