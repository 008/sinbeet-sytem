#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh
#@reboot sleep 6 && ping6 google.com -c 5; rm update.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh; bash update.sh
echo "`date` <<<<<<<<<<<< starting script >>>>>>>>>>>" >> status

declare -i newnodever
declare -i curnodever
declare -i loading
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

systemctl disable syslog
systemctl disable rsyslog

echo "   " > .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo alias st=\"tail -fn300 status\" >> .bashrc
echo alias ht=\"htop\" >> .bashrc 
echo alias z=\"bash info.sh\" >> .bashrc 
echo alias re=\"wget https://github.com/SINOVATEblockchain/SIN-core/releases/download/v1.0.0.2/bootstrap.7z\" >> .bashrc 
echo alias rew=\"touch bpart.zip\" >> .bashrc
echo alias t1=\"tail .sin/debug.log -f\" >> .bashrc 
echo alias t2=\"tail .sin/debug.log -n2000\" >> .bashrc 
echo alias reboot2=\"bash safereboot.sh\" >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "   " >> .bashrc
echo "cat /root/.bashrc" >> .bashrc

#memos
#Ubu18 is all we need. With U18 no additional libs install needed.
#valgrind --leak-check=full \--show-leak-kinds=all \--track-origins=yes \--verbose \--log-file=valgrind-out.txt \./sind -daemon
#gdb --args ./sind -daemon
	

#com helpers
rm info.sh ver.sh safereboot.sh #added later, remove after update.

if [ ! -f info.sh ]; then 
echo "./sin-cli infinitynode mypeerinfo" > info.sh
echo "./sin-cli getbalance"  >> info.sh
echo "./sin-cli getblockcount" >> info.sh
echo "date" >> info.sh
echo "./sind -version|grep Daemon| cut -c 20-" >> info.sh
chmod +x info.sh
fi

if [ ! -f ver.sh ]; then 
echo "./sind -version|grep Daemon| cut -c 20-" >> ver.sh
chmod +x ver.sh
fi


if [ ! -f safereboot.sh ]; then 
echo "bash update.sh safereboot" >> safereboot.sh
chmod +x safereboot.sh
fi


#vartest=`cat .sin/sin.conf|grep testnet=1`
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


vartest=`cat .sin/sin.conf|grep testnet=1`
if [ -z "$vartest" ]
 then
echo "not testnet" >> status
 else
 #rm update.sh
 echo "********** testnet2 **********" >> status
 rm testnet2.sh
 wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet2.sh
 bash testnet2.sh
 exit
fi

backconf() {
mv .sin/wallet.dat wallet.dat
cp .sin/sin.conf sin.conf
cp .sin/sin.conf sin.conf.back
rm .sin/* -rf
}

import(){
echo "`date` importprivkey check wait phase" >> status
sleep 200
./sin-cli importprivkey `cat /root/.sin/sin.conf|grep infinitynodeprivkey|cut -c 21-72`
echo "`date` importprivkey check1" >> status
echo "`date` importprivkey check1" >> .sin/debug.log
sleep 300
./sin-cli importprivkey `cat /root/.sin/sin.conf|grep infinitynodeprivkey|cut -c 21-72`
echo "`date` importprivkey check2" >> status
echo "`date` importprivkey check2" >> .sin/debug.log
sleep 1200
./sin-cli importprivkey `cat /root/.sin/sin.conf|grep infinitynodeprivkey|cut -c 21-72`
echo "`date` importprivkey check3" >> status
echo "`date` importprivkey check3" >> .sin/debug.log
}




down() {
			echo "`date` starting down" >> status
			echo "`date` updating node old $curnodever" >> .sin/debug.log
			echo "`date` updating node old $curnodever" >> status
			echo "***************`date` updating node old $curnodever"
			
			rm cur.zip
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
			
			unzip cur* || apt install unzip -y
			unzip cur.zip
			sleep 0.2
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			#rm -rf .sin/*.dat
			ver=`./sind -version|grep Daemon| cut -c 20-`
			echo "`date` updating node DONE new ver $newnodever $ver" >> .sin/debug.log
			echo "*************** `date` updating node DONE new ver $newnodever $ver" >> status
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


#debug
if [ -a /root/storage/SIN-core/src/sind ]
then 
rm sind; rm sin-cli
cp /root/storage/SIN-core/src/sind sind ; cp /root/storage/SIN-core/src/sin-cli sin-cli
chmod +x sin-cli ; chmod +x sind
echo "`date` debug src enabled" >> status
echo "`date` debug src enabled"
else
echo "`date` debug src NOT enabled"
fi



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

ver=`./sind -version|grep Daemon| cut -c 20-`
if [ -a /root/.sin/sin.conf ]
then 
echo "`date` starting $ver " >> status
echo "*************** `date` starting $ver ***************"

chmod +x sin-cli ; chmod +x sind
rm .sin/peers.dat

cd /root/
if [ -f "bootstrap.7z" ]; then
echo "daemon start wait for bootstrap.7z removed" >> status
echo "daemon start wait for bootstrap.7z removed"
else
echo "no bootstrap.7z starting daemon" >> status
echo "no bootstrap.7z starting daemon"
./sind -turnoffmasternode=1 -masternode=0 -debug=0
echo "`date` starting $ver done" >> status
fi
# -dbcache=200 -maxmempool=100 -mempoolexpiry=36 -par=4 -timeout=1000 

#-dbcache=100 -maxmempool=10 -mempoolexpiry=3 -par=4 -timeout=1000 -debug=0
#-maxconnections=32
# -dbcache=100 -maxmempool=5 -mempoolexpiry=1 -whitelist=192.168.0.1/24 -masternode=0
#-disablewallet
#-dbcache=8 -maxmempool=8 -mempoolexpiry=8
#-disablewallet node wont start with this
#./sind -rpcthreads=8 -logips -par=4 -timeout=500
else
  echo "`date` dont have .conf1" >> status
  echo "***************`date` dont have .conf1 ***************"
exit
fi
}

sinaddnodes() {
./sin-cli addnode 168.119.239.82 add
./sin-cli addnode 104.248.195.254 add
./sin-cli addnode 149.202.74.5 add
}


sinclean() {
sinstop
cd .sin/
mv sin.conf ..
mv cur ..
ls | grep -v wallet.dat | xargs rm -rf
mv ../sin.conf . 
mv ../cur .
cd ..
echo "`date` clean done" >> status
echo "***************`date` clean done !!!!!!!!!!!"
}

sinautobootstrapOLD() {
sinstop
echo "`date` sinautobootstrap started" >> status
echo "***************`date` sinautobootstrap started"
rm .sin.tar.gz
if wget http://setdown.sinovate.io/sinbeet-sytem/.sin.tar.gz ; then
	echo "`date` sinautobootstrap done - rebooting in 60 sec" >> status
	echo "***************`date` sinautobootstrap done - rebooting in 60 sec"
	sleep 60 && /sbin/reboot --force
	else
    echo "`date` sinautobootstrap WGET FAIL" >> status
	echo "***************`date` sinautobootstrap WGET FAIL reboot in 300 sec"
	sleep 300 && /sbin/reboot --force
	fi
}

sinautobootstrap() {
sinstop
echo "`date` sinautobootstrap started" >> status
echo "***************`date` sinautobootstrap started"
#backconf
sinclean
apt install curl
rm bootstrap.7z
if curl -J -O https://bootstrap.sinovate.io/index.php/s/tdqOuaXAYPgKx9d/download ; then
	echo "`date` sinautobootstrap done - rebooting in 60 sec" >> status
	echo "***************`date` sinautobootstrap done - rebooting in 60 sec"
	sleep 60 && /sbin/reboot --force
	else
    echo "`date` sinautobootstrap WGET FAIL" >> status
	echo "***************`date` sinautobootstrap WGET FAIL reboot in 300 sec"
	sleep 300 && /sbin/reboot --force
	fi
}





sinerror1() {
var2=`tail .sin/debug.log -n500|grep -a "please fix it manually"`
if [ -z "$var2" ]
 then
echo "`date` NO error1"
echo "`date` NO error1" >> .sin/debug.log 
echo "`date` NO error1" >> status
 else
echo "WARNING `date` sinerror1" >> status
echo "`date` file error - please fix it manually" >> status
echo "`date` file error - please fix it manually" >> .sin/debug.log 
echo "`date` starting sinautobootstrap" >> status
echo "`date` starting sinautobootstrap" >> .sin/debug.log 
sinautobootstrap
fi
}

sinerror11() {
var11=`tail .sin/debug.log -n500|grep -a "Corrupted block database detected"`
if [ -z "$var11" ]
 then
echo "`date` NO error11"
echo "`date` NO error11" >> .sin/debug.log 
echo "`date` NO error11" >> status
 else
echo "WARNING `date` sinerror11" >> status
echo "`date` file error - Corrupted db" >> status
echo "`date` file error - Corrupted db" >> .sin/debug.log 
echo "`date` starting sinautobootstrap" >> status
echo "`date` starting sinautobootstrap" >> .sin/debug.log 
sinautobootstrap
fi
}

sinerror111() {
var111=`tail .sin/debug.log -n500|grep -a "EXCEPTION: 15dbwrapper_error"`
if [ -z "$var111" ]
 then
echo "`date` NO error111"
echo "`date` NO error111" >> .sin/debug.log 
echo "`date` NO error111" >> status
 else
echo "WARNING `date` sinerror111" >> status
echo "`date` file error - 15dbwrapper_error" >> status
echo "`date` file error - 15dbwrapper_error" >> .sin/debug.log 
echo "`date` starting sinautobootstrap" >> status
echo "`date` starting sinautobootstrap" >> .sin/debug.log 
sinautobootstrap
fi
}


sinerror1112() {
var1112=`tail .sin/debug.log -n500|grep -a "Please restart with"`
if [ -z "$var1112" ]
 then
echo "`date` NO error1112"
echo "`date` NO error1112" >> .sin/debug.log 
echo "`date` NO error1112" >> status
 else
echo "WARNING `date` sinerror1112" >> status
echo "`date` file error - reindex wanted" >> status
echo "`date` file error - reindex wanted" >> .sin/debug.log 
echo "`date` starting sinautobootstrap" >> status
echo "`date` starting sinautobootstrap" >> .sin/debug.log 
sinautobootstrap
fi
}


sinerror7() {
var7=`tail .sin/debug.log -n500|grep -a "failed to flush state"`
if [ -z "$var7" ]
 then
echo "`date` NO error7"
echo "`date` NO error7" >> .sin/debug.log 
echo "`date` NO error7" >> status
 else
echo "WARNING `date` sinerror7" >> status
echo "WARNING `date` sinerror7" >> .sin/debug.log 
echo "`date` file error - starting daemon" >> status
echo "`date` file error - starting daemon" >> .sin/debug.log 
sinstart
fi
}


#is marked invalid
sinerror2() {
var2=`tail .sin/debug.log -n500|grep -a "is marked invalid"`
if [ -z "$var2" ]
 then
echo "`date` NO error2"
echo "`date` NO error2" >> .sin/debug.log 
 else
 echo "WARNING `date` sinerror2 " >> status
echo "`date` AcceptBlockHeader" >> status
echo "`date` found error AcceptBlockHeader" >> .sin/debug.log 
sinautobootstrap
fi
}

sinerror3() {
var3=`ps aux|grep sind|wc -l`
if (( $var3 < 2 )); then
echo "WARNING `date` sinerror3 daemon offline?" >> status
echo "`date` WARNING error3 daemon offline?" >> .sin/debug.log 

var33=`ps aux|grep bootstrap|wc -l`
if (( $var33 > 1 )); then
echo "`date` var33 download in progress" >> status
echo "`date` var33 download in progress" >> .sin/debug.log 
else
sinerror1
sinerror11
sinerror111
sinerror1112
sinerror7
fi

var4=`./sin-cli uptime`
echo cli uptime $(((($var4 / 60)/60)/24)) days, $var4 sec >> status
echo ****************************************** >> status
ps aux >> status
echo ****************************************** >> status
fi
}


notcapablecheck() {

vartest=`./sin-cli infinitynode mypeerinfo|grep "Not capable"`
if [ -z "$vartest" ]
 then
echo "`date` node status check - ENABLED" >> status
 else
 echo "`date` Not capable, check FAIL" >> status
 sinstop
 sleep $((RANDOM % 30))
 sinstart
fi

}


pingtest() {
ping6 google.com -c1 |grep packets >> status 
}


createblockmark() {

  if [ -f "savednodeblock" ]; then
        echo "************** savednodeblock exist **************"
        echo "************** savednodeblock exist **************" >> status
        else

block=`./sin-cli infinitynode getrawblockcount`
echo $block > savednodeblock

        echo "*********** rec savednodeblock is $block ***********"
        echo "*********** rec savednodeblock is $block ***********" >> status
        fi


}

sinerror4() {
#IP=`cat /root/.sin/sin.conf|grep externalip=|cut -c 12-72`

currentnodeblock=`./sin-cli infinitynode getrawblockcount`
IFS= read -r savednodeblock < savednodeblock;

if echo "$savednodeblock" | grep -qE '^[0-9]+$'; then
    #echo "Valid number"

	if (( $savednodeblock < $currentnodeblock )); then
    echo "blocks OK $savednodeblock / $currentnodeblock"
	echo "`date` blocks $currentnodeblock OK" >> status
	echo $currentnodeblock > savednodeblock
	else
	#curl -s -X POST XXXXXXXXXXXXXXXXXX -d chat_id=396043531 -d text="`date` $currentnodeblock $IP"
    echo "$savednodeblock $currentnodeblock ***************"
	echo "blocks error FAIL $currentnodeblock"
	echo "`date` blocks error FAIL $savednodeblock $currentnodeblock" >> status
	echo "`date` blocks error FAIL will try to start daemon" >> status
	echo "`date` error4" >> .sin/debug.log 
	sinstart
	fi

else
    #echo "Error: cur blocks value not a number"
	echo $currentnodeblock > savednodeblock #re-made if error
	echo "`date` savednodeblock value fail - recreate" >> status
fi
}



sinerror5() {
if tail .sin/debug.log -n500 |grep -q 'Timeout downloading block'
then
echo "`date` WARNING sinerror5 Timeout downloading block" >> status
echo "`date` error5" >> .sin/debug.log 
sinstop
sinstart
else
echo "`date` NO error5" >> .sin/debug.log 
fi
}




sinlog(){
#check if log more then 1G
GOAL=$(stat -c%s .sin/debug.log)

if (( $GOAL > 135544320 )); then #135mb
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

########################### bootstrap

	if [ -f ".sin.tar.gz" ]; then
	
	echo "!!! we have .sin.tar.gz" >> status
	echo "!!! we have .sin.tar.gz" >> .sin/debug.log
		
	mv .sin/wallet.dat wallet.dat
	cp .sin/sin.conf sin.conf
	cp .sin/sin.conf sin.conf.back
	rm .sin/* -rf
	tar -xzvf .sin.tar.gz
	mv wallet.dat .sin/wallet.dat
	cp sin.conf .sin/sin.conf
	rm .sin.tar.gz
	fi
###################################################

	#touch bpart.zip
	if [ -f "bpart.zip" ]; then
	
	echo "!!! we have bpart.7z" >> status
	echo "!!! we have bpart.7z" >> .sin/debug.log
	sinstop
	sinclean
	
	apt update -y
	apt install curl -y
	apt install unzip -y
	
	#p1
	curl -J -O https://bootstrap.sinovate.io/index.php/s/6D3QkArPlAeoqRa/download
	unzip p1.zip || echo "p1.zip error !!!!!!!!!!!!" >> status
	
	mv p1/* .sin/
	rm p1 -rf
	rm p1.zip
	echo "`date` ***** p1 done *****" >> status
	
	#p2
	curl -J -O https://bootstrap.sinovate.io/index.php/s/RdQWQQBiKRM8UWd/download
	unzip p2.zip || echo "p2.zip error !!!!!!!!!!!!" >> status
	mv p2/blocks/* .sin/blocks/
	rm p2 -rf
	rm p2.zip
	echo "`date` ***** p2 done *****" >> status
	
	#p3
	curl -J -O https://bootstrap.sinovate.io/index.php/s/IQnBvVtWI9C35u9/download
	unzip p3.zip || echo "p3.zip error !!!!!!!!!!!!" >> status
	mv p3/* .sin/
	rm p3 -rf
	rm p3.zip
	echo "`date` ***** p3 done *****" >> status
	
	rm bpart.zip
	echo "`date` ***** bpart.zip used *****"
	echo "`date` ***** bpart.zip used *****" >> status
	echo "`date` ***** bpart.zip used *****" >> .sin/debug.log
	sinstart
	fi










	if [ -f "bootstrap.7z" ]; then
	
	echo "!!! we have bootstrap.7z" >> status
	echo "!!! we have bootstrap.7z" >> .sin/debug.log
	sinstop
	sinclean
	
	dpkg --configure -a
	apt update -y
	apt-get install tar -y
	apt install p7zip-full -y
	
	7z x /root/bootstrap.7z -o.sin || echo "7z error !!!!!!!!!!!!" >> status
	mv .sin/bootstrap/* .sin/
	rm .sin/bootstrap -rf
	rm bootstrap.7z
	echo "`date` ***** bootstrap.7z used *****"
	echo "`date` ***** bootstrap.7z used *****" >> status
	echo "`date` ***** bootstrap.7z used *****" >> .sin/debug.log
	mv wallet.dat .sin/wallet.dat
	cp sin.conf .sin/sin.conf
	sinstart
	fi
	
###########################

case $1 in
     clean)      
sinclean
;;
     safereboot)      
sinstop
/sbin/reboot --force
exit
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
	testnet)
	mkdir .sin
	touch .sin/sin.conf
	
	cat <<EOF > .sin/sin.conf
testnet=1
debug=1
#infinitynode=1
#infinitynodeprivkey=
#externalip=
[test]
addnode=51.195.174.64
addnode=51.195.174.65
addnode=51.195.174.66
addnode=51.195.174.67
EOF
	#wget -6 http://setdown.sinovate.io/sinbeet-sytem/testnet2.sh
	#sinstop
	#bash testnet2.sh
	reboot
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
		sleep 0.2
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
			echo "`date` update check: no new" >> status
			echo "*************** `date` update check: no new" >> .sin/debug.log
			else
			mv .sin/new .sin/cur
			down
			sinstart			
			fi
	#exit
    else
	echo "************** cur ver NOT exist **************"
	sleep 0.2
	wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/ver
	down
	sinstart
	#crontab -l | { cat; echo "0 */3 * * * `pwd`/update.sh"; } | crontab -
    fi

}










#Binding RPC on address 0.0.0.0 port 20981 failed
#socket recv error Connection reset by peer
#Timeout downloading block ed739d151e3a69845eceb75142f3ff6bd866db3bca4db8e2e875b8d079afa543 from peer=18759, disconnecting
#ERROR: Requesting unset send - OK
#ContextualCheckBlockHeader - resync? restart? OK ?
#Cannot try to connect TopNode score     cat .sin/debug.log |grep -i "Cannot try"


########################################################################start

#sinerror1
sinlog
sinupdate
sinstart
import &
echo "`date` start seq done" >> status
echo "`date` start seq done" >> .sin/debug.log

############cron
while sleep 481; do sinerror3; done & #daemon running check
while sleep 3601; do sinerror4; done & #blockcount check (createblockmark fun dependent - here down below)
while sleep 250; do sinerror5; done &
#while sleep 174; do sinerror2; done & #AcceptBlockHeader
while sleep 10801; do notcapablecheck; done &
#while sleep 86399; do sinstop;sinstart;echo "*************** `date` node restart" >> .sin/debug.log;echo "*************** `date` node restart" >> status; done &
sleep 31 && sinerror1 &
sleep 119 && sinaddnodes &
sleep 10701 && pingtest &
sleep 301 && createblockmark &

#golden nodes
#sleep 56;./sin-cli addnode seed1.sinovate.org add &
#sleep 58;./sin-cli addnode seed2.sinovate.org add &
#sleep 60;./sin-cli addnode seed3.sinovate.org add &
#sleep 62;./sin-cli addnode seedv01.sinovate.org add &
#sleep 64;./sin-cli addnode seedv02.sinovate.org add &
#sleep 66;./sin-cli addnode seedv03.sinovate.org add &
#sleep 68;./sin-cli addnode seedv04.sinovate.org add &



echo "`date` <<<<<<<<<<<< done script >>>>>>>>>>>" >> status



	
	
