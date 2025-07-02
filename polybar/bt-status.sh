#!/bin/bash

icon_on=""
icon_off=""

# Verify if is on
powered=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
if [[ "$powered" != "yes" ]]; then
    echo "$icon_off "
    exit 0
fi

# Search
device_block=$(bluetoothctl info)
if [[ -z "$device_block" ]]; then
    echo "$icon_on "
    exit 0
fi

# Pick the mac addres
device_name=$(echo "$device_block" | grep "Name" | cut -d ' ' -f2-)
device_mac=$(echo "$device_block" | grep "Device" | awk '{print $2}' | sed 's/:/_/g')

# Search the converted MAC
battery_path=$(upower -e | grep -i "$device_mac")

# Search the percent
if [[ -n "$battery_path" ]]; then
    battery_level=$(upower -i "$battery_path" | grep "percentage" | awk '{print $2}')
else
    battery_level="??%"
fi

echo "$icon_on %{T3} $device_name $battery_level"
