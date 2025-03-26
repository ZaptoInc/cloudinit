#!/bin/bash

export CI_VERBOSE=1

# Downloading variables config file
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Creating /etc/cloudinit if it doesn't exist"
fi
mkdir -p "/etc/cloudinit"
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Downloading latest variable.sh to /etc/cloudinit..."
fi
wget -O "/etc/cloudinit/variables.sh" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/variables.sh"
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Making it executable"
fi
chmod +x "/etc/cloudinit/variables.sh"

# Importing variables config
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Importing variables"
fi
source "/etc/cloudinit/variables.sh"

# Creating main directory
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Creating $CI_MAIN_DIR if it doesn't exist"
fi
mkdir -p "$CI_MAIN_DIR"

# Importing OS scripts
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Creating $CI_SCRIPTS if it doesn't exist"
fi
mkdir -p "$CI_SCRIPTS"
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Downloading latest debian12.sh to $CI_SCRIPTS..."
fi
wget -O "$CI_SCRIPTS/debian12.sh" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/scripts/debian12.sh"
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Making it executable"
fi
chmod +x "$CI_SCRIPTS/debian12.sh"

# Creating cloudinit executable
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Downloading latest cloudinit to /usr/local/bin..."
fi
wget -O "/usr/local/bin/cloudinit" "https://raw.githubusercontent.com/ZaptoInc/cloudinit/refs/heads/master/cloudinit"
if [[ "$CI_VERBOSE" -eq 1 ]]; then
    echo "Making it executable"
fi
chmod +x "/usr/local/bin/cloudinit"

echo "TODO"
