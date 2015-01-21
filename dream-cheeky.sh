#!/bin/bash
# Bash script to control dream-cheeky red button
# http://dreamcheeky.com/big-red-button
# Inspirated by Malcolm Sparks <malcolm@congreve.com> C driver
# for the same device.
# developed mostly by Fernando Merces <www.mentebinaria.com.br>
# with some contributions by Alfredo Casanova <atcasanova@gmail.com>
######################################################################
 
read lid_closed button_pressed lid_open <<< "21 22 23"
last=$lid_closed
buffer="\x08\x00\x00\x00\x00\x00\x00\x02"

while true; do
	sleep 0.05
	echo -ne "$buffer" > /dev/hidraw3
	buf=$(timeout 0.02 head -c1 /dev/hidraw3)
	[ ${#buf} -eq 1 ] || continue
	status=$(echo -ne "$buf" | hexdump -ve '"%d"')
	if (( $last == $lid_closed )) && (( $status == $lid_open )); then
		echo "LID OPEN $last $status"
	elif (( $last != $button_pressed )) && (( $status == $button_pressed )); then
		echo "FIRE $last $status"
	elif (( $last != $lid_closed )) && (( $status == $lid_closed )); then
		echo "LID CLOSED $last $status"
	fi
	last=$status
done
