#!/bin/bash

# Stop Enigma2
/sbin/init 4

# System update
opkg update
opkg upgrade
opkg clean

# Restore keymap
sed -i 's/<key id="KEY_EXIT" mapto="leavePlayerOnExit" flags="m" \/>/<key id="KEY_EXIT" mapto="leavePlayer" flags="m" \/>/g' /usr/share/enigma2/keymap.xml

# Remove unwanted packages
opkg remove --force-depends --force-remove --autoremove $(cat /usr/script/remove.opkg)

# System restart
/sbin/init 6
