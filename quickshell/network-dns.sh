#!/usr/bin/env bash
set -euo pipefail

active_uuid=$(nmcli -t -f UUID,TYPE,STATE connection show --active | awk -F: '$2 == "802-11-wireless" || $2 == "802-3-ethernet" { print $1; exit }')
[[ -n $active_uuid ]] || { echo 'No active network connection' >&2; exit 1; }

current_provider() {
  local automatic dns
  automatic=$(nmcli -g ipv4.ignore-auto-dns connection show "$active_uuid")
  dns=$(nmcli -g ipv4.dns connection show "$active_uuid" | tr ';' ' ')
  if [[ $automatic != yes || -z ${dns// /} ]]; then echo DHCP
  elif [[ $dns == *1.1.1.1* ]]; then echo Cloudflare
  elif [[ $dns == *8.8.8.8* ]]; then echo Google
  else echo Custom
  fi
}

[[ $# -gt 0 ]] || { current_provider; exit 0; }
provider=$1
case "$provider" in
  DHCP)
    nmcli connection modify "$active_uuid" ipv4.ignore-auto-dns no ipv4.dns '' ipv6.ignore-auto-dns no ipv6.dns ''
    ;;
  Cloudflare)
    nmcli connection modify "$active_uuid" ipv4.ignore-auto-dns yes ipv4.dns '1.1.1.1 1.0.0.1' ipv6.ignore-auto-dns yes ipv6.dns '2606:4700:4700::1111 2606:4700:4700::1001'
    ;;
  Google)
    nmcli connection modify "$active_uuid" ipv4.ignore-auto-dns yes ipv4.dns '8.8.8.8 8.8.4.4' ipv6.ignore-auto-dns yes ipv6.dns '2001:4860:4860::8888 2001:4860:4860::8844'
    ;;
  Custom)
    servers=${2:-}
    [[ -n ${servers// /} ]] || { echo 'Enter at least one DNS server' >&2; exit 2; }
    ipv4=''; ipv6=''
    for server in ${servers//,/ }; do
      if [[ $server == *:* ]]; then ipv6+="${ipv6:+ }$server"; else ipv4+="${ipv4:+ }$server"; fi
    done
    nmcli connection modify "$active_uuid" ipv4.ignore-auto-dns yes ipv4.dns "$ipv4" ipv6.ignore-auto-dns yes ipv6.dns "$ipv6"
    ;;
  *) echo 'Usage: network-dns.sh [DHCP|Cloudflare|Google|Custom [servers]]' >&2; exit 2 ;;
esac

nmcli device reapply "$(nmcli -g GENERAL.DEVICES connection show "$active_uuid" | head -n 1)" >/dev/null
current_provider
