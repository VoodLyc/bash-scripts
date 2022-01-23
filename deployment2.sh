#!/bin/bash

#Fuctions
check_availability () {
	for ((i =1; i<=22; i++))
	do
		if ping -c 1 xhgrid$i > /dev/null 2>&1
		then
			echo xhgrid$i available!
		else
			echo xhgrid$i not available!
		fi
	done
}

upload_files () {
	sshpass -p "swarch" ssh -tt swarchice@xhgrid$1 << EOF
	mkdir JOHAN_ICE
	exit
EOF
	sshpass -p "swarch" scp mcafe.zip swarchice@xhgrid$1:/home/swarchice/VALDES_ICE

	sshpass -p "swarch" ssh -tt swarchice@xhgrid$1 <<EOF
	cd JOHAN_ICE/
	unzip johancoffee.zip
	cd johancoffee/src_postgres/
	./gradlew build
	exit
EOF
}

deploy_type () {
case $1 in
	1)
		sshpass -p "swarch" ssh -tt swarchice@xhgrid$2 << EOF
		cd JOHAN_ICE/src_postgres/ServidorCentral/build/libs
		java -jar ServidorCentral.jar
EOF
	;;
	2)
		sshpass -p "swarch" ssh -tt swarchice@xhgrid$2 << EOF
		cd JOHAN_ICE/src_postgres/
		icebox --Ice.Config=config.icebox
EOF
	;;
	3)
		sshpass -p "swarch" ssh -tt -X swarchice@xhgrid$2 << EOF
		cd JOHAN_ICE/src_postgres/coffeeMach/build/libs
		java -jar coffeeMach.jar
EOF
		;;
	*)
		echo invalid type!
	;;
esac
}

check_dir () {
    if [[ `sshpass -p "swarch" ssh swarchice@xhgrid$1 test -d /home/swarchice/JOHAN_ICE && echo exists` ]]
    then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

replace () {
if check_dir $1
then
    echo JOHAN_ICE already exists, do you want to replace it? y/n
    read replace
    if [ $replace == "y" ]
    then
        sshpass -p "swarch" ssh -tt swarchice@xhgrid$1 << EOF
        rm -r JOHAN_ICE/
        exit
EOF
        upload_files $xhgrid
    fi
else
    upload_files $xhgrid
fi
}

echo type:$'\n' 1 - ServidorCentral $'\n' 2 - Icebox $'\n' 3 - coffeMach $'\n'please enter type:
read type_component

echo Do you want to check the availability of the hosts '(xhgrid *)'? y/n
read answer

if [ $answer == "y" ]
then
	check_availability
fi

echo Please enter the xhgrid '(1, 2, ... 22)':
read xhgrid

replace $xhgrid

deploy_type $type_component $xhgrid
