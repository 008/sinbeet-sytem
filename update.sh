#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh
#@reboot sleep 2 && rm update.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh; bash update.sh

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


#Ubu18 is all we need.



vartest=`cat .sin/sin.conf|grep testnet=1`
if [ -z "$vartest" ]
 then
echo "not testnet" >> status
 else
 #rm update.sh
 echo "********** testnet **********" >> status
 rm testnet.sh
 wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet.sh
 bash testnet.sh
 exit
fi







down() {
			echo "`date` starting down" >> status
			echo "`date` updating node old $curnodever" >> .sin/debug.log
			echo "`date` updating node old $curnodever" >> status
			echo "***************`date` updating node old $curnodever"
			
		
			wget -6 -O cur.zip http://setdown.sinovate.io/sinbeet-sytem/cur/cur.zip

			if [ ! -f "cur.zip" ]; then 
			echo "`date` download node fail, will try later" >> .sin/debug.log
			echo "`date` download node fail, will try later" >> status
			echo "*************** `date` download node fail, will try later"
			exit
			fi
			
			sinstop
			#rm -rf /usr/local/bin/sin-cli
			#rm -rf /usr/local/bin/sind
			rm -rf sin-cli
			rm -rf sind
			
			unzip cur* || apt install unzip -y && unzip cur.zip
			sleep 0.2
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			#rm -rf .sin/*.dat
			echo "`date` updating node DONE new ver $newnodever" >> .sin/debug.log
			echo "*************** `date` updating node DONE new ver $newnodever" >> status
}


sinstop() {
			./sin-cli stop
			   if [ "$?" -ne 0 ]
               then
               echo "cant see ./sin-cli, dont wait for daemon stop."
			   else
			   	while [ -f /root/.sin/sind.pid ]; 
				do
				echo "waiting to stop"
				sleep 0.2
				done
               fi  
			   sleep 5 #to make sure
			   }

sinstart() {

	if [ -a "sind" ]; then 
	echo "************** SIND exist **************"
	echo "************** SIND exist **************" >> status
	else
	echo "************** sind NOT exist **************"
	echo "************** sind NOT exist **************" >> status
	nowait=1
	down
	fi
	

while [ ! -f /root/.sin/sin.conf ]
do
echo "waiting for .conf" >> status
echo "waiting for .conf"
sleep 0.3
done

echo "found .conf" >> status
echo "found .conf"
#start sind only if .conf exist

if [ -a /root/.sin/sin.conf ]
then 
echo "`date` starting sind5 " >> status
echo "*************** `date` starting sind5 ***************"

./sind -dbcache=4 -maxmempool=5 -mempoolexpiry=1 -whitelist=192.168.0.1/24 -disablewallet
#-dbcache=8 -maxmempool=8 -mempoolexpiry=8
#-disablewallet node wont start with this
sleep 100 && ./sin-cli importprivkey `cat /root/.sin/sin.conf|grep infinitynodeprivkey|cut -c 21-72` &
echo importprivkey queued
echo importprivkey queued >> status
echo importprivkey queued >> .sin/debug.log
else
  echo "`date` dont have .conf1" >> status
  echo "***************`date` dont have .conf1 ***************"
exit
fi
}


sinclean() {
sinstop
cd .sin/
mv sin.conf ..
ls | grep -v wallet.dat | xargs rm -rf
mv ../sin.conf . 
cd ..
cd ..
echo "`date` clean done" >> status
echo "***************`date` clean done !!!!!!!!!!!"
sinstart
}

sinerror1() {
var2=`tail .sin/debug.log -n500|grep "please fix it manually"`
if [ -z "$var2" ]
 then
echo "`date` NO error1"
 else
echo "WARNING `date` sinerror1" >> status
echo "`date` file error - please fix it manually" >> status
echo "`date` file error - please fix it manually" >> .sin/debug.log 
sinclean
fi

}

#is marked invalid
sinerror2() {
var2=`tail .sin/debug.log -n500|grep "is marked invalid"`
if [ -z "$var2" ]
 then
echo "`date` NO error2"
 else
 echo "WARNING `date` sinerror2" >> status
echo "`date` AcceptBlockHeader" >> status
echo "`date` found error AcceptBlockHeader" >> .sin/debug.log 
sinclean
fi
}

sinerror3() {
var3=`ps aux|grep sind|wc -l`
if (( $var3 < 2 )); then
echo "WARNING `date` sinerror3" >> status
sinstart
fi
}


sinlog(){
#check if log more then 1G
GOAL=$(stat -c%s .sin/debug.log)
if (( $GOAL > 262144 )); then #256MB
    echo "clear log ***************"
	echo "`date` start clear log" >> status
	echo "clear log" > .sin/debug.log 
else
    echo "log less ***************"
	echo "`date` log less" >> status
	echo "log less" >> .sin/debug.log 
	echo "log less" >> .sin/debug.log 
	echo "log less" >> .sin/debug.log 
fi
}

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
	
	echo "!!! we have .sin.tar.gz" >> status
	echo "!!! we have .sin.tar.gz" >> .sin/debug.log
		
	mv .sin/wallet.dat wallet.dat
	cp .sin/sin.conf sin.conf
	rm .sin/* -rf
	tar -xzvf .sin.tar.gz
	mv wallet.dat .sin/wallet.dat
	cp sin.conf .sin/sin.conf
	rm .sin.tar.gz
	
		else
			echo "no .sin.tar.gz" >> status
			echo "no .sin.tar.gz" >> .sin/debug.log
			echo "no .sin.tar.gz"
		fi


case $1 in
     clean)      
sinclean
;;
     nowait)      
          nowait=1
          ;;
     removedat)
          mv .sin/wallet.dat wallet.dat
		  rm .sin/*
		  mv wallet.dat .sin/wallet.dat
          ;; 
     down)
	rm -rf sin-cli
	rm -rf sind
	 rm cur.zip
	 wget -6 -O cur.zip http://setdown.sinovate.io/sinbeet-sytem/cur/cur.zip
	 unzip cur* || apt install unzip -y && unzip cur.zip
	 sleep 0.2
	 chmod +x sin*
	 echo "`date` forced to download" >> .sin/debug.log
	 exit
	 
          ;;
     prep)
		sinstop
		rm .sin/debug.log 
		rm .sin/wallet.dat
		#rm .sin/sin.conf
		rm cur.zip
		rm status
		echo "removed"
		exit
          ;;
     prepnode)
		sinstop
		rm .sin/debug.log 
		rm .sin/wallet.dat
		#rm .sin/sin.conf
		rm cur.zip
		rm status
		echo "removed"
		exit
          ;;
esac
echo "no param (nowait, removedat, down, pre200, prepnode)"



sinupdate() {
    if [ -a ".sin/cur" ]; then 
	echo "************** cur exist **************"
	
	#if [ -z "$nowait" ]; then
	#echo "************** rand wait  **************"
	#sleep $((RANDOM % 60))
	#fi
	
	    curnodever=$(cat .sin/cur)
		wget -6 -O .sin/new http://setdown.sinovate.io/sinbeet-sytem/ver
		
		if [ -a ".sin/new" ]; then 
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
			sinstart			
			fi
	#exit
    else
	echo "************** cur NOT exist **************"
	wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/ver
	down
	sinstart
	#crontab -l | { cat; echo "0 */3 * * * `pwd`/update.sh"; } | crontab -
    fi

}










#Binding RPC on address 0.0.0.0 port 20981 failed


########################################################################start 

sinerror1
sinlog
sinupdate
sinstart
echo "`date` start seq done" >> status

############cron

sleep 30;sinerror1 &
while sleep 480; do sinerror3; done & #daemon running check
#while sleep 174; do sinerror2; done &
while sleep 1861; do sinlog; done &
while sleep 43200; do sinstop;sinstart;echo "*************** `date` node restart" >> .sin/debug.log; done &







	
	
