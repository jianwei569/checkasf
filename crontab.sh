path=$(cat ${checkasf}/path.json | awk -F "[:]" '/path/{print$2}' | awk -F'"' '{print $2}')
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
date >> /tmp/tmp.txt
#echo $check_asf
echo "command(bash) results are:$check_asf"
if [[ $check_asf =~ "asf" ]]
then
        echo "ASF is running !"
else
        echo "running ASF!"
        runasf
fi
