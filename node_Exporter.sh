#!/bin/bash


Check_network(){

checkTelnet=`rpm -qa | grep  telnet`

if [ -z $checkTelnet ];then

echo "没安装telnet"
yum install tenlet curl  -y
else 
echo "安装"
fi

}

Download(){

wget -P /usr/local/src/  https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz

tar -xvf  /usr/local/src/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz  -C /usr/local/

mv /usr/local/node_exporter-1.4.0-rc.0.linux-amd64  /usr/local/node_exporter

}

ServiceFile(){
cat > /lib/systemd/system/node_exporter.service  <<EOF

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
sleep 5s
systemctl start  node_exporter.service
systemctl enable node_exporter.service
systemctl status node_exporter.service
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="27.50.59.216/24" port protocol="tcp" port="9100" accept'
firewall-cmd --reload

}

Print_INFO(){

IP_Public=`curl -s ip.sb`
echo '''
Prometheus添加的服务服务信息
------------------------------------------
      - targets: ["'${IP_Public}':9100"]
        labels:
          instance: '${IP_Public}'-BT
------------------------------------------
'''
}
Check_network
Download
ServiceFile
Print_INFO

