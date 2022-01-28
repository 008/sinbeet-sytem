#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet.sh
#rm testnet.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet.sh; bash testnet.sh

#rm -rf .sin/testnet3/

echo "TESTNET TESTNET TESTNET TESTNET TESTNET TESTNET TESTNET TESTNET " >> status
echo "************** `date` testnet2.sh **************" >> status

declare -i newnodever
declare -i curnodever


echo "   " > .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo alias st=\"cat status\" >> .bashrc
echo alias conf=\"cat .sin/sin.conf \" >> .bashrc
echo alias ht=\"htop\" >> .bashrc
echo alias z=\"bash info.sh\" >> .bashrc
echo alias re=\"wget http://setdown.sinovate.io/sinbeet-sytem/.sin.tar.gz\" >> .bashrc
echo alias t1=\"tail .sin/testnet3/debug.log -f\" >> .bashrc
echo alias t2=\"tail .sin/testnet3/debug.log -n2000\" >> .bashrc
echo alias reboot2=\"bash safereboot.sh\" >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "cat /root/.bashrc" >> .bashrc

rm info.sh ver.sh safereboot.sh #added later, remove after update.

echo "./sin-cli infinitynode mypeerinfo" > info.sh
echo "./sin-cli getbalance"  >> info.sh
echo "./sin-cli getblockcount" >> info.sh
echo "date" >> info.sh
echo "./sind -version|grep Daemon| cut -c 20-" >> info.sh
chmod +x info.sh


echo 'for ((n=0;n<1111;n++))' > send
echo 'do' >> send
echo './sin-cli sendtoaddress SfGLjM4PaUmrV5Jq6ec9GKbnCECcC859AV 5' >> send
echo 'sleep 0.25' >> send
echo 'done' >> send

chmod +x send




#echo "********** starting testnet2.sh **********" >> status

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
				echo "************** daemon stop **************"
               fi  
			   
			   }

sinstart() {

	if [ -f "sind" ]; then 
	echo "************** sinD exist **************"
	echo "************** sinD exist **************" >> status
	else
	echo "************** sind NOT exist **************"
	echo "************** sind NOT exist **************" >> status
	nowait=1
	down
	fi
	
	
#start sind only if .conf exist
if [ -f .sin/sin.conf ]; then 

echo "`date` starting sin " >> status
echo "*************** `date` starting sin ***************"
chmod +x sin*

./sind -daemon -staking=0 #-fallbackfee=0.025 -paytxfee=0.025

 #-dbcache=4 -maxmempool=5 -mempoolexpiry=1 -whitelist=192.168.0.1/24
#-dbcache=8 -maxmempool=8 -mempoolexpiry=8
#-disablewallet node wont start with this

sleep 100 && ./sin-cli importprivkey `cat /root/.sin/sin.conf|grep infinitynodeprivkey|cut -c 21-72` &
#echo importprivkey queued
#echo importprivkey queued >> status
#echo importprivkey queued >> .sin/debug.log

else
  echo "`date` dont have .conf" >> status
  echo "***************`date` dont have .conf ***************"
exit
fi

echo "*************** `date` starting sin done **********"
}

dnscheck(){
echo "nameserver 2606:4700:4700::64" >> /etc/resolv.conf
echo "nameserver 2606:4700:4700::1111" >> /etc/resolv.conf
echo "nameserver 2606:4700:4700::1001" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
}


sinclean() {
sinstop
cd .sin/testnet3/
ls | grep -v wallet.dat | xargs rm -rf
cd ..
cd ..
echo "`date` clean done" >> status
echo "***************`date` clean done !!!!!!!!!!!"
sinstart
}



sinerror1() {
var2=`tail .sin/testnet3/debug.log -n500|grep "please fix it manually"`
if [ -z "$var2" ]
 then
echo "`date` NO error1"
 else
echo "WARNING `date` sinerror1" >> status
echo "`date` file error - please fix it manually" >> status
echo "`date` file error - please fix it manually" >> .sin/testnet3/debug.log 
sinclean
fi

}

#is marked invalid
sinerror2() {
var2=`tail .sin/testnet3/debug.log -n500|grep "is marked invalid"`
if [ -z "$var2" ]
 then
echo "`date` NO error2"
 else
 echo "WARNING `date` sinerror2" >> status
echo "`date` AcceptBlockHeader" >> status
echo "`date` found error AcceptBlockHeader" >> .sin/testnet3/debug.log 
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
GOAL=$(stat -c%s .sin/testnet3/debug.log)
if (( $GOAL > 1048576 )); then
    echo "clear log ***************"
	echo "`date` start clear log" >> status
	echo "clear log" > .sin/testnet3/debug.log 
else
    echo "log less 1G ***************"
	echo "`date` log less 1G" >> status
	echo "log less 1G" >> .sin/testnet3/debug.log 
	echo "log less 1G" >> .sin/testnet3/debug.log 
	echo "log less 1G" >> .sin/testnet3/debug.log 
fi
}

#check if swap enought
#swap=`swapon --show=used --raw --bytes`
#swaparr=($swap)
#swapsize=${swaparr[1]}

#echo $swapsize

#if (( $swapsize < 2147483648 )); then
#echo less
#./sin-cli stop && bash testnet.sh
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
sinclean
exit
;;
     nowait)      
          nowait=1
		  down
		  sinstart
          ;;
     removedat)
          mv .sin/testnet3/wallet.dat wallet.dat
		  rm .sin/testnet3/*
		  mv wallet.dat .sin/testnet3/wallet.dat
          ;; 
     down)
	 rm testnet.zip
	 rm sin*
	 wget -6 -O testnet.zip http://setdown.sinovate.io/sinbeet-sytem/cur/testnet.zip
	 unzip testnet.zip
	 sleep 0.2
	 chmod +x sin*
	 echo "`date` forced to download" >> .sin/debug.log
	 exit
	 
          ;;
     *)
          echo no param
          ;;
esac



down() {
echo "`date` starting down" >> status

if [[ `wget -N http://testnetcomp.sinovate.io/latest/daemon.zip  2>&1 | grep '304 Not Modified'` ]]; 
then 
echo "`date` update check: 304 not new" >> status
else
			if [ ! -f "daemon.zip" ]; then 
			echo "`date` download node fail, will try later" >> .sin/testnet3/debug.log
			echo "`date` download node fail, will try later" >> status
			echo "*************** `date` download node fail, will try later"
			exit
			fi

			sinstop
			rm sin-cli sind
			unzip daemon.zip
			sleep 0.2
			chmod +x sin*
			echo "`date` updating daemon DONE " >> .sin/testnet3/debug.log
			echo "*************** `date` updating daemon DONE" >> status
			
			sinstart
fi

			# echo "`date` starting down" >> status
			# echo "`date` updating node $curnodever..." >> .sin/testnet3/debug.log
			# echo "`date` updating node $curnodever..." >> status
			# echo "***************`date` updating node $curnodever..."
			
		
			# wget -6 -O testnet.zip http://setdown.sinovate.io/sinbeet-sytem/cur/testnet.zip

			# if [ ! -f "testnet.zip" ]; then 
			# echo "`date` download node fail, will try later" >> .sin/testnet3/debug.log
			# echo "`date` download node fail, will try later" >> status
			# echo "*************** `date` download node fail, will try later"
			# exit
			# fi
			
			# sinstop
			# rm -rf sin-cli
			# rm -rf sind
			
			# unzip testnet.zip
			# sleep 0.2
			# chmod +x sin*
			# echo "`date` updating node DONE $newnodever" >> .sin/testnet3/debug.log
			# echo "*************** `date` updating node DONE $newnodever" >> status
			
			# sinstart
} #end down

nodeprepare(){
echo "`date` start nodeprepare" >> status
ip6tables -t nat -I PREROUTING -i eth0 -p tcp -m tcp --dport 20971 -j REDIRECT --to-ports 20981 
sleep 10 && ./sin-cli createwallet 01 && echo "`date` createwallet done" >> status
sleep 10 && ./sin-cli loadwallet 01 && echo "`date` loadwallet done" >> status
sleep 10 && ip6tables -t nat -I PREROUTING -i eth0 -p tcp -m tcp --dport 20971 -j REDIRECT --to-ports 20981 && echo "`date` ip6tables" >> status
#sleep 60 && ./sin-cli settxfee 0.025 && echo "`date` settxfee 0.025 done" >> status &
}
#Binding RPC on address 0.0.0.0 port 20981 failed

cronjob(){
############cron
sleep 121
echo "@reboot sleep 23 && ping6 google.com -c 3; rm update.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh; bash update.sh" > cron
echo "@reboot sleep 9 && ip6tables -t nat -I PREROUTING -i eth0 -p tcp -m tcp --dport 20971 -j REDIRECT --to-ports 20981" >> cron
crontab cron
}

#sleep 30;sinerror1 &
#while sleep 480; do sinerror3; done & #daemon running check
#while sleep 1740; do sinerror2; done &
#while sleep 3530; do sinlog; done &
#while sleep 43200; do sinstop;sinstart;echo "*************** `date` node restart" >> .sin/debug.log; done &






    # if [ -f ".sin/cur" ]; then 
	# echo "************** cur exist **************"
	
	# if [ -z "$nowait" ]; then
	# echo "************** rand wait  **************"
	# sleep $((RANDOM % 10))
	# fi
	
	    # curnodever=$(cat .sin/cur)
		# wget -6 -O .sin/new http://setdown.sinovate.io/sinbeet-sytem/testver
		
		# if [ -f ".sin/new" ]; then 
		# newnodever=$(cat .sin/new)
		# else
			# echo "`date` download fail" >> status
			# echo "`date` download fail" >> .sin/testnet3/debug.log
			# echo "*************** `date` download fail ***************"
			# exit
		# fi
			
		# if [ "$newnodever" -lt "1" ]; then
			# echo "`date` wget fail" >> status
			# echo "`date` wget fail" >> .sin/testnet3/debug.log
			# echo "*************** `date` wget fail ***************"
			# exit
		# fi
			
			
			
		    # if [ "$curnodever" -eq "$newnodever" ]; then
			# echo "`date` update check: not new" >> status
			# echo "*************** `date` update check: not new" >> .sin/testnet3/debug.log
			# else
			# mv .sin/new .sin/cur
			# down
			# fi
	
    # else
	# echo "************** cur NOT exist **************"
	# wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/testver
	# down
    # fi
	
	
########################################################################start 
#sinerror
#sinlog
down
dnscheck
sinstart
nodeprepare &
cronjob &


#ip6tables -t nat -I PREROUTING -i eth0 -p tcp -m tcp --dport 20971 -j REDIRECT --to-ports 20981
#apt-get install iptables-persistent
#ip6tables-save > /etc/iptables/rules.v6
#memo
echo "`date` start seq done" >> status
