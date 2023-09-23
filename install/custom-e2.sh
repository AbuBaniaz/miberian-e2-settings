#!/bin/bash

lamedb_origin="https://raw.githubusercontent.com/ciefp/ciefpsettings-enigma2/master/ciefp-E2-1sat-19E/lamedb"

# Get initial channel db
A=$$; ( wget -q $lamedb_origin -O /tmp/$A.d && mv /tmp/$A.d /etc/enigma2/lamedb ) || (rm /tmp/$A.d; echo "Removing temp file")

# Clean default bouquet settings
rm /etc/enigma2/bouquets.*
rm /etc/enigma2/userbouquet.favourites.*
