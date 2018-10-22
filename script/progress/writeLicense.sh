#!/bin/bash

serial=$(grep -E -o -m 1 "Serial #:.{1,10}" 11.7-Linux64.txt )
serial=$(echo "$serial"|tr -d " Serial #: ")

control1=$(grep -E -o -m 1 "OE RDBMS Adv Enterprise Edition Serial #: "$serial" Rel: 11.7 Control#:.{1,18}" 11.7-Linux64.txt )
control1=$(echo ${control1: -17})
control2=$(grep -E -o -m 1 "OE App Server Basic Serial #: "$serial" Rel: 11.7 Control#:.{1,18}" 11.7-Linux64.txt )
control2=$(echo ${control2: -17})
control3=$(grep -E -o -m 1 "Progress Dev AppServer for OE Serial #: "$serial" Rel: 11.7 Control#:.{1,18}" 11.7-Linux64.txt )
control3=$(echo ${control3: -17})
control4=$(grep -E -o -m 1 "OE Development Server Serial #: "$serial" Rel: 11.7 Control#:.{1,18}" 11.7-Linux64.txt )
control4=$(echo ${control4: -17})
control5=$(grep -E -o -m 1 "4GL Development System Serial #: "$serial" Rel: 11.7 Control#:.{1,18}" 11.7-Linux64.txt )
control5=$(echo ${control5: -17})


sed -i '15s/serial=/serial='"$serial"'/' response.ini
sed -i '22s/serial=/serial='"$serial"'/' response.ini
sed -i '29s/serial=/serial='"$serial"'/' response.ini
sed -i '36s/serial=/serial='"$serial"'/' response.ini
sed -i '43s/serial=/serial='"$serial"'/' response.ini

sed -i '17s/control=/control='"$control1"'/' response.ini
sed -i '24s/control=/control='"$control2"'/' response.ini
sed -i '31s/control=/control='"$control3"'/' response.ini
sed -i '38s/control=/control='"$control4"'/' response.ini
sed -i '45s/control=/control='"$control5"'/' response.ini
