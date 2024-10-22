#!/bin/bash

# ! Do not modify the file. !

CONFIGFILE_PATH="/opt/plcnext/config/System/Um/Modules"
current_user=$(whoami)
APP_CONFIG="/opt/plcnext/apps/60002172000868/AuthenticationProvider/config/UmModuleEx.config"
if [ ! "$current_user" = "root" ]; then
	echo "Error: Please execute with root privileges."
	exit 1
fi


if [ "$#" -ne 1 ]; then
    echo "Usage: sh change-ip.sh  <server_ip_address>"
    exit 1
fi

if [ ! -f "$APP_CONFIG" ]; then
	echo "Error: App config file does not exist."
	exit 1
fi

IP=$1


if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    IFS='.' read -r -a octets <<< "$IP"
    valid=true
    for octet in "${octets[@]}"; do
        if ! (( octet >= 0 && octet <= 255 )); then
            valid=false
            break
        fi
    done
    
    if [ "$valid" = true ]; then
        echo "The ip address you entered: $IP"
	cp ${APP_CONFIG} /opt/plcnext/config/System/Um/Modules
	sed -i "s/<!--IP-->/$IP/gi" ${CONFIGFILE_PATH}/UmModuleEx.config
	echo "Change success. Please reboot to apply the configuration changes."
    else
        echo "Error: Invalid IP address. Each section must be between 0 and 255."
        exit 1
    fi
else
    echo "Error: Invalid IP address format."
    exit 1
fi

