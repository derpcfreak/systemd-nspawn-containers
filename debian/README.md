rpm -i debootstrap-1.0.140-3.el10_0.noarch.rpm --nodeps
Install `debootstrap` on the current distribution you are running and make sure that your system can run `systemd-nspawn` containers.
If this prerequisites are met, just execute the bash script to create a new systemd-nspawn container in `/var/lib/machines/`.
For the purpose we use `debootstrap` it usually does not need its dependencies like dpkg so you can install it without
dependencies e.g. `--nodeps`.
