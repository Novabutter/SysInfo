#!/bin/bash
# Center Title of Program
center() {
  termwidth="$(tput cols)"
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}
# Center Columns for Program
columns() {
  padding="$(printf '%0.1s' ' '{1..500})"
  printf '%*.*s %s %*.*s %s %*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/4))" "$padding" "$1" 0 "$(((termwidth-2-${#1})/5))" "$padding" "$2" 0 "$(((termwidth-2-${#1})/5))" "$padding" "$3"
}

# Update the line passed
update() {
  echo -en "$1"
}
# Clear Screen and set cursor to invisible
clear
tput civis -- invisible

# Declare Title and determine the main network interface
center "SysInfo"
INTER="$( ip -o link show | awk '{print $2,$9}' | grep "UP" | cut -d: -f 1 | cut -d@ -f 1)"
# Declare titles for columans

printCol=$( columns "\e[32mDisk" "\e[32mMemory" "\e[32mNetwork\e[0m" )

# Initiate initial bytes read by the network interface
prevBytes=$(cat /sys/class/net/$INTER/statistics/rx_bytes)

# Print the columns on the screen
echo -e "$printCol"

# Continue until interrupted

while :
do
  # Update variables of the system, including memory, disk usage, 
  # and the current total bytes from the network interface
  # Determine the original total bytes transmitted versus current
  # total bytes.

  memUsage=$(printf "%0.2f%%" "$(free -m | awk 'NR==2{ print $3*100/$2 }')" )
  diskUsage=$(df -t ext4 | awk 'NR==2{ print $5 }')
  currentBytes=$(cat /sys/class/net/$INTER/statistics/rx_bytes)
  networkChange=$( printf "%d B/s" "$( expr $currentBytes - $prevBytes )" )

  # Set the new total of bytes to the previous record of total bytes
  prevBytes=$currentBytes
  
  # Update and print the columns on the screen
  printUpdate=$( columns "$diskUsage" "$memUsage" "$networkChange") 
  update "$printUpdate"
  update "\r"
  # Wait for 1 second and clear the screen
  sleep 1
  update ""
done
