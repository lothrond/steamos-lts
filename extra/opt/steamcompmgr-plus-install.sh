#!/bin/bash
#
# Get the latest (stable) release of SteamOS compositor plus from gamer-os

# Exit with return value.
ret=1

# Get from the internet, put on machine.
echo -e "Getting latest release of SteamOS compositor plus ..."
if wget https://raw.githubusercontent.com/gamer-os/steamos-compositor/master/steamos-install.sh -P /tmp; then
	# Install from machine.
	echo "Installing ..."
	if sudo bash /tmp/steamos-install.sh; then
		echo "Done." && ret=0
	fi
fi

exit ${ret}
