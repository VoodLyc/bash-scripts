#!/bin/bash
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
	mkdir VALDES_ICE
	exit
EOF
	sshpass -p "swarch" scp mcafe.zip swarchice@xhgrid$1:/home/swarchice/VALDES_ICE

	sshpass -p "swarch" ssh -tt swarchice@xhgrid$1 <<EOF
	cd VALDES_ICE/
	unzip mcafe.zip
	cd mcafe/java-components/coffeemach/src_postgres/
	chmod +x gradlew
	./gradlew build
	exit
EOF
}

deploy_type () {
case $1 in
	1)
		sshpass -p "swarch" ssh -tt swarchice@xhgrid$2 << EOF
		cd VALDES_ICE/mcafe/java-components/coffeemach/src_postgres/ServidorCentral/build/libs
		java -jar ServidorCentral.jar
EOF
	;;
	2)
		sshpass -p "swarch" ssh -tt swarchice@xhgrid$2 << EOF
		cd VALDES_ICE/mcafe/java-components/coffeemach/src_postgres/
		fuser -n tcp -k 9996
		icebox --Ice.Config=config.icebox
EOF
	;;
	3)
		sshpass -p "swarch" ssh -tt -X swarchice@xhgrid$2 << EOF
		cd VALDES_ICE/mcafe/java-components/coffeemach/src_postgres/coffeeMach/build/libs
		java -jar coffeeMach.jar
EOF
		;;
	*)
		echo invalid type!
	;;
esac
}

check_dir () {
    if [[ `sshpass -p "swarch" ssh swarchice@xhgrid$1 test -d /home/swarchice/VALDES_ICE && echo exists` ]]
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
    echo VALDES_ICE already exists, do you want to replace it? y/n
    read replace
    if [ $replace == "y" ]
    then
        sshpass -p "swarch" ssh -tt swarchice@xhgrid$1 << EOF
        rm -r VALDES_ICE
        exit
EOF
        upload_files $1
    fi
else
    upload_files $1
fi
}

update_host_mcCafe () {
    cd mcafe/java-components/coffeemach/src_postgres/coffeeMach/src/main/resources/
    sed -i "1s/.*/CoffeMach.Endpoints = default -h hgrid$1 -p 12346/" coffeMach.cfg
    sed -i "2s/.*/MqCafe = MQCafe:tcp -h hgrid$2 -p 12345" coffeMach.cfg
    sed -i "3s/.*/ProxyServer = proxy:tcp -h hgrid$2 -p 12345" coffeMach.cfg
    sed -i "6s/.*/TopicManager.Proxy=RecetasPubSub/TopicManager:default -h hgrid$3 -p 10000" coffeMach.cfg
    cd ~/Desktop/ALL/Scripts/
    zip_update
}

zip_update () {
    if [[ `test -f mcafe.zip && echo exists` ]]
    then
        rm mcafe.zip
    fi
    zip -r mcafe.zip mcafe
}

deploy () {
    replace $2

    deploy_type $1 $2
}
