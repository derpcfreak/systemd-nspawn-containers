This is a special version that maps the hosts interface `br0` into the container so the container
would be able to access the network(s) attached to `br0`

This mapping is done by the setting

```
[Network]
Bridge=br0
```

in the `.nspawn` file.

Since the container does not have any means of automatically configuring the network, dhcpcd is installed within the OS.
A custom systemd service `network-ifup-and-dhcp.service` has been created to bring the `host0` interface
inside the container up and uses `dhcpcd` to aquire an ip address.
`dhcpcd`s own service has not been enabled.



Install `dnf` on the current distribution you are running and make sure that your system can run `systemd-nspawn` containers.
If this prerequisites are met, just execute the bash script to create a new systemd-nspawn container in `/var/lib/machines/`.
