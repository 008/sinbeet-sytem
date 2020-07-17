#!/bin/bash
#wget -6 http://setdown.sinovate.io/sinbeet-sytem/updatenodecron.sh

    if [ -f ".sin/cur" ]; then 
	
	sleep $((RANDOM % 2))
	
        curnodever=$(cat .sin/cur)
#        rm .sin/cur
		wget -6 -O .sin/new http://setdown.sinovate.io/sinbeet-sytem/ver
		newnodever=$(cat .sin/new)
		
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "update check no new ver" >> status
			echo "update check no new ver" >> .sin/debug.log
			exit
			else
			echo "updating node ver..." >> .sin/debug.log
			echo "updating node ver..." >> status
			
			#service sind stop
			killall -9 sind
			sleep 5

			#rm -rf /usr/local/bin/sin-cli
			#rm -rf /usr/local/bin/sind
			rm -rf sin-cli
			rm -rf sind
			rm -rf linux*
			#rm -rf ubu18.*
			#rm -rf ubu16.*
			
			#wget https://github.com/008/sinbeet-sytem/raw/master/current/ubu18.zip
			
			
			wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/$newnodever/linux.zip
			
								
			if [ ! -f "linux.zip" ]; then 
			echo "download node fail, will try later" >> .sin/debug.log
			echo "download node fail, will try later" >> status
			echo "download node fail, will try later"
			exit
			fi
			
			unzip linux*
			chmod +x sin*
			#install -c sin-cli /usr/local/bin/sin-cli
			#install -c sind /usr/local/bin/sind
			#service sind start || sind
			./sind
			echo "updating node DONE ver date $newnodever" >> .sin/debug.log
			echo "updating node DONE ver date $newnodever" >> status
			fi
			
			
		
    else
	wget -6 -O .sin/cur http://setdown.sinovate.io/sinbeet-sytem/ver
	crontab -l | { cat; echo "0 */3 * * * `pwd`/updatenodecron.sh"; } | crontab -
    fi
	