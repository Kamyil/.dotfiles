# WireGuard DNS on NixOS and macOS

WireGuard is managed by NixOS, while its private configuration remains outside the public repository:

- `/etc/wireguard/wg0.conf` contains peers, routes, keys, and private DNS details.
- `wg-quick-wg0.service` starts the tunnel from that file.
- `dnsmasq` is the system resolver at `127.0.0.1`.
- NetworkManager supplies the normal upstream DNS servers.

## macOS: persistent split DNS

The `malinka` tunnel uses `wg-quick` with `wireguard-go`. Its private configuration must not set `DNS = 10.10.0.1`, because `wg-quick` would make the Raspberry Pi resolver global and public DNS would fail whenever the tunnel is unavailable.

nix-darwin manages `/etc/resolver/lan` through `environment.etc` in `nix/macos.nix`:

```text
nameserver 10.10.0.1
```

macOS therefore sends only `.lan` queries to `10.10.0.1`; DHCP/Wi-Fi resolvers remain responsible for public domains. The resolver file intentionally exists independently of the WireGuard lifecycle. With the tunnel down, only `.lan` resolution is unavailable.

### Endpoint refresh after wake or network changes

`vpn.malinka.uk` is resolved when `wg-quick up malinka` runs. To discard a stale split-horizon endpoint address, nix-darwin declares three launchd daemons:

- `malinka-wireguard-wake` uses `sleepwatcher` to emit a wake file event when the desired-active marker exists;
- `malinka-wireguard-refresh` watches that event and `/etc/resolv.conf`, cleans up the current or stale runtime mapping, then kickstarts the tunnel service;
- `malinka-wireguard` runs `wg-quick up malinka`.

The `wgu malinka` helper creates `/var/run/wireguard/malinka.desired-active` only after a successful manual start. `wgd malinka` removes it before attempting cleanup, so explicit user intent wins even when the runtime state is broken. Wake and network events do nothing without this marker.

The mapping file `/var/run/wireguard/malinka.name` contains the actual `wireguard-go` interface name (for example `utun4`). Cleanup therefore uses that name rather than the `malinka` configuration name and tolerates stale socket/mapping state.

On Darwin, `wg-quick up` calls `launchctl procinfo $$`, keeps its route monitor attached when that PID belongs to launchd, and waits for it. The dedicated `malinka-wireguard` wrapper therefore ends with `exec wg-quick up malinka`: `wg-quick` replaces the launchd-owned process instead of running as its child. The tunnel service remains running with the route monitor, while the refresh job remains short-lived and only uses `launchctl kickstart`. There is no polling loop or periodic restart. Refresh logs are written to `/var/log/malinka-wireguard-refresh.log`; tunnel and route-monitor logs use `/var/log/malinka-wireguard.log`.

## NixOS

### VPN DNS lifecycle

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

### Reproducibility boundary

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
