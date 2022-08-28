#!/bin/sh
dbus-send --system --print-reply --dest=org.freedesktop.DisplayManager  /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToUser string:'steam' string:''

