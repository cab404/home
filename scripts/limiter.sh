#!/usr/bin/env bash

sleepUntil() {
    sleep $(( $(date +%s --date="$1") - $(date +%s) ))
}

sleepUntilMinute() {
    local hour
    local minute
    hour=$(date +%_H)
    minute=$1
    if [ $(( $(date +%_M) < minute )) == 0 ]; then
       hour=$(((hour + 1) % 24));
    fi
    sleepUntil $hour:$minute;
}


while true; do
  sleepUntilMinute 55
  echo "Engaging limiter for 10 minutes"
  wl-gammactl -c 1.4 -b 0.25 & gamma_pid=$!
  trap "kill $gamma_pid" EXIT
  sleepUntilMinute 0
  echo "Releasing limiter"
  kill $gamma_pid
  trap "exit" EXIT
done
