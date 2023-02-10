#!/bin/bash
set -x
echo "test..."

kernelSet(){

kernel_Somaxconn=`sed -n '/net.core.somaxconn = 1024/d' /etc/sysctl.conf`

if [ $kernel_Somaxconn = 0  ];then
   echo "不需要修改somaxconn"
else
  #删除
  sed -i '/net.core.somaxconn = 1024/d' /etc/sysctl.conf  
fi

#1.优化内核参数
cat >> /etc/sysctl.conf << EOF
net.core.somaxconn = 65535
net.core.wmem_max = 16777216
net.core.rmem_max = 1024123000
net.core.netdev_max_backlog = 1000
net.core.optmem_max = 20480
net.ipv4.tcp_max_tw_buckets = 262144
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_retries1 = 5
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_mem = 2304000 3072000 4608000
net.ipv4.tcp_wmem = 8192 436600 4194304
net.ipv4.tcp_rmem = 32768 436600 4194304
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_syn_backlog = 200000
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 0
net.ipv4.tcp_syncookies = 1
net.core.netdev_max_backlog = 165536

EOF

 echo -e  "\033[31m 主机 优化Kernel参数完毕 \033[0m "
}
#2.句柄数
fileLimits(){
cat >> /etc/security/limits.conf <<EOF
* soft nofile 1024000
* hard nofile 1024000
hive   - nofile 1024000
hive   - nproc  1024000
# End of file
EOF
 echo -e  "\033[31m 主机 优化句柄数 参数完毕  \033[0m"
}

#3.php优化
phpSet(){
#修改phplimit
sed -i  '/log_level = notice/a\rlimit_files = 65535' /www/server/php/72/etc/php-fpm.conf
#修改php动态设置
sed -i 's/pm = dynamic/pm = static/g'  /www/server/php/72/etc/php-fpm.conf
#修改php启动的子进程
sed -i  's/pm.max_children = 300/pm.max_children = 30/g'  /www/server/php/72/etc/php-fpm.conf

#修改php.ini
sed -i 's/max_execution_time = 300/max_execution_time = 100/g'  /www/server/php/72/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 1024M/g'  /www/server/php/72/etc/php.ini
#关闭某些功能
#disable_functions

}


#4.nginx日志优化

nginxSet(){


}



#5.日志轮训
logCut(){
#保存三天日志
cat >> /etc/logrotate.d/nginx  <<EOF
 /www/wwwlogs/*.log {
  daily
  rotate 3
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e  /www/server/nginx/logs/nginx.pid ] && kill -USR1 `cat  /www/server/nginx/logs/nginx.pid`
  endscript
}
EOF
}
