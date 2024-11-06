#!/bin/bash

opkg_remove_from_file () {

	filename=$1
	if [[ -f $filename ]]; then
		opkg remove --force-depends --force-remove --autoremove $(cat $filename)
	else
		echo "** opkg_remove_from_file: \"$filename\" not found"
	fi

}

opkg_install_from_file () {

	filename=$1
	if [[ -f $filename ]]; then
		opkg install $(cat $filename)
	else
		echo "** opkg_install_from_file: \"$filename\" not found"
	fi

}

cron_add_from_file () {

	filename=$1
	if [[ -f $filename ]]; then
  		while read LINE || [[ -n "$LINE" ]]; do
    			crontab -l | grep "$LINE" || (crontab -l 2>/dev/null; echo "$LINE") | crontab -
  		done < $filename
	else
		echo "** cron_add_from_file: \"$filename\" not found!"
	fi

}

if [[ -f ./deploy.conf ]]; then
	source ./deploy.conf
	echo "e2-settings: box $box, distro $distro, keys_folder $keys_folder"
else
	echo "e2-settings: ERROR config file not found"
	exit -1
fi

echo "e2-settings: Stopping Enigma2..."
/sbin/init 4

echo "e2-settings: Removing unwanted packages..."
opkg_remove_from_file "./opkg/remove.e2"
opkg_remove_from_file "./opkg/remove.$distro"
opkg_remove_from_file "./opkg/remove.$box"
cat ./opkg/remove.* > /usr/script/remove.opkg

echo "e2-settings: Running custom commands..."
if [[ -f ./install/custom-e2.sh ]]     ; then ./install/custom-e2.sh      ; fi
if [[ -f ./install/custom-$distro.sh ]]; then ./install/custom-$distro.sh ; fi
if [[ -f ./install/custom-$box.sh ]]   ; then ./install/custom-$box.sh    ; fi

echo "e2-settings: Installing required packages..."
opkg update
opkg_install_from_file "./opkg/install.e2"
opkg_install_from_file "./opkg/install.$distro"
opkg_install_from_file "./opkg/install.$box"

echo "e2-settings: Configuring cron jobs..."
cron_add_from_file "./cron/cronjobs.e2"
cron_add_from_file "./cron/cronjobs.$distro"
cron_add_from_file "./cron/cronjobs.$box"

echo "e2-settings: Deploying configuration..."
cp -r ./$box/e2/* /
cp -r ./$box/$distro/* /

if [[ -f $keys_folder/$box-e2.keys.tar ]]; then
	echo "e2-settings: Unpacking keys..."
	tar xvf $keys_folder/$box-e2.keys.tar -C /
else
	echo "e2-settings: WARNING keys file \"$keys_folder/$box-e2.keys.tar\" not found. You might not be able to ssh into the box"
fi

if [[ -f /usr/script/iptv_update.sh ]]; then
	echo "e2-settings: Loading IPTV channels..."
	/usr/script/iptv_update.sh
else
	echo "e2-settings: INFO IPTV script not found. Skipping..."
fi

if [[ -f /usr/script/system_update.sh ]]; then
	echo "e2-settings: Upgrading and restarting!"
	/usr/script/system_update.sh
else
	echo "e2-settings: WARNING System update script not found. Review log and/or restart manually"
fi
