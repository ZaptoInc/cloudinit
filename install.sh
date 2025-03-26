#!/bin/bash
CI_INSTALL_DIR="/var/lib/vz"
CI_TEMPLATE_DIR="$CI_INSTALL_DIR/template/raw"
CI_SCRIPTS="$CI_INSTALL_DIR/cloudinit/scripts"

mkdir "$CI_TEMPLATE_DIR"
wget -O "$CI_TEMPLATE_DIR" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"

mkdir "$CI_SCRIPTS"
wget -O "$CI_SCRIPTS/debian12.sh" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/scripts/debian12.sh"

wget -O "/usr/local/bin/cloudinit" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/cloudinit"

echo "TODO"
