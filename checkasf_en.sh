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
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    #echo $DISTRO;
}
Get_Dist_Name

install_expect(){
	#$PM
	yum install -y expect
}

install_screen(){
	#$PM
	yum install -y screen
}

#check_expect=$($PM | grep "expect")
check_expect=$(yum list installed | grep "expect")

if [[ $check_expect =~ "expect" ]]
then
        echo "expect has been installed!"
else
        echo "installing expect!"
        install_expect
fi

#check_screen=$($PM | grep "screen")
check_screen=$(yum list installed | grep "screen")

if [[ $check_screen =~ "screen" ]]
then
        echo "screen has been installed"
else
        echo "installing screen!"
        install_screen
fi

ASF="/opt/ASF/ArchiSteamFarm"
echo "default ASF path:$ASF"
while :
do
	if [ -f $ASF ]
	then
		echo "ASF exist!"
		break
	else	
		echo "can not detect ASF!"
		read -p "input new ASF path?y/n" yn
		case $yn in
		[Yy]) read ASF
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
cmd=$"$ASF";
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
