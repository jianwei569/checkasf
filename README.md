# checkasf
# checkasf
前言：

之前楼主利用手中的闲置服务器挂卡，以前2.0版本的时候可以设置不要自动更新，觉得很方便，后来不更新不给用，所以就升级到3.0+版本，特点每天都会检查更新，一更新就会退出screen，无法进行挂卡，近来突发奇想，能否利用crontab来定时检测呢？于是就有了这篇教程
目前该脚本仅适配CentOS，其他系统在适配中(咕咕咕)
脚本功能：
检测是否已安装expect和screen
检测ASF是否存在
若以上都存在则检测asf是否运行，若不在运行则启动ASF

默认ASF路径存在于path.json文件中，默认是/opt/ASF/ArchiSteamFarm，若路径不一样可以执行脚本修改或者自行修改

使用方法：

---
一条命令直接搞定
git clone https://github.com/jianwei569/checkasf && cd checkasf && chmod +x *.sh
---
分步骤
从我的Github上面down代码
git clone https://github.com/jianwei569/checkasf
复制代码


接下来进入checkasf文件夹
cd checkasf

接下来输入
chmod +x *.sh
---
crontab基本格式，可以参考一下

基本格式 : 
*　　*　　*　　*　　*　　command 
分　时　日　月　周　命令 
第1列表示分钟1～59 每分钟用*或者 */1表示 
第2列表示小时1～23（0表示0点） 
第3列表示日期1～31 
第4列表示月份1～12 
第5列标识号星期0～6（0表示星期天） 
第6列要运行的命令 
例如：
00 12 * * * /root/checkasf.sh 
表示每天中午12点都检测一次ASF的状态
---
常见问题：
Q：为啥没有其他系统的呀
A：因为还没做适配呀

Q：怎么看ASF目录啊
A：cd进ASF所在目录，然后输入pwd

Q:为啥会出现no crontab for root啊
A：这是因为你的系统还没有一个定时计划
    在 root 用户下输入 crontab -e
按 Esc 按： wq   回车输入
然后就可以继续执行啦！
