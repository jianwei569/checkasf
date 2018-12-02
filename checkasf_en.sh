#!/usr/bin/env bash
Get_Dist_Name()
{
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt-get'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt-get'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt-get'
    else
        DISTRO='unknow'
    fi
    #echo $DISTRO;
}
Get_Dist_Name

update_software(){
	#$PM
	#yum update -y
	$PM update -y
}

install_expect(){
	#$PM
	#yum install -y expect
	$PM install -y expect
}

install_screen(){
	#$PM
	#yum install -y screen
	$PM install -y screen
}

check_expect=$($PM list installed | grep "expect")
#check_expect=$(yum list installed | grep "expect")

if [[ $check_expect =~ "expect" ]]
then
        echo "expect has been installed!"
else
        echo "installing expect!"
        install_expect
fi

check_screen=$($PM list installed | grep "screen")
#check_screen=$(yum list installed | grep "screen")

if [[ $check_screen =~ "screen" ]]
then
        echo "screen has been installed"
else
        echo "installing screen!"
        install_screen
fi

NewAsfPath(){
	read ASF
	final=$(echo $ASF | grep -E '^\/(\w+\/?)+$')
	if [ ! -z $final ]
	then
		echo -e "{\n\"path\":\"$ASF\"\n}" > path.json
		#cat test.json
	else
		echo "Invalid!"
fi
}

#ASF="/opt/ASF/ArchiSteamFarm"
path=$(cat path.json | awk -F "[:]" '/path/{print$2}' | awk -F'"' '{print $2}')
echo "default ASF path:$path"
while :
do
	path=$(cat path.json | awk -F "[:]" '/path/{print$2}' | awk -F'"' '{print $2}')
	if [ -f "$path" ] && [ -n "$path" ]
	then
		echo "ASF exist!"
		break
	else	
		echo "can not detect ASF!"
		read -p "input new ASF path?y/n:" yn
		case $yn in
		[Yy]) NewAsfPath
		;;
		[Nn]) exit 0
		;;
		*) exit 0
		;;
		esac
	fi
done

#screen -ls | grep "asf"
runasf(){
cmd=$"$path";
screen_name="asf"
screen -dmS $screen_name
screen -x -S $screen_name -p 0 -X stuff "$cmd"
screen -x -S $screen_name -p 0 -X stuff '\n'
/usr/bin/expect <<EOF
send "\01"
send "d"
expect eof
EOF
}

check_asf=$(screen -ls | grep "asf")
#echo $check_asf
echo "command(bash) results are:$check_asf"
if [[ $check_asf =~ "asf" ]]
then
        echo "ASF is running !"
else
        echo "running ASF!"
        runasf
fi

CreatNewCrontab(){
	CUR_PATH=$(cd "$(dirname "$0")"; pwd)
	File_name="/crontab.sh"
	final=${CUR_PATH}
	sed  -i '1 i\checkasf='"$final"''  crontab.sh
	crontab -l > conf && echo "0 */2 * * * ${CUR_PATH}${File_name} >> /tmp/tmp.txt" >> conf && crontab conf && rm -f conf
}

CheckCrontab(){
	result=$(crontab -l | grep "checkasf/crontab.sh")
	if [[ $result =~ "checkasf/crontab.sh" ]]
	then
        echo "Already have checkasf！"
	else
        echo "No checkasf create one!"
        CreatNewCrontab
	fi
}

read -p "Create new Crontab?y/n:" yon
case $yon in
	[Yy]) CheckCrontab
	;;
	[Nn]) exit 0
	;;
	*) exit 0
	;;
esac
