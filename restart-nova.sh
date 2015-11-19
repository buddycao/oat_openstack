#!/bin/bash

unset http_proxy
unset https_proxy
unset ftp_proxy

usage(){
    echo "Error! You must specify the role to restart Nova service!"
    echo "Usage --->> ./restart-nova.sh controller/compute"
    exit 1
}

role=$1

if [ -z $role ];then
   usage
fi

##############Kill all nova service and clen up old log files################
ps aux | grep nova- | grep -v grep | grep -v $0 | awk '{print $2}' | xargs -i kill -9 {}
mkdir -p /var/log/nova/
rm -f /var/log/nova/*

##############Restart Nova services#############################
if [ $role = "controller" ];then
    echo "Restart Controller Nova services"
    nohup /usr/bin/nova-api --config-file /etc/nova/nova.conf --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/api.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-objectstore --config-file /etc/nova/nova.conf --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/network.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-novncproxy --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf  --logfile /var/log/novncproxy.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-consoleauth --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/consoleauth.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-scheduler --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/scheduler.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-conductor --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/conductor.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-txt --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/txt.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-cert --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/cert.log > /dev/null 2>& 1 &

elif [ $role = "compute" ];then
    echo "Restart compute node Nova services"
    nohup /usr/bin/nova-compute --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/compute.log > /dev/null 2>& 1 &
    nohup /usr/bin/nova-txt --config-file /etc/nova/nova.conf  --config-file /etc/nova/nova-txt.conf --logfile /var/log/nova/txt.log > /dev/null 2>& 1 &
else
    echo "Unsupport parameters"
    usage
fi

echo "Done!"
