#!/bin/bash
CI_INSTALL_DIR="/var/lib/vz"
export CI_INSTALL_DIR
export CI_TEMPLATE_DIR="$CI_INSTALL_DIR/template/raw"
export CI_SCRIPTS="$CI_INSTALL_DIR/cloudinit/scripts"

CI_CUSTOM_VARIABLES="/etc/cloudinit/custom.sh"
if [[ -e $CI_CUSTOM_VARIABLES ]]; then
    chmod +x $CI_CUSTOM_VARIABLES
    source $CI_CUSTOM_VARIABLES
fi