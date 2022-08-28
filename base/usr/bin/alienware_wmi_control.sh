#!/bin/bash

exec >/dev/null
exec 2>/dev/null

platform_dir=/sys/devices/platform/alienware-wmi

if [ "$1" = "--query-led-presence" ]
then
  if [ -d "$platform_dir/rgb_zones" ]
  then
    exit 0
  else
    exit 1
  fi
fi

if [ "$1" = "--query-hdmi-mux-presence" ]
then
  if [ -d "$platform_dir/hdmi" ]
  then
    exit 0
  else
    exit 1
  fi
fi

if [ "$1" = "--query-hdmi-mux-cable-presence" ]
then
  if [ ! -d "$platform_dir/hdmi" ]
  then
    exit 1
  fi
  status=$(cat $platform_dir/hdmi/cable | sed 's,.*\[,,; s,\].*,,')
  if [ "$status" = "connected" ]
  then
    exit 0
  else
    exit 1
  fi
fi

if [ "$1" = "--hdmi-mux" ]
then
  if [ ! -d "$platform_dir/hdmi" ]
  then
    exit 1
  fi
  echo $2 > $platform_dir/hdmi/source
  exit 0
fi

if [ "$1" = "--led-brightness" ]
then
  if [ ! -f "$platform_dir/leds/alienware::global_brightness/brightness" ]
  then
    exit 1
  fi
  echo $2 > $platform_dir/leds/alienware\:\:global_brightness/brightness
  exit 0
fi

if [ "$1" = "--supports-deep-sleep-control" ]
then
  if [ -d "$platform_dir/deepsleep" ]
  then
    exit 0
  fi
  exit 1
fi

if [ "$1" = "--query-deep-sleep-control" ]
then
  status=$(cat $platform_dir/deepsleep/deepsleep | sed 's,.*\[,,;s,\].*,,')
  if [ "$status" != "disabled" ]
  then
    exit 0
  fi
  exit 1
fi

if [ "$1" = "--modify-deep-sleep-control" ]
then
  #disabled/s5/s5_s4
  echo $2 > $platform_dir/deepsleep/deepsleep
  exit 0
fi

if [ "$1" = "head" ]; then
  zone="zone00"
elif [ "$1" = "left" ]; then
  zone="zone01"
elif [ "$1" = "right" ]; then
  zone="zone02"
fi

if [ ! -f "$platform_dir/rgb_zones/${zone}" ]
then
  exit 1
fi

R=0$(printf '%x\n' $2)
G=0$(printf '%x\n' $3)
B=0$(printf '%x\n' $4)
RGB="$R$G$B"

echo "running" > $platform_dir/rgb_zones/lighting_control_state
echo $RGB      > $platform_dir/rgb_zones/${zone}
