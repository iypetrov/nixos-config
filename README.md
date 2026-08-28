# nixos-config

My NixOS configurations.

## Bootstrap

```sh
# NixOS VM
$ sudo su
$ passwd # root
$ ip addr
$ echo "nameserver 8.8.8.8" > /etc/resolv.conf

# MacOS Host
$ make vm/bootstrap0 NIXADDR=<NIXOS-PRIVATE-IPv4>
$ make vm/bootstrap NIXADDR=<NIXOS-PRIVATE-IPv4>

# NixOS VM (after you clone the repo on the VM)
$ make switch
```

## VMware Fusion VM

Create a VMware Fusion VM with the following settings:
- ISO: NixOS 26.05 or later.
- Disk: SATA 150 GB+
- CPU/Memory: I give at least half my cores and half my RAM, as much as you can.
- Graphics: Full acceleration, full resolution, maximum graphics RAM.
- Network: Shared with my Mac.
- Remove sound card, remove video camera, remove printer.
- Profile: Disable almost all keybindings
- Boot Mode: UEFI
