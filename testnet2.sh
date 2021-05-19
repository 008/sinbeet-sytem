#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet.sh
#rm testnet.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet.sh; bash testnet.sh

echo "************** `date` testnet2.sh started **************" >> status

declare -i newnodever
declare -i curnodever


echo "   " > .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo alias st=\"cat status\" >> .bashrc
echo alias conf=\"cat .bitcoin/bitcoin.conf \" >> .bashrc
echo alias ht=\"htop\" >> .bashrc 
echo alias z=\"bash info.sh\" >> .bashrc 
echo alias re=\"wget http://setdown.sinovate.io/sinbeet-sytem/.sin.tar.gz\" >> .bashrc 
echo alias t1=\"tail .bitcoin/debug.log -f\" >> .bashrc 
echo alias t2=\"tail .bitcoin/debug.log -n2000\" >> .bashrc 
echo alias reboot2=\"bash safereboot.sh\" >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "cat /root/.bashrc" >> .bashrc


rm /root/.bashrc
touch /root/.bashrc

rm info.sh ver.sh safereboot.sh #added later, remove after update.

echo "./bitcoin-cli infinitynode mypeerinfo" > info.sh
echo "./bitcoin-cli getbalance"  >> info.sh
echo "./bitcoin-cli getblockcount" >> info.sh
echo "date" >> info.sh
echo "./bitcoind -version|grep Daemon| cut -c 20-" >> info.sh
chmod +x info.sh



echo "********** starting testnet2.sh **********" >> status

bitcoinstop() {
			./bitcoin-cli stop
			   if [ "$?" -ne 0 ]
               then
               echo "cant see ./bitcoin-cli, dont wait for daemon stop."
			   else
			   	while [ -f /root/.bitcoin/testnet3/bitcoind.pid ]; 
				do
				echo "waiting to stop"
				sleep 0.2
				done
				echo "************** daemon stop **************"
               fi  
			   
			   }

bitcoinstart() {

	if [ -f "bitcoind" ]; then 
	echo "************** bitcoinD exist **************"
	echo "************** bitcoinD exist **************" >> status
	else
	echo "************** bitcoind NOT exist **************"
	echo "************** bitcoind NOT exist **************" >> status
	nowait=1
	down
	fi
	
	
#start bitcoind only if .conf exist
if [ -f .bitcoin/bitcoin.conf ]; then 

echo "`date` starting bitcoin " >> status
echo "*************** `date` starting bitcoin ***************"
chmod +x bitcoin*

./bitcoind -daemon -fallbackfee=0.025 -paytxfee=0.025

 #-dbcache=4 -maxmempool=5 -mempoolexpiry=1 -whitelist=192.168.0.1/24
#-dbcache=8 -maxmempool=8 -mempoolexpiry=8
#-disablewallet node wont start with this

sleep 100 && ./bitcoin-cli importprivkey `cat /root/.bitcoin/bitcoin.conf|grep infinitynodeprivkey|cut -c 21-72` &
#echo importprivkey queued
#echo importprivkey queued >> status
#echo importprivkey queued >> .bitcoin/debug.log

else
  echo "`date` dont have .conf" >> status
  echo "***************`date` dont have .conf ***************"
exit
fi
}


bitcoinclean() {
bitcoinstop
cd .bitcoin/testnet3/
ls | grep -v wallet.dat | xargs rm -rf
cd ..
cd ..
echo "`date` clean done" >> status
echo "***************`date` clean done !!!!!!!!!!!"
bitcoinstart
}



bitcoinerror1() {
var2=`tail .bitcoin/testnet3/debug.log -n500|grep "please fix it manually"`
if [ -z "$var2" ]
 then
echo "`date` NO error1"
 else
echo "WARNING `date` bitcoinerror1" >> status
echo "`date` file error - please fix it manually" >> status
echo "`date` file error - please fix it manually" >> .bitcoin/testnet3/debug.log 
bitcoinclean
fi

}

#is marked invalid
bitcoinerror2() {
var2=`tail .bitcoin/testnet3/debug.log -n500|grep "is marked invalid"`
if [ -z "$var2" ]
 then
echo "`date` NO error2"
 else
 echo "WARNING `date` bitcoinerror2" >> status
echo "`date` AcceptBlockHeader" >> status
echo "`date` found error AcceptBlockHeader" >> .bitcoin/testnet3/debug.log 
bitcoinclean
fi
}

bitcoinerror3() {
var3=`ps aux|grep bitcoind|wc -l`
if (( $var3 < 2 )); then
echo "WARNING `date` bitcoinerror3" >> status
bitcoinstart
fi
}


bitcoinlog(){
#check if log more then 1G
GOAL=$(stat -c%s .bitcoin/testnet3/debug.log)
if (( $GOAL > 1048576 )); then
    echo "clear log ***************"
	echo "`date` start clear log" >> status
	echo "clear log" > .bitcoin/testnet3/debug.log 
else
    echo "log less 1G ***************"
	echo "`date` log less 1G" >> status
	echo "log less 1G" >> .bitcoin/testnet3/debug.log 
	echo "log less 1G" >> .bitcoin/testnet3/debug.log 
	echo "log less 1G" >> .bitcoin/testnet3/debug.log 
fi
}

#check if swap enought
#swap=`swapon --show=used --raw --bytes`
#swaparr=($swap)
#swapsize=${swaparr[1]}

#echo $swapsize

#if (( $swapsize < 2147483648 )); then
#echo less
#./bitcoin-cli stop && bash testnet.sh
#fi


	if [ -f ".bitcoin.tar.gz" ]; then
		
	mv .bitcoin/testnet3/wallet.dat wallet.dat
	rm .bitcoin/testnet3/* -rf
	tar -xzvf .bitcoin.tar.gz
	mv wallet.dat .bitcoin/testnet3/wallet.dat
	rm .bitcoin.tar.gz
	
		else
			echo "no .bitcoin.tar.gz" >> status
			echo "no .bitcoin.tar.gz" >> .bitcoin/debug.log
			echo "no .bitcoin.tar.gz"
		fi


case $1 in
     clean)      
bitcoinclean
;;
     nowait)      
          nowait=1
		  down
		  bitcoinstart
          ;;
     removedat)
          mv .bitcoin/testnet3/wallet.dat wallet.dat
		  rm .bitcoin/testnet3/*
		  mv wallet.dat .bitcoin/testnet3/wallet.dat
          ;; 
     down)
	 rm testnet.zip
	 rm bitcoin*
	 wget -6 -O testnet.zip http://setdown.sinovate.io/sinbeet-sytem/cur/testnet.zip
	 unzip testnet.zip
	 sleep 0.2
	 chmod +x bitcoin*
	 echo "`date` forced to download" >> .bitcoin/debug.log
	 exit
	 
          ;;
     *)
          echo no param
          ;;
esac



down() {
			echo "`date` starting down" >> status
			echo "`date` updating node $curnodever..." >> .bitcoin/testnet3/debug.log
			echo "`date` updating node $curnodever..." >> status
			echo "***************`date` updating node $curnodever..."
			
		
			wget -6 -O testnet.zip http://setdown.sinovate.io/sinbeet-sytem/cur/testnet.zip

			if [ ! -f "testnet.zip" ]; then 
			echo "`date` download node fail, will try later" >> .bitcoin/testnet3/debug.log
			echo "`date` download node fail, will try later" >> status
			echo "*************** `date` download node fail, will try later"
			exit
			fi
			
			bitcoinstop
			#rm -rf /usr/local/bin/bitcoin-cli
			#rm -rf /usr/local/bin/bitcoind
			rm -rf bitcoin-cli
			rm -rf bitcoind
			
			unzip testnet.zip
			sleep 0.2
			chmod +x bitcoin*
			#install -c bitcoin-cli /usr/local/bin/bitcoin-cli
			#install -c bitcoind /usr/local/bin/bitcoind
			#service bitcoind start || bitcoind
			#rm -rf .bitcoin/testnet3/*.dat
			echo "`date` updating node DONE $newnodever" >> .bitcoin/testnet3/debug.log
			echo "*************** `date` updating node DONE $newnodever" >> status
			
			bitcoinstart
}

nodeprepare(){
sleep 40 && ./bitcoin-cli createwallet 01 && echo "`date` createwallet done" >> status &
sleep 50 && ./bitcoin-cli loadwallet 01 && echo "`date` loadwallet done" >> status &
sleep 60 && ./bitcoin-cli settxfee 0.025 && echo "`date` settxfee 0.025 done" >> status &
}
#Binding RPC on address 0.0.0.0 port 20981 failed


########################################################################start 

#bitcoinerror
#bitcoinlog
bitcoinstart
nodeprepare
echo "`date` start seq done" >> status

############cron

#sleep 30;bitcoinerror1 &
#while sleep 480; do bitcoinerror3; done & #daemon running check
#while sleep 1740; do bitcoinerror2; done &
#while sleep 3530; do bitcoinlog; done &
#while sleep 43200; do bitcoinstop;bitcoinstart;echo "*************** `date` node restart" >> .bitcoin/debug.log; done &






    if [ -f ".bitcoin/cur" ]; then 
	echo "************** cur exist **************"
	
	if [ -z "$nowait" ]; then
	echo "************** rand wait  **************"
	sleep $((RANDOM % 60))
	fi
	
	    curnodever=$(cat .bitcoin/cur)
		wget -6 -O .bitcoin/new http://setdown.sinovate.io/sinbeet-sytem/testver
		
		if [ -f ".bitcoin/new" ]; then 
		newnodever=$(cat .bitcoin/new)
		else
			echo "`date` download fail" >> status
			echo "`date` download fail" >> .bitcoin/testnet3/debug.log
			echo "*************** `date` download fail ***************"
			exit
		fi
			
		if [ "$newnodever" -lt "1" ]; then
			echo "`date` wget fail" >> status
			echo "`date` wget fail" >> .bitcoin/testnet3/debug.log
			echo "*************** `date` wget fail ***************"
			exit
		fi
			
			
			
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "`date` update check: not new" >> status
			echo "*************** `date` update check: not new" >> .bitcoin/testnet3/debug.log
			else
			mv .bitcoin/new .bitcoin/cur
			down
			fi
	exit
    else
	echo "************** cur NOT exist **************"
	wget -6 -O .bitcoin/cur http://setdown.sinovate.io/sinbeet-sytem/testver
	down
	#crontab -l | { cat; echo "0 */3 * * * `pwd`/update.sh"; } | crontab -
    fi
	
	
