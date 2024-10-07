#!/bin/bash

# Check for standby
standby=$(wget -O- -q http://127.0.0.1/api/powerstate | grep instandby | cut -d ":" -f 2)

# Check for number of active recordings
recordings=$(wget -O- -q http://127.0.0.1/api/timerlist | grep '"state": 2' | wc -l)

if [ "$standby" = " true" ] && [ "$recordings" = "0" ]; then
    # Restart enigma2
    wget -O- -q http://127.0.0.1/api/powerstate?newstate=3
    # Restart softcam
    /etc/init.d/softcam restart
fi
