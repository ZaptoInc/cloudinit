#!/bin/bash

source /etc/cloudinit/variables.sh

CI_IMAGE_NAME="debian-12-genericcloud-amd64.raw"

echo "TODO"

DownloadImage() {
    mkdir "$CI_TEMPLATE_DIR"
    wget -O "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.raw"
}

if [[ ! -e "$CI_TEMPLATE_DIR/$CI_IMAGE_NAME" || "$CI_UPDATE_OS" -eq 1 ]]; then
    DownloadImage
fi