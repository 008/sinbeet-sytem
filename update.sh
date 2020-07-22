#!/bin/bash

##wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh
#rm update.sh ;wget -6 http://setdown.sinovate.io/sinbeet-sytem/update.sh; bash update.sh

declare -i newnodever
declare -i curnodever

down() {

			echo "`date` updating node $curnodever..." >> .sin/debug.log
			echo "`date` updating node $curnodever..." >> status
			
			#service sind stop
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
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			./sind
			echo "`date` updating node DONE $newnodever" >> .sin/debug.log
			echo "`date` updating node DONE $newnodever" >> status
			
}


    if [ -f ".sin/cur" ]; then 
	sleep $((RANDOM % 5))
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
			
			if [ "$curnodever" -lt "1" ]; then
			echo "`date` wget fail" >> status
			echo "`date` wget fail" >> .sin/debug.log
			echo "`date` wget fail"
			exit
			
			
			
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "`date` update check no new" >> status
			echo "`date` update check no new" >> .sin/debug.log
			exit
			else
			mv .sin/new .sin/cur
			down
			fi
    else
	wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/ver
	down
	#crontab -l | { cat; echo "0 */3 * * * `pwd`/update.sh"; } | crontab -
    fi