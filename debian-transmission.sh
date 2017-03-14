#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


# Transmission | Debian
rootFolder=""
webFolder=""
orgindex="index.original.html"
index="index.html"
tmpFolder="/tmp/tr-web-control/"
packname="transmission-control-full.tar.gz"
host="https://github.com/uesugitatsuya/transmission-web/raw/master/release/"
donwloadurl="$host$packname"
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
	echo "deb http://ftp.debian.org/debian/ sid main" >> /etc/apt/sources.list
	echo "deb http://ftp.debian.org/debian/ experimental main" >> /etc/apt/sources.list
	apt-get update
	apt-get -t experimental install transmission-daemon -y
	echo "APT::Default-Release \"stable\";" >> /etc/apt/apt.conf.d/71distro
else
	apt-get update
	apt-get -y install transmission-daemon
fi

# SETTINGS.JSON
service transmission-daemon stop
wget --no-check-certificate https://raw.githubusercontent.com/asukax/transmission/master/settings.json
mv -f settings.json /etc/transmission-daemon
sed -i 's/^.*rpc-username.*/"rpc-username": "'$(echo $username)'",/' /etc/transmission-daemon/settings.json
sed -i 's/^.*rpc-password.*/"rpc-password": "'$(echo $password)'",/' /etc/transmission-daemon/settings.json
sed -i 's/^.*rpc-port.*/"rpc-port": '$(echo $port)',/' /etc/transmission-daemon/settings.json
service transmission-daemon start

mkdir -p /home/transmission/downloads/
chmod -R 777 /home/transmission/downloads/
#
if [ ! -d "$tmpFolder" ]; then
	cd /tmp
	mkdir tr-web-control
fi
cd "$tmpFolder"
# 找出web ui 目录
folderIsExist=0
echo "Searching Transmission Web Folder..."

# 感谢 yumin9822 提供的代码
rootFolder=`find / -name 'web' -type d | grep 'transmission/web' | head -n 1 | sed 's/web.*$//g'`

echo "Folder: ""$rootFolder""..."
if [ -d "$rootFolder""web/" ]; then
	webFolder="$rootFolder""web/"
	folderIsExist=1
fi

# 如果目录存在，则进行下载和更新动作
if [ $folderIsExist = 1 ]; then
	echo "Transmission Web Control Is Downloading..."
	wget "$donwloadurl"
	echo "Installing..."
	tar -xzf "$packname"
	rm "$packname"
	# 如果之前没有安装过，则先将原系统的文件改为
	if [ ! -f "$webFolder$orgindex" -a -f "$webFolder$index" ]; then
		mv "$webFolder$index" "$webFolder$orgindex"
	fi
	# 复制文件到
	cp -r web "$rootFolder"
	echo "Done."
else
	echo "##############################################"
	echo "#"
	echo "# ERROR : Transmisson WEB UI Folder is missing."
	echo "#"
	echo "##############################################"
fi
rm -rf "$tmpFolder"

# END
clear
echo "Done."
echo " "
echo "Web GUI: http://your ip:$port/"
echo "username: $username"
echo "password: $password"
