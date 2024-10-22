#!/bin/bash

json_file="/opt/plcnext/apps/60002172000868/app_info.json"

version=$(awk -F'"' '/"version"/ {print $4}' "$json_file")

echo "$version"
