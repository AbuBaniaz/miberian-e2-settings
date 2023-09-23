#!/bin/bash

iptv_update () {

echo "*** IPTV UPDATE ***"

echo "** Downloading Bouquets **"
file="/etc/enigma2/iptv_bouquets"
while read line; do
  bouquet=$(echo $line | awk -F "/" '{print $NF}')
  A=$$; ( wget -q $line -O /tmp/$A.d && mv /tmp/$A.d /etc/enigma2/$bouquet ) || (rm /tmp/$A.d; echo "Removing temp file")
  result=$(grep $bouquet /etc/enigma2/bouquets.tv)
  if [ ! -n "$result" ]; then
    echo "#SERVICE 1:7:1:0:0:0:0:0:0:0:FROM BOUQUET \"${bouquet}\" ORDER BY bouquet" >> /etc/enigma2/bouquets.tv
  fi
done < "${file}"

}

# Update channel list
iptv_update

# Reload enigma2 channel list
wget -qO - http://127.0.0.1/web/servicelistreload?mode=0
