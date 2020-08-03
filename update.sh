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



case $1 in
     clean)      
killall -9 sind
sleep 5
cd .sin/testnet3/
ls | grep -v wallet.dat | xargs rm -rf
cd ..
cd ..
echo "`date` clean done" >> status
echo "`date` clean done"
startsind
exit
;;
     remove)      
          commands
          ;;
     st)
          commands
          ;; 
     good)
          commands
          ;;
     *)
          echo no param
          ;;
esac




startsind() {
#start sind only if .conf exist
if [ -f .sin/sin.conf ]; then 

./sind

  echo "`date` starting sind" >> status
  echo "`date` starting sind"
  sleep 2
else
  echo "`date` dont have .conf" >> status
  echo "`date` dont have .conf"
exit
fi
}





down() {
			echo "`date` updating node $curnodever..." >> .sin/debug.log
			echo "`date` updating node $curnodever..." >> status
			echo "`date` updating node $curnodever..."
			
			killall -9 sind
			sleep 5
			
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
			echo "`date` download node fail, will try later"
			exit
			fi
			
			unzip cur*
			sleep 0.2
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			rm -rf .sin/testnet3/*.dat
			echo "`date` updating node DONE $newnodever" >> .sin/debug.log
			echo "`date` updating node DONE $newnodever" >> status
			startsind
			
}


startsind





    if [ -f ".sin/cur" ]; then 
	echo "************** cur exist **************"
	sleep $((RANDOM % 60))
        curnodever=$(cat .sin/cur)
		wget -6 -O .sin/new http://setdown.sinovate.io/sinbeet-sytem/ver
		
		if [ -f ".sin/new" ]; then 
		newnodever=$(cat .sin/new)
		else
			echo "`date` download fail" >> status
			echo "`date` download fail" >> .sin/debug.log
			echo "`date` download fail"
			exit
		fi
			
		if [ "$newnodever" -lt "1" ]; then
			echo "`date` wget fail" >> status
			echo "`date` wget fail" >> .sin/debug.log
			echo "`date` wget fail"
			exit
		fi
			
			
			
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "`date` update check no new" >> status
			echo "`date` update check no new" >> .sin/debug.log
			exit
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
	
