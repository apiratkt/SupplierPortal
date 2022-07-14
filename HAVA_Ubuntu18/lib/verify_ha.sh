#!/bin/bash
OWNPATH=`pwd`
PATH_LIB=${OWNPATH}/lib
PATH_RESULT=${OWNPATH}/result
PATH_CONFIG=${OWNPATH}/config
FILE_CONFIG=${PATH_CONFIG}/hava.config

#echo $OWNPATH
#echo $PATH_LIB
#echo $PATH_RESULT
#echo $PATH_CONFIG

# ip=`ifconfig | grep inet | awk 'NR==1{print $2}'`
# subnet=`ifconfig | grep inet | awk 'NR==1{print $4}'`
# CIDR=`cat ${PATH_CONFIG}/netmask.cfg | grep ${subnet} | awk -F'|' '{print $1}'`
# CIDR=`ip a | grep eth0 | grep inet | awk 'NR==1{print $2}'`
# ip=`echo $(cut -d'/' -f1<<<$CIDR})`
ip=`hostname -I | awk '{print $1}'`
CIDR=`ip a | grep ${ip} | awk '{print $2}'`
HOSTNAME=`hostname`
ip_list=`cat ${FILE_CONFIG} | grep 'oob_ip'`
set_ip_list=`echo ${ip_list} | awk -F'=' '{print $2}'`
ha_request_id=`cat ${FILE_CONFIG} | grep 'ha_request_id' | awk -F'=' '{print $2}'`
project_id=`cat ${FILE_CONFIG} | grep 'project_id' | awk -F'=' '{print $2}'`
hostname_list=`cat ${FILE_CONFIG} | grep 'host_name=' | awk -F'=' '{print $2}'`
project_owner=`cat ${FILE_CONFIG} | grep 'project_owner=' | awk -F'=' '{print $2}' | awk '{print $1"_"$2}'`
chksum_cfg=`cat ${FILE_CONFIG} | grep 'checksum' | awk -F'sum=' '{print $2}'`
raw_cfg=`cat ${FILE_CONFIG} | grep 'raw=' | awk -F'=' '{print $2}'`
username=`id -u -n`

#echo "IP List :" ${set_ip_list}
#echo "ha_request_id :"${ha_request_id}
#echo "project_id :"${project_id}
#echo "HOSTNAME :"${HOSTNAME}
#echo "IP :"${ip}${CIDR}
#test=192.168.21.2
test=${ip}
#echo ${ip}
num_ip=`echo  ${set_ip_list} | grep ${test}| wc -l`
oob_chk=`echo ${set_ip_list}|sed 's/,/@/g'`
hostname_chk="xqb6Tf2h"${hostname_list}
value_chk=${oob_chk}${hostname_chk}
#echo $value_chk
#echo "============ sha256 =============="
chk_sha256=`echo -n ${value_chk} | sha256sum`
chk_sha256_2=`echo -n $chk_sha256|awk '{print $1}'`
#echo $chk_sha256_2
#echo "============ base64  =============="
chk_base64=`echo -n $chk_sha256_2 | base64`
#echo $chk_base64
chksum=`echo $chk_base64|awk '{print $1$2}'`
#echo $chksum
#echo "============== Config Checksum =============="
#echo ${chksum_cfg}
#echo "============== Config Raw =============="
#echo ${raw_cfg}
#echo "======================================"




if [ $num_ip -gt "0" ] && [ $chksum_cfg == $chksum ]; then
   #echo "ha_request_id :"${ha_request_id}
   #echo "project_id :"${project_id}
   #echo "HOSTNAME :"${HOSTNAME}
   #echo "IP :"${ip} ${CIDR}
   echo 1 $project_owner $project_id $HOSTNAME ${CIDR}
else
   #echo "IP not found in file :"${FILE_CONFIG}
   #echo ${ip_list}
   echo 0
fi
