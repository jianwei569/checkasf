#!/usr/bin/env bash
#判断系统
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

update_software(){
	#$PM
	yum install update -y
}

install_expect(){
	#$PM
	yum install -y expect
}

install_screen(){
	#$PM
	yum install -y screen
}

#判断是否有安装expect或screen
#check_expect=$($PM | grep "expect")
check_expect=$(yum list installed | grep "expect")

if [[ $check_expect =~ "expect" ]]
then
        echo "expect已安装，继续执行！"
else
        echo "检测到未安装expect，自动安装!"
        install_expect
fi

#check_screen=$($PM | grep "screen")
check_screen=$(yum list installed | grep "screen")

if [[ $check_screen =~ "screen" ]]
then
        echo "screen已安装，继续执行!"
else
        echo "检测到未安装screen，自动安装!"
        install_screen
fi

#更改ASF的路径
NewAsfPath(){
	read ASF
	final=$(echo $ASF | grep -E '^\/(\w+\/?)+$')
	if [ -n final ]
	then
		echo -e "{\n\"path\":\"$ASF\"\n}" > path.json
		#cat test.json
	else
		echo "Invalid!"
fi
}

#ASF="/opt/ASF/ArchiSteamFarm"
#判断ASF是否存在
path=$(cat path.json | jq '.path' | sed 's/\"//g')
echo "默认ASF路径为$path"
while :
do
	path=$(cat path.json | awk -F "[:]" '/path/{print$2}' | sed 's/\"//g')
	if [ -f "$path" ] && [ -n "$path" ]
	then
		echo "ASF文件存在，继续执行！"
		break
	else	
		echo "无法检测到ASF！"
		read -p "是否输入新的ASF路径？y/n" yn
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
#判断asf状态
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
        echo "ASF已经在运行了！"
else
        echo "ASF未在运行! 启动ASF!"
        runasf
fi

#创建定时检测计划
CreatNewCrontab(){
	CUR_PATH=$(cd "$(dirname "$0")"; pwd)
	File_name="/crontab.sh"
	final=${CUR_PATH}
	sed  -i '1 i\checkasf='"$final"''  crontab.sh
	crontab -l > conf && echo "0 */2 * * * ${CUR_PATH}${File_name} >> /tmp/tmp.txt" >> conf && crontab conf && rm -f conf
}

#检测是否已经存在相同的定时检测计划
CheckCrontab(){
	result=$(crontab -l | grep "checkasf/crontab.sh")
	if [[ $result =~ "checkasf/crontab.sh" ]]
	then
        echo "已经有定时检测ASF计划了！"
	else
        echo "暂无定时检测ASF计划，创建中!"
        CreatNewCrontab
	fi
}

read -p "创建一个定时检测计划吗?y/n:" yon
case $yon in
	[Yy]) CheckCrontab
	;;
	[Nn]) exit 0
	;;
	*) exit 0
	;;
esac
