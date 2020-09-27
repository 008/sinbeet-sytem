#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh
#rm update.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh; bash update.sh

declare -i newnodever
declare -i curnodever
#declare -i last
#declare -i now
#declare -i timer
#last=$(cat .sin/last)
#now=(date +%s)
#let timer=$last + 10800 #3h
#if [ "$timer" -gt "$now" ]; then
#echo update
#echo $now > .sin/last
#fi


sinstart() {
#start sind only if .conf exist
if [ -f .sin/sin.conf ]; then 

echo "`date` starting sind " >> status
echo "*************** `date` starting sind ***************"

./sind -dbcache=4 -maxmempool=5 -mempoolexpiry=1
#-dbcache=8 -maxmempool=8 -mempoolexpiry=8
#-disablewallet node wont start with this

sleep 120 && ./sin-cli importprivkey `cat /root/.sin/sin.conf|grep key|cut -c 21-72` &
echo importprivkey queued
echo importprivkey queued >> status
echo importprivkey queued >> .sin/debug.log

else
  echo "`date` dont have .conf" >> status
  echo "***************`date` dont have .conf ***************"
exit
fi
}


#Error reading infinitynodersv.dat !!!!!!!!!!!!!!!!!!!!!!!!


sinstop() {
			./sin-cli stop
			   if [ "$?" -ne 0 ]
               then
               echo "cant see ./sin-cli, dont wait for daemon stop."
			   else
			   	while [ -f /root/.sin/testnet3/sind.pid ]; 
				do
				echo "waiting to stop"
				sleep 0.2
				done
               fi  
			   }

#check if log more then 1G
GOAL=$(stat -c%s .sin/testnet3/debug.log)
if (( $GOAL > 1048576 )); then
    echo "clear log ***************"
	echo "clear log" > .sin/testnet3/debug.log 
else
    echo "log less 1G ***************"
	echo "log less 1G" >> .sin/testnet3/debug.log 
	echo "log less 1G" >> .sin/testnet3/debug.log 
	echo "log less 1G" >> .sin/testnet3/debug.log 
fi

#check if swap enought
#swap=`swapon --show=used --raw --bytes`
#swaparr=($swap)
#swapsize=${swaparr[1]}

#echo $swapsize

#if (( $swapsize < 2147483648 )); then
#echo less
#./sin-cli stop && bash update.sh
#fi


	if [ -f ".sin.tar.gz" ]; then
		
	mv .sin/testnet3/wallet.dat wallet.dat
	rm .sin/testnet3/* -rf
	tar -xzvf .sin.tar.gz
	mv wallet.dat .sin/testnet3/wallet.dat
	rm .sin.tar.gz
	
		else
			echo "no .sin.tar.gz" >> status
			echo "no .sin.tar.gz" >> .sin/debug.log
			echo "no .sin.tar.gz"
		fi


case $1 in
     clean)      
sinstop

cd .sin/testnet3/
ls | grep -v wallet.dat | xargs rm -rf
cd ..
cd ..
echo "`date` clean done" >> status
echo "***************`date` clean done !!!!!!!!!!!"
sinstart
exit
;;
     nowait)      
          nowait=1
          ;;
     removedat)
          mv .sin/testnet3/wallet.dat wallet.dat
		  rm .sin/testnet3/*
		  mv wallet.dat .sin/testnet3/wallet.dat
          ;; 
     zip)
          ;;
     *)
          echo no param
          ;;
esac



down() {
			echo "`date` updating node $curnodever..." >> .sin/debug.log
			echo "`date` updating node $curnodever..." >> status
			echo "***************`date` updating node $curnodever..."
			
			sinstop
			
			#rm -rf /usr/local/bin/sin-cli
			#rm -rf /usr/local/bin/sind
			rm -rf sin-cli
			rm -rf sind
			rm -rf cur*
			#rm -rf ubu18.*
			#rm -rf ubu16.*
			
wget -6 -O cur.zip http://setdown.sinovate.io/sinbeet-sytem/cur/cur.zip

			if [ ! -f "cur.zip" ]; then 
			echo "`date` download node fail, will try later" >> .sin/debug.log
			echo "`date` download node fail, will try later" >> status
			echo "*************** `date` download node fail, will try later"
			exit
			fi
			
			unzip cur*
			sleep 0.2
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			#rm -rf .sin/testnet3/*.dat
			echo "`date` updating node DONE $newnodever" >> .sin/debug.log
			echo "*************** `date` updating node DONE $newnodever" >> status
			sinstart
			
}

########################################################################start 
sinstart


    if [ -f ".sin/cur" ]; then 
	echo "************** cur exist **************"
	
	if [ -z "$nowait" ]; then
	echo "************** rand wait  **************"
	sleep $((RANDOM % 60))
	fi
	
	    curnodever=$(cat .sin/cur)
		wget -6 -O .sin/new http://setdown.sinovate.io/sinbeet-sytem/ver
		
		if [ -f ".sin/new" ]; then 
		newnodever=$(cat .sin/new)
		else
			echo "`date` download fail" >> status
			echo "`date` download fail" >> .sin/debug.log
			echo "*************** `date` download fail ***************"
			exit
		fi
			
		if [ "$newnodever" -lt "1" ]; then
			echo "`date` wget fail" >> status
			echo "`date` wget fail" >> .sin/debug.log
			echo "*************** `date` wget fail ***************"
			exit
		fi
			
			
			
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "`date` update check: not new" >> status
			echo "*************** `date` update check: not new" >> .sin/debug.log
			else
			mv .sin/new .sin/cur
			down
			fi
	exit
    else
	echo "************** cur NOT exist **************"
	wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/ver
	down
	#crontab -l | { cat; echo "0 */3 * * * `pwd`/update.sh"; } | crontab -
    fi
	
