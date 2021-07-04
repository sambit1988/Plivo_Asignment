#!/bin/bash

hostname=phone.plivo.com
remote_public_ip=`dig +short $hostname`
local_ip=`wget -qO- http://instance-data/latest/meta-data/local-ipv4`
local_public_ip=`wget -qO- http://instance-data/latest/meta-data/public-ipv4`

rm -rf Register_Calle*_messages.log
rm -rf Register_Calle*_errors.log

echo -e "\t\t \033[0;33m Starting Registration for Caller :`date` \033[0m "

Caller_REG_PID=`./sipp -sf Register_Caller.xml -inf Caller.csv -nd -m 1 -aa -r 1 -t u1 -i $local_ip -p 5060 $remote_public_ip:5060  -trace_msg -trace_err -bg`
echo $Caller_REG_PID | awk '$0=$2' FS=[ RS=] > .Caller_REG_PID

echo -e "\t\t \033[0;33m Starting Registration for Callee :`date` \033[0m "
Callee_REG_PID=`./sipp -sf Register_Callee.xml -inf Callee.csv -nd -m 1 -aa -r 1 -t u1 -i $local_ip -p 5061 $remote_public_ip:5060  -trace_msg -trace_err -bg`
echo $Callee_REG_PID | awk '$0=$2' FS=[ RS=] > .Callee_REG_PID


while ps -p `cat .Callee_REG_PID` &>/dev/null; do echo -e "\n\t\t \033[1;33m sipp is still running \033[0m \n";     sleep 2; done
while ps -p `cat .Callee_REG_PID` &>/dev/null; do echo -e "\n\t\t \033[1;33m sipp is still running \033[0m \n";     sleep 2; done

while ps -p `cat .Callee_REG_PID` &>/dev/null; do kill -9 `cat .Callee_REG_PID` ; sleep 1; done
while ps -p `cat .Callee_REG_PID` &>/dev/null; do kill -9 `cat .Callee_REG_PID` ; sleep 1; done


if [ -f Register_Caller_*_errors.log ]; then
    echo -e "\t\t \033[1;31m Caller REGISTER is Failed \033[0m \n"
else 
    echo -e "\t\t \033[1;32m Caller REGISTER is Success \033[0m \n"
fi

if [ -f Register_Callee_*_errors.log ]; then
    echo -e "\t\t \033[1;31m Callee REGISTER is Failed \033[0m \n"
else 
    echo -e "\t\t \033[1;32m Callee REGISTER is Success \033[0m \n"
fi


if  [ -f Register_Caller_*_errors.log ] || [ -f Register_Calle3_*_errors.log ] ; then
	echo FAIL > .REG_STATUS
else
	echo PASS > .REG_STATUS
fi

rm -rf Register_Calle*_errors.log