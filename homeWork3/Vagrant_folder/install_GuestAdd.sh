#!/bin/bash
VBOX_VERSION=$1
wget -P /tmp/ http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /tmp/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
/mnt/VBoxLinuxAdditions.run --nox11
sed -i '/install_GuestAdd.sh/d' /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
shutdown -h now
