#!/bin/bash
# ! Do not modify the file. !

current_user=$(whoami)


if [ ! "$current_user" = "root" ]; then
	echo "Error: Please execute with root privileges."
	exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: sh register-license.sh  <path_of_the_license_file>"
    exit 1
fi

license_file_path=$1
if [ ! -f "$license_file_path" ]; then
    echo "Error: License file does not exist in this path."
    exit 1
fi

license_destination_path="/opt/plcnext/otac/license/swidchauthclient.lic"

> "$license_destination_path"
cp "$license_file_path" "$license_destination_path"


if [ ! -s "$license_destination_path" ]; then
	echo "Error: License file is empty. Please check the license file you uploaded."
	exit 1
fi

size1=$(stat -c %s "$license_destination_path")
size2=$(stat -c %s "$license_file_path")

if [ ! "$size1" -eq "$size2" ]; then
	echo "Error: Copy error. Please try again."
	exit 1
fi

echo "License file creation success. Please reboot to apply the license file."