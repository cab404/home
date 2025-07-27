#!/usr/bin/env bash

## Preview Plymouth Splash ##
##      by _khAttAm_       ##
##    www.khattam.info     ##
##    License: GPL v3      ##

# chk_root () {
#   if [ ! $( id -u ) -eq 0 ]; then
#     echo "The installer must be run as root (sudo)."
#     exit
#   fi
# }

# chk_root

DURATION=$1
if [ $# -ne 1 ]; then
  DURATION=3
fi

plymouthd --debug
sleep 0.1s
plymouth --show-splash
plymouth ask-for-password --command=echo --prompt="I need a password:"
for ((I=0; I<$DURATION; I++)); do
  plymouth --update=test$I;
  plymouth display-message --text="Boot testing, $I..."
  sleep 1;
  done;
plymouth quit
