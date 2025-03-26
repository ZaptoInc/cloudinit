#!/bin/bash

# Downloading variables config file
mkdir "/etc/cloudinit"
wget -O "/etc/cloudinit/variables.sh" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/variables.sh"
chmod +x "/etc/cloudinit/variables.sh"

# Importing variables config
source "/etc/cloudinit/variables.sh"

# Importing OS scripts
mkdir "$CI_SCRIPTS"
wget -O "$CI_SCRIPTS/debian12.sh" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/scripts/debian12.sh"
chmod +x "$CI_SCRIPTS/debian12.sh"

# Creating cloudinit executable
wget -O "/usr/local/bin/cloudinit" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/cloudinit"
chmod +x "/usr/local/bin/cloudinit"

echo "TODO"
