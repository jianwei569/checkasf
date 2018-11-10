#!/usr/bin/env bash
#�ж�ϵͳ
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

#�ж��Ƿ��а�װexpect��screen
#check_expect=$($PM | grep "expect")
check_expect=$(yum list installed | grep "expect")

if [[ $check_expect =~ "expect" ]]
then
        echo "expect�Ѱ�װ������ִ�У�"
else
        echo "��⵽δ��װexpect���Զ���װ!"
        install_expect
fi

#check_screen=$($PM | grep "screen")
check_screen=$(yum list installed | grep "screen")

if [[ $check_screen =~ "screen" ]]
then
        echo "screen�Ѱ�װ������ִ��!"
else
        echo "��⵽δ��װscreen���Զ���װ!"
        install_screen
fi

#����ASF��·��
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
#�ж�ASF�Ƿ����
path=$(cat path.json | awk -F "[:]" '/path/{print$2}' | sed 's/\"//g')
echo "Ĭ��ASF·��Ϊ$path"
while :
do
	if [ -f "$path" ] && [ -n "$path" ]
	then
		echo "ASF�ļ����ڣ�����ִ�У�"
		break
	else	
		echo "�޷���⵽ASF��"
		read -p "�Ƿ������µ�ASF·����y/n" yn
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
#�ж�asf״̬
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
        echo "ASF�Ѿ��������ˣ�"
else
        echo "ASFδ������! ����ASF!"
        runasf
fi

#������ʱ���ƻ�
CreatNewCrontab(){
	CUR_PATH=$(cd "$(dirname "$0")"; pwd)
	File_name="/crontab.sh"
	crontab -l > conf && echo "00 12 * * * ${CUR_PATH}${File_name} >> /tmp/tmp.txt" >> conf && crontab conf && rm -f conf
}


read -p "����һ����ʱ���ƻ���?y/n:" yon
case $yon in
	[Yy]) CreatNewCrontab
	;;
	[Nn]) exit 0
	;;
	*) exit 0
	;;
esac
