#!/bin/bash

hostname=phone.plivo.com
remote_public_ip=`dig +short $hostname`
local_ip=`wget -qO- http://instance-data/latest/meta-data/local-ipv4`
local_public_ip=`wget -qO- http://instance-data/latest/meta-data/public-ipv4`


rm -rf MT_*_messages.log
rm -rf MT_*_errors.log

MT_PID=`./sipp -sf MT.xml -inf Callee_Caller.csv -m 3 -t u1 -i $local_ip -p 5061 $remote_public_ip:5060 -aa -trace_msg -trace_err -bg`

echo $MT_PID | awk '$0=$2' FS=[ RS=] > .MT_SIPP_PID

echo -e "\t\t \033[1;32m Started Caller script with PID `cat .MT_SIPP_PID`  \033[0m \n"

rm -rf MT_*_errors.log