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
```
