#!/bin/bash

# Entrées : réseau et CIDR (ex: 192.168.1.0/24)
RESEAU_CIDR="$1"

# Vérifier le format
if ! [[ "$RESEAU_CIDR" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/(3[0-2]|[12]?[0-9])$ ]]; then
  echo "Format invalide. Utilisation : $0 192.168.1.0/24"
  exit 1
fi

IP="${BASH_REMATCH[1]}"
CIDR="${BASH_REMATCH[2]}"

# Convertir IP en entier
ip_to_int() {
  IFS=. read -r a b c d <<< "$1"
  echo $(( (a << 24) + (b << 16) + (c << 8) + d ))
}

# Convertir entier en IP
int_to_ip() {
  local ip=$1
  echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}

# Calcul des plages IP
NET_INT=$(ip_to_int "$IP")
MASK=$(( 0xFFFFFFFF << (32 - CIDR) & 0xFFFFFFFF ))
NET_ADDR=$(( NET_INT & MASK ))
BROADCAST=$(( NET_ADDR | ~MASK & 0xFFFFFFFF ))

# Générer une IP aléatoire entre NET_ADDR+1 et BROADCAST-1
RANDOM_IP=$(( RANDOM % (BROADCAST - NET_ADDR - 1) + NET_ADDR + 1 ))
int_to_ip "$RANDOM_IP"
