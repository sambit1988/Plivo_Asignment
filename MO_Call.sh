#!/bin/bash

hostname=phone.plivo.com
remote_public_ip=`dig +short $hostname`
local_ip=`wget -qO- http://instance-data/latest/meta-data/local-ipv4`
local_public_ip=`wget -qO- http://instance-data/latest/meta-data/public-ipv4`


rm -rf MO_*_messages.log
rm -rf MO_*_errors.log

MO_PID=`./sipp -sf MO.xml -inf Callee_Caller.csv -nd -m 1 -r 1 -t u1 -i $local_ip -p 5060 $remote_public_ip:5060 -mp 2000 -aa -trace_msg -trace_err -bg`

echo $MO_PID | awk '$0=$2' FS=[ RS=] > .MO_SIPP_PID

echo -e "\t\t \033[1;32m Started Callee script with PID `cat .MO_SIPP_PID` \033[0m \n"

#while ps -p `cat .MO_SIPP_PID` &>/dev/null; do echo -e "\n\t\t \033[1;33m sipp is still running \033[0m"; sleep 10; done

a=0
while [ $a -lt 10 ]
do 
    if ps -p `cat .MO_SIPP_PID` &>/dev/null; then echo -e "\n\t\t \033[1;33m sipp is still running \033[0m"; sleep 10; fi   
    a=`expr $a + 1`
    if [ $a -eq 10 ]; then echo -e "\n\t\t \033[1;33m Call is completed or wait timer is timeout, if any sipp processes running will be killed \033[0m" ; fi
done

sed -i '/Automatic response mode for an unexpected INFO, NOTIFY, OPTIONS or UPDATE\|The following events occurred/d' *_errors.log


if [ ! -s MO_*_errors.log ] ; then rm -rf MO_*_errors.log; fi
if [ ! -s MT_*_errors.log ] ; then rm -rf MT_*_errors.log; fi


if  [ -f MO_*_errors.log ] || [ -f MT_*_errors.log ] ; then
	echo -e "\n\t\t \033[1;31m Call Failed \033[0m \n"
else 
    echo -e "\n\t\t \033[1;32m Call Success \033[0m \n" 
fi