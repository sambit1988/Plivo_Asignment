#!/bin/bash

hostname=phone.plivo.com
remote_public_ip=`dig +short $hostname`
local_ip=`wget -qO- http://instance-data/latest/meta-data/local-ipv4`
local_public_ip=`wget -qO- http://instance-data/latest/meta-data/public-ipv4`



echo -e "\t\t \033[0;33m Starting Registration for Callee and Caller :`date` \033[0m "

./Register_Callee_Caller.sh

echo -e "\t\t \033[0;33m Starting Caller script : `date`\033[0m "

if [ `cat .REG_STATUS ` == FAIL ]  ;then  echo -e "\n\t\t \033[1;31m REG Failed, Call will skipped\033[0m \n" ; exit 1; fi

./MT_Call.sh

sleep 1s
echo -e "\t\t \033[0;33m Starting Callee script : `date` \033[0m "

./MO_Call.sh 


while ps -p `cat .MO_SIPP_PID` &>/dev/null; do kill -9 `cat .MO_SIPP_PID` ; sleep 1; done
while ps -p `cat .MT_SIPP_PID` &>/dev/null; do kill -9 `cat .MT_SIPP_PID` ; sleep 1; done


callee_recv_invite_time=`grep INVITE_RECV_TIME SIPP_LOGS.txt | cut -f "2,3,4" -d "="`
caller_recv_200OK_time=`grep INVITE_ANSWER_TIME SIPP_LOGS.txt | cut -f "2" -d "="`
callee_bye_sent_time=`grep BYE_SENT_TIME SIPP_LOGS.txt | cut -f "2" -d "="`
call_start_time=`grep CALL_STARTED SIPP_LOGS.txt | cut -f "2" -d "="`
call_end_time=`grep CALL_TERM SIPP_LOGS.txt | cut -f "2" -d "="`
Call_Duration=`expr ${call_end_time} - ${call_start_time}`

echo -e "\033[1;34m \t\t==========================================================="
echo -e "\t\tCapturing Call time and duration report"
echo -e "\t\tTime at which callee received the INVITE : $callee_recv_invite_time " 
echo -e "\t\tTime at which caller received 200OK : $caller_recv_200OK_time "
echo -e "\t\tTime at which BYE was sent to caller : $callee_bye_sent_time "
echo -e "\t\tTotal duration of the call : $Call_Duration secs"
echo -e "\t\tEnd of the report"
echo -e "\t\t===========================================================  \033[0m "