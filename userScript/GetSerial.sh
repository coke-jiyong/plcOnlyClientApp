#!/bin/bash

# ! Do not modify the file. !

current_user=$(whoami)

if [ ! "$current_user" = "root" ]; then
    echo "Error: Please execute with root privileges."
    exit 1
fi

result=$(cat /etc/device_data/phoenixsign/production_data | grep 'OEM_SERIAL=' | awk -F'"' '{print $2}' | sed 's/"//g')
echo "$result"

