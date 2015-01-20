#!/bin/bash
# Bash script to control dream-cheeky red button
# Inspirated by Malcolm Sparks <malcolm@congreve.com> C driver
# for the same device.
# developed mostly by Fernando Merces <www.mentebinaria.com.br>
# with some contributions by Alfredo Casanova <atcasanova@gmail.com>
######################################################################
 
LID_CLOSED=21
BUTTON_PRESSED=22
LID_OPEN=23
 
last=$LID_CLOSED
buffer="\x08\x00\x00\x00\x00\x00\x00\x02"
ct=0
 
while true
do
        echo -ne "$buffer" > /dev/hidraw3
        buf=$(timeout 0.02 head -c1 /dev/hidraw3)
        [ ${#buf} -eq 1 ] || continue
        status=$(head -c1 <<< $buf)
        status=$(echo -ne "$status" | hexdump -v -e '/1 "%d"')
        if [ $last -eq $LID_CLOSED -a $status -eq $LID_OPEN ]
        then
                echo "LID OPEN $last $status ($ct)"
        elif [ $last -ne $BUTTON_PRESSED -a $status -eq $BUTTON_PRESSED ]
        then
                echo "FIRE $last $status ($ct)"
        elif [ $last -ne $LID_CLOSED -a $status -eq $LID_CLOSED ]
        then
                echo "LID CLOSED $last $status ($ct)"
        fi
        last=$status
        sleep 0.05
done
