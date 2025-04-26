#!/bin/bash

update_channel_list () {

cat /etc/enigma2/userbouquet.abm.sat_192_sky_deutschland.main.tv | grep :85:c00000:0:0:0: | cut -d " " -f 2 | awk '{print toupper($0)}' > /etc/enigma2/whitelist_streamrelay

}

# Check for standby
standby=$(wget -O- -q http://127.0.0.1/api/powerstate | grep instandby | cut -d ":" -f 2)

# Check for number of active recordings
recordings=$(wget -O- -q http://127.0.0.1/api/timerlist | grep '"state": 2' | wc -l)

# Update channel list
update_channel_list

if [ "$standby" = " true" ] && [ "$recordings" = "0" ]; then
    # Restart enigma2
    wget -O- -q http://127.0.0.1/api/powerstate?newstate=3
    # Restart softcam
    /etc/init.d/softcam restart
fi
