#!/bin/bash

# 10s is the time window where systemd stops trying to restart a service
sleep 15

# If lightdm is not running after 15s, it's not a random crash, but many
# otherwise nothing to do, systemd will call us again if it crashes more.
if pidof -x lightdm > /dev/nulll; then
    exit 0
fi

# Can't have this be a dependency of our unit or it'll trigger too early.
service plymouth-reboot start
plymouth display-message --text="SteamOS is attempting to recover from a fatal error"
plymouth system-update --progress=10
dpkg --configure -a
apt-get -f -y install
plymouth system-update --progress=50

# Force a rebuild of all dkms modules.
dkms_modules=`find /usr/src -maxdepth 2 -name dkms.conf`
arr=($dkms_modules)
let prog=50

# Compute how far to move the progress bar for each module.
let delta="50/${#arr[@]}"

for i in $dkms_modules; do
	module_name=`grep ^PACKAGE_NAME $i | cut -d= -f2 | tr -d \"`
	module_version=`grep ^PACKAGE_VERSION $i | cut -d= -f2 | tr -d \"`

	dkms remove $module_name/$module_version --all
	dkms build -m $module_name -v $module_version
	dkms install -m $module_name -v $module_version

	let prog="$prog + $delta"
	plymouth system-update --progress=$prog
done

plymouth system-update --progress=100
plymouth display-message --text="Recovery complete, restarting..."

sleep 1

reboot
