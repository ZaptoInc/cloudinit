#!/bin/bash
CI_INSTALL_DIR="/var/lib/vz"
export CI_INSTALL_DIR
export CI_TEMPLATE_DIR="$CI_INSTALL_DIR/template/raw"
export CI_SCRIPTS="$CI_INSTALL_DIR/cloudinit/scripts"