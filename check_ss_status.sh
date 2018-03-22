
#完美解决掉线问题（未运行 未加速）
#脚本中 ss-local   dns2socks  ss_redir 三个进程 ， ps查看自己的极路由中是哪三个，各个版本中似乎有点不一样
#参考操作
#1. cp  check_ss_status.sh  /etc/init.d/
#2. chmod +x /etc/init.d/check_ss_status.sh
#3. rc.local 中   执行  check_ss_status.sh
############################################################################

#!/bin/sh

name='ss-local'


check_ss_status() {
        if [ `killall -0 ss-local >/dev/null 2>&1; echo $?` == 1 ] || [ `killall -0 dns2socks >/dev/null 2>&1; echo $?` == 1 ] || [ `killall -0 ss-redir >/dev/null 2>&1; echo $?` == 1 ]; then

                val=`date`
                echo -n $val  >>/tmp/check_ss_status_aaron.log
                ss_local_val=`killall -0 ss-local >/dev/null 2>&1`
                echo -n " ss_local = $?; " >> /tmp/check_ss_status_aaron.log
                dns_val=`killall -0 dns2socks >/dev/null 2>&1`
                echo -n "dns2socks = $?; " >> /tmp/check_ss_status_aaron.log
                ss_val=`killall -0 ss-redir >/dev/null 2>&1`
                echo -n "ss_redir = $? " >> /tmp/check_ss_status_aaron.log

                if [ -f /etc/init.d/gw-shadowsocks ]; then
                       /etc/init.d/gw-shadowsocks restart
                       RETVAL=$?
                       if [ "$RETVAL" = "0" ]; then
                                echo "  $name restart success"  >>/tmp/check_ss_status_aaron.log
                       else
                               echo "$name restart failed"  >>/tmp/check_ss_status_aaron.log
                       fi
                else
                       echo " it is starting... "
                fi
         else
                echo "$name is running"
                RETVAL=1
         fi
}


check_conn_youtube(){
        conn_status=`curl www.youtube.com -m 3 -s -o /dev/null`
        conn_status=$?
        echo "connect youtube status=$conn_status"
        if [ "$conn_status" = "0" ] ;then
                echo "ss is ok"
        else
                val=`date`
                echo -n $val  >>/tmp/check_ss_status_aaron.log
                echo " it can NOT access youtube, restart ss.. "  >>/tmp/check_ss_status_aaron.log
                /etc/init.d/gw-shadowsocks restart
        fi

}



while  [ 1 ]; do
        echo "************************************************************************"
        echo "check ss status, every 15s"
        check_conn_youtube
        sleep 10
        check_ss_status
        sleep 5
done

