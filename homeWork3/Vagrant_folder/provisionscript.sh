#!/bin/bash
# update all
yum -y update
yum -y install gcc kernel-devel make wget kernel-headers
VBOX_VERSION=$1
# auto start script
echo "/home/vagrant/install_GuestAdd.sh $VBOX_VERSION" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
chmod +x /home/vagrant/install_GuestAdd.sh
mkdir /media/test
# Reboot VM
shutdown -r now
