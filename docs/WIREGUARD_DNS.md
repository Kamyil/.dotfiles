# WireGuard DNS on NixOS

WireGuard is managed by NixOS, while its private configuration remains outside the public repository:

- `/etc/wireguard/wg0.conf` contains peers, routes, keys, and private DNS details.
- `wg-quick-wg0.service` starts the tunnel from that file.
- `dnsmasq` is the system resolver at `127.0.0.1`.
- NetworkManager supplies the normal upstream DNS servers.

## VPN DNS lifecycle

The external `wg0.conf` leaves `DNS = ...` disabled and changes the `dnsmasq` upstream while the tunnel is active:

```ini
[Interface]
# DNS = <VPN_DNS_IP>

PostUp = printf 'server=<VPN_DNS_IP>\n' > /etc/dnsmasq.d/wireguard.conf
PostUp = systemctl restart dnsmasq.service

PreDown = rm -f /etc/dnsmasq.d/wireguard.conf
PreDown = systemctl restart dnsmasq.service
```

When `wg0` starts, all DNS queries use the VPN resolver. When it stops, `dnsmasq` returns to the upstream selected by NetworkManager. This requires the VPN resolver to resolve both private and public names.

WireGuard itself does not resolve names. `dnsmasq` converts names to IP addresses; WireGuard's `AllowedIPs` and routes determine whether packets to those addresses travel through the tunnel.

## Reproducibility boundary

The public Nix configuration reproducibly provides:

- `dnsmasq` and `/etc/dnsmasq.d`;
- the `wg-quick-wg0` service and service ordering;
- NetworkManager integration;
- the `wgr` restart alias.

The private `/etc/wireguard/wg0.conf` is provisioned separately. Its hooks generate `/etc/dnsmasq.d/wireguard.conf` automatically, so no separate DNS setup is required on a new machine.

After provisioning `wg0.conf`, apply the system configuration normally:

```bash
nrs
```
(alias for `sudo nixos-rebuild switch --flake=~/.dotfiles/nix`)
To reapply tunnel and DNS changes:

```bash
wgr
```
(wireguard reset)
