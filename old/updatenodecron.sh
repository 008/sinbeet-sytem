#!/bin/bash

    if [ -f "sin/cur" ]; then 
	
	sleep $((RANDOM % 7200))
	
        curnodever=$(cat sin/cur)
        rm sin/cur
		wget -O sin/cur https://raw.githubusercontent.com/008/sinbeet-sytem/master/cur
		newnodever=$(cat sin/cur)
		
		    if [ "$curnodever" -eq "$newnodever" ]; then
			echo "update check no new ver" >> status
			echo "update check no new ver" >> .sin/debug.log
			exit
			else
			echo "updating node ver..." >> .sin/debug.log
			echo "updating node ver..." >> status
			
			service sind stop
			killall -9 sind
			sleep 5

			rm -rf /usr/local/bin/sin-cli
			rm -rf /usr/local/bin/sind
			rm -rf sin-cli
			rm -rf sind
			rm -rf ubu18.*
			rm -rf ubu16.*
			
			wget https://github.com/008/sinbeet-sytem/raw/master/current/ubu18.zip
			
			if [ ! -f "ubu18.zip" ]; then 
			echo "download node fail, will try later" >> .sin/debug.log
			echo "download node fail, will try later" >> status
			exit
			fi
			
			unzip ubu*
			chmod +x sin*
			install -c sin-cli /usr/local/bin/sin-cli
			install -c sind /usr/local/bin/sind
			service sind start
			echo "updating node DONE ver date $newnodever" >> .sin/debug.log
			echo "updating node DONE ver date $newnodever" >> status
			fi
			
			
		
    else
	wget -O sin/cur https://raw.githubusercontent.com/008/sinbeet-sytem/master/cur
    fi
	