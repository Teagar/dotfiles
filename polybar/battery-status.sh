#!/bin/bash

capacity=$(cat /sys/class/power_supply/axp288_fuel_gauge/capacity)
status=$(cat /sys/class/power_supply/axp288_fuel_gauge/status)

get_discharging_icon() {
  case $capacity in
    [0-7]) echo "" ;;
    [8-1][0-9]) echo "" ;;
    2[0-9]) echo "" ;;
    3[0-9]) echo "" ;;
    4[0-9]) echo "" ;;
    5[0-9]) echo "" ;;
    6[0-9]) echo "" ;;
    7[0-4]) echo "" ;;
    7[5-9]) echo ""  ;;
    8[0-9]) echo "" ;;
    9[0-5]) echo "" ;;
    *) echo "" ;;
  esac
}

get_charging_icon() {
  case $capacity in
    [0-7]) echo "" ;;
    [8-1][0-9]) echo "" ;;
    2[0-9]) echo "" ;;
    3[0-9]) echo "" ;;
    4[0-9]) echo "" ;;
    5[0-9]) echo "" ;;
    6[0-9]) echo "" ;;
    7[0-4]) echo "" ;;
    7[5-9]) echo ""  ;;
    8[0-9]) echo "" ;;
    9[0-5]) echo "" ;;
    *) echo "" ;;
  esac
}

if [[ "$status" == "Charging" ]]; then
  icon="$(get_charging_icon)   "
else
  icon="$(get_discharging_icon)   "
fi

echo "$icon $capacity%"
