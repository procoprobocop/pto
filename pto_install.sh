#!/bin/bash
#I. Раздел (Обновление, SSH, VNC, Disk2, Ввод в домен)
#
#
#
#создаём временную переменную "$PASSWORD" для подставления пароля администратора
PASSWORD=$(whiptail --title "Ввод пароля администратора" --passwordbox "Введите пароль Локального администратора и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
#проверка на наличие пользователя в группе администраторов
echo "Производится обновление системы"
sleep 3
echo "$PASSWORD" | sudo -S dnf -y install kernel-lt-5.15.35-1.el7.3.x86_64 kernel-lt-tools-5.15.35-1.el7.3.x86_64 kernel-lt-devel-5.15.35-1.el7.3.x86_64 kernel-lt-headers-5.15.35-1.el7.3.x86_64
echo "$PASSWORD" | sudo -S dnf -y update && echo "$PASSWORD" | sudo -S dnf -y upgrade && echo "$PASSWORD" | sudo -S dnf -y autoremove && uname -r
else
	echo "Вы выбрали отмену."
	exit
fi
#
#
#
echo "Установка и настройка VNC"
sleep 3
#устанавливаем программу x11vnc
echo "$PASSWORD" | sudo -S dnf -y install x11vnc
#создаём временную переменную $PASSVNC для подставления пароля
PASSVNC=$(whiptail --title "Ввод пароля" --passwordbox "Задайте пароль для доступа по VNC и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
#задаём пароль на вход
echo "$PASSWORD" | sudo -S x11vnc -storepasswd $PASSVNC /etc/vncpasswd
else
	echo "Вы выбрали отмену."
	exit
fi
#выдаём права на чтение и выполнение для файла с паролем
echo "$PASSWORD" | sudo -S chmod 544 /etc/vncpasswd
#создаём службу для подключения по протоколу vnc
IPVNC=$(whiptail --title "Настройка доступа VNC" --inputbox "Через запятую, без пробелов введите ip-адреса, которые будут подключаться к настриваемой машине по протоколу VNC (пример: 10.10.73.16,10.10.73.17 и т.д.)" 10 60 10.10.73.16,  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Вы предоставили доступ следующим ip-адресам:" $IPVNC
	echo "Вы выбрали отмену."
	exit
fi
sleep 5
#заходим в сервисную директорию и редактируем файл для автозапуска сервиса x11vnc.service
echo "$PASSWORD" | sudo -S touch /lib/systemd/system/x11vnc.service
echo "$PASSWORD" | sudo -S chmod 777 /lib/systemd/system/x11vnc.service
echo "$PASSWORD" | sudo -S echo -e "[Unit]\nDescription=x11vnc server for GDM\nAfter=display-manager.service\n[Service]\nExecStart=/usr/bin/x11vnc -allow $IPVNC -many -shared -forever -nomodtweak -capslock -display :0 -auth guess -noxdamage -rfbauth /etc/vncpasswd\nRestart=on-failure\nRestartSec=3\n[Install]\nWantedBy=graphical.target" > /lib/systemd/system/x11vnc.service
#даём файлу x11vnc.service права на выполнение
echo "$PASSWORD" | sudo -S chmod 755 /lib/systemd/system/x11vnc.service
#перезагружаем демона, включаем службу в автозагрузку, запускаем и проверяем статус
echo "$PASSWORD" | sudo -S systemctl daemon-reload
echo "$PASSWORD" | sudo -S systemctl enable x11vnc.service
echo "$PASSWORD" | sudo -S systemctl start x11vnc.service
echo "$PASSWORD" | sudo -S systemctl status x11vnc.service --no-pager
else
#
#
#
echo "Производится настройка Disk2"
sleep 3
#создаём таблицу разделов в формате gpt
echo "$PASSWORD" | sudo -S  parted /dev/sdb mktable gpt
#создаём раздел диска sdb, который будет называться sdb1 с файловой системой ext4 и отводим ему 100% места на диске
echo "$PASSWORD" | sudo -S  parted /dev/sdb mkpart primary ext4 0% 100% 
#форматируем созданный раздел
echo "$PASSWORD" | sudo -S  mkfs.ext4 /dev/sdb1
#создаём директорию Disk2, в которую смонтируем наш HDD
echo "$PASSWORD" | sudo -S  mkdir /mnt/Disk2
#монтируем созданный диск
echo "$PASSWORD" | sudo -S  mount /mnt/Disk2
#задаём директории Disk2 в которую примонтирован HDD доступ на чтение/запись/выполнение для всех: 
echo "$PASSWORD" | sudo -S  chmod 777 /mnt/Disk2/
#создаём символическую ссылку диска на рабочем столе локального пользователя:
ln -s /mnt/Disk2 /home/$USER/Рабочий\ стол/
#редактируем файл /etc/fstab монтируя вновь созданный раздел диска /dev/sdb1 в директорию Disk2
echo "$PASSWORD" | sudo -S  sh -c "echo '/dev/sdb1	/mnt/Disk2	ext4	defaults	1 2' >> /etc/fstab"
#
#
#
echo "Добавляем компьютер в домен"
sleep 3
#устанавливаем правильный часовой пояс
echo "$PASSWORD" | sudo -S timedatectl set-timezone Asia/Yekaterinburg
timedatectl | grep "Time zone"
date
chronyc tracking
#проверяем DNS и разрешение имён
nslookup 10.10.73.5
nslookup 10.10.73.9
nslookup PTO.local
#меняем локализацию на английскую. Это нужно, если у вас в пароле администратора домена присутствуют специальные символы: !@#$%^ и т.д..
#после перезагрузки локализация снова сбросится на русскую
export LANG=en_US.UTF-8
#проверяем доступность домена
realm discover PTO.local
#устанавливаем программу добавления в домен
echo "$PASSWORD" | sudo -S dnf -y install join-to-domain
#запускаем скрипт добавления в домен
echo "$PASSWORD" | sudo -S sudo join-to-domain.sh
sleep 60
sudo join-to-domain.sh
#проверяем доступность домена
realm list
#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
DOMAIN=$(dnsdomainname -d)
realm discover -v $DOMAIN
#проверяем новое имя компьютера
hostname
#даём группам "Администраторы домена" и "Пользователи домена" права выполнения команд от имени суперпользователя 
cd /etc/
echo "$PASSROOT" | sudo -S  perl -i -pe 'print "%Администраторы\\ домена  ALL=(ALL)       ALL\n" if $. == 108' sudoers
echo "$PASSROOT" | sudo -S  perl -i -pe 'print "%Пользователи\\ домена  ALL=(ALL)       ALL\n" if $. == 109' sudoers
#перезагружаемся, иначе магия не сработает
if (whiptail --title "Требуется перезагрузка системы" --yesno "Перезагрузить систему сейчас?" 10 60) then
	echo "$PASSWORD" | sudo reboot
else
	echo "Не забудьте перезагрузить систему"
	exit
fi
#
#
#




