#!/bin/bash

source ~/Desktop/ALL/Scripts/functions.sh

echo Do you want to check the availability of the hosts '(xhgrid *)'? y/n
read answer

if [ $answer == "y" ]
then
	check_availability
fi

echo Please enter the xhgrid '(1, 2, ... 22)' for the ServidorCentral:
read server

echo Please enter the xhgrid '(1, 2, ... 22)' for the Icebox:
read icebox

read -p "Please enter hgrids for mcCafe separated by 'space' '(7 9 14 9)' : " xhgrids

konsole -e ./functions.sh && deploy 1 $server
konsole -e ./functions.sh && deploy 2 $icebox

for xhgrid in ${xhgrids[@]}
do
    update_host_mcCafe $xhgrid $server $icebox
    konsole -e ./functions.sh && deploy 3 $xhgrid
done
