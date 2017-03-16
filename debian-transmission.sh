#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# VERSION CHOICE
ver="latest"
echo "Which version(latest OR stable) do you want to install:"
read -p "Type latest or stable (latest):" ver
if [ "$ver" = "" ]; then
	ver="latest"
fi

# CONFIGURATION
username=""
read -p "Set username(transmission):" username
if [ "$username" = "" ]; then
	username="transmission"
fi

password=""
read -p "Set password(transmission):" password
if [ "$password" = "" ]; then
	password="transmission"
fi

port=""
read -p "Set port(9091):" port
if [ "$port" = "" ]; then
	port="9091"
fi

	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

# START
if [ "$ver" = "latest" ]; then
#	echo "deb http://ftp.debian.org/debian/ sid main" >> /etc/apt/sources.list
#	echo "deb http://ftp.debian.org/debian/ experimental main" >> /etc/apt/sources.list
#	apt-get update
#	apt-get -t experimental install transmission-daemon -y
#	echo "APT::Default-Release \"stable\";" >> /etc/apt/apt.conf.d/71distro
	apt-get install transmission-daemon
else
#	apt-get update
	apt-get install transmission-daemon
fi

# SETTINGS.JSON
/etc/init.d/transmission-daemon stop
killall transmission-daemon
#wget --no-check-certificate https://raw.githubusercontent.com/asukax/transmission/master/settings.json
#mv -f settings.json /etc/transmission-daemon/
sed -i 's/^.*rpc-username.*/    "rpc-username": "'$(echo $username)'",/' /etc/transmission-daemon/settings.json
sed -i 's/^.*rpc-password.*/    "rpc-password": "'$(echo $password)'",/' /etc/transmission-daemon/settings.json
sed -i 's/^.*rpc-port.*/    "rpc-port": '$(echo $port)',/' /etc/transmission-daemon/settings.json
sed -i 's/^.*dht-enabled.*/    "dht-enabled": false,/' /etc/transmission-daemon/settings.json
sed -i 's/^.*rpc-whitelist-enabled.*/    "rpc-whitelist-enabled": false,/' /etc/transmission-daemon/settings.json
/etc/init.d/transmission-daemon start

#mkdir -p /home/transmission/downloads/
#chmod -R 777 /home/transmission/downloads/

# END
clear
echo "Done."
echo " "
echo "Web GUI: http://your ip:$port/"
echo "username: $username"
echo "password: $password"
