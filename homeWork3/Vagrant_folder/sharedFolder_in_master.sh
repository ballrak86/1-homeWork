#!/bin/bash
uuidVM=$(vboxmanage list vms | grep "shared-folder" | sed 's|.*{\(.*\)}|\1|')
VBoxManage sharedfolder add $uuidVM --name "hell" --hostpath "/mnt/test" --automount --auto-mount-point "/media/test"