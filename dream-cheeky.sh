#!/bin/bash
#
# dream-cheeky.sh - Bit Red Button (http://dreamcheeky.com/big-red-button) controller
#
# Copyright (C) 2015 Alfredo Casanova <atcasanova@gmail.com>
#                    Fernando Merces <www.mentebinaria.com.br>
#
# Thanks to Malcolm Sparks <malcolm@congreve.com> for his C code that inspired us
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

read lid_closed button_pressed lid_open <<< "21 22 23"
last=$lid_closed
buffer="\x08\x00\x00\x00\x00\x00\x00\x02"

while true; do
	sleep 0.05
	echo -ne "$buffer" > /dev/hidraw3
	buf=$(timeout 0.02 head -c1 /dev/hidraw3)
	(( ${#buf} == 1 )) || continue
	status=$(echo -ne "$buf" | hexdump -e '"%d"')

	if (( $last == $lid_closed )) && (( $status == $lid_open )); then
		echo "LID OPEN $last $status"
	elif (( $last != $button_pressed )) && (( $status == $button_pressed )); then
		echo "FIRE $last $status"
	elif (( $last != $lid_closed )) && (( $status == $lid_closed )); then
		echo "LID CLOSED $last $status"
	fi

	last=$status
done