------------------------------------------------------------
Описание файлов в директории
errorsResolve.txt - ошибки с которыми встретился и их решение
logFileFull.log - полный лог выполнения
used_commands.txt - команды которые использовал
usedInetResorce.txt - ресурсы в интернете которые мне помогли решить ДЗ
usedPackage.txt - краткое описание используемых пакетов

Vagrant_folder - все что понадобится для поднятия VM и краткое описание файлов в ней
install_GuestAdd.sh - скрипт установки Virtual Box Guest Additions запускаемый после перезагузки VM
provisionscript.sh - скрипт провижинга VM
sharedFolder_in_master.sh - включение shared folder, Virtual Box на master
Vagrantfile - вагрант файл

------------------------------------------------------------
Описание как запустить виртуальную машину чтобы shared folder работали (кратко)
Выполнить команду
vagrant up
дождаться когда VM завершит работу
выполнить скрипт на master (рабочая машина на которой вы работаете)
sharedFolder_in_master.sh
Запустить виртуальную машину и зайти в нее по ssh
vagrant up
vagrant ssh
Выполнить в VM команды
sudo -i
echo "123" > /media/test/1.txt
выйти из VM
logout
logout
Прочитать файл 1.txt который перенесся на master с VM
cat /mnt/test/1.txt
123


------------------------------------------------------------
Полное описание как работают скрипты и запуск vagrant up

------------Vagrantfile (только интересные моменты)------------
Version=`VBoxManage -v | cut -f1 -d'r'`
Присваиваем переменной Version номер версии Virtual Box

`if ! [ -d /mnt/test/ ];then mkdir /mnt/test;fi`
Если нет папки /mnt/test/ на master то создаем ее

config.vm.provision "file", source: "install_GuestAdd.sh", destination: "/home/vagrant/"
через провижинг передаем скрипт install_GuestAdd.sh в VM в директорию /home/vagrant/

config.vm.provision "shell", path: "provisionscript.sh", args: Version
выполняем скрипт provisionscript.sh в VM и передаем скрипту версию Virtual Box которая стоит на master

после запуска VM запускается скрипт
------------provisionscript.sh------------
#!/bin/bash
#все обновляем в том числе и ядро. Ставим хедеры ядра и нужные пакеты
yum -y update
yum -y install gcc kernel-devel make wget kernel-headers
#добавляем в автозагрузку скрипт установки Virtual Box Guest Additions и передаем ему версию Virtual Box. После устновки хедеров и ядра нужна перезагрузка
VBOX_VERSION=$1
echo "/home/vagrant/install_GuestAdd.sh $VBOX_VERSION" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
chmod +x /home/vagrant/install_GuestAdd.sh
#создаем папку для shared folder
mkdir /media/test
#перезагружаем VM
shutdown -r now

После перезагрузки системы запускается воторой скрипт
------------install_GuestAdd.sh------------
#!/bin/bash
#ранее мы передали из master номер версии Virtual Box и присваиваем его переменной
VBOX_VERSION=$1
#качаем нужный iso и монтируем его
wget -P /tmp/ http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /tmp/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
#устанавливаем Virtual Box Guest Additions и говорим что GUI у нас нет
/mnt/VBoxLinuxAdditions.run --nox11
#убираем из автозагрузки наш скрипт, он сделал свое дело
sed -i '/install_GuestAdd.sh/d' /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#выключаем VM
shutdown -h now

После отключения VM запускаем скрипт
------------sharedFolder_in_master.sh------------
#!/bin/bash
#Передаем в переменную uuidVM уникальный номер нашей VM
uuidVM=$(vboxmanage list vms | grep "shared-folder" | sed 's|.*{\(.*\)}|\1|')
#И создаем для VM shared folder с именем hell дитектория на master "/mnt/test", дитектория в VM /media/test
VBoxManage sharedfolder add $uuidVM --name "hell" --hostpath "/mnt/test" --automount --auto-mount-point "/media/test"

Далее еще раз запускаем нашу виртуальную машину.
Создаем и заполняем файл в директории /media/test
и тот же файл мы увидем в директории /mnt/test на master