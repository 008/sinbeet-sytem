#!/bin/bash
sleep $((RANDOM % 90))
sms(){
GROUP_ID=396043531
BOT_TOKEN=850623372:AAGvyDrYQpAnlWD3n-4dh2Ea3kQbN7c3VVg
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` \"text message\""
  exit 0
fi
if [ -z "$1" ]
  then
    echo "Add message text as second arguments"
    exit 0
fi
if [ "$#" -ne 1 ]; then
    echo "You can pass only one argument. For string with spaces put it on quotes"
    exit 0
fi
curl -s --data "text=$1" --data "chat_id=$GROUP_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage' > /dev/null
}

errorcheck(){
if [ -d "/home/solver/.sin$COUNT" ]; then
        value=`cat /home/solver/.sin$COUNT/state`
        if [ "$value" == "suspended" ]; then
        echo $value suspnd
        else
	#we have error

		#just started ignore
		uptime=`pct exec $COUNT cat /proc/uptime`
		upSeconds="$(echo $uptime | grep -o '^[0-9]\+')"
		if [ "$upSeconds" -gt "600" ]; then
		sms $COUNT
		fi
        fi
fi
}

COUNT=10000
LIMIT=30000
while [[ "$LIMIT" -ge "$COUNT" ]]
do
if [ $COUNT == 13371 ] || [ $COUNT == 13372 ] || [ $COUNT == 13373 ] || [ $COUNT == 13374 ] || [ $COUNT == 12212 ] ||
[ $COUNT == 12224 ] || [ $COUNT == 14324 ] || [ $COUNT == 14328 ] || [ $COUNT == 14333 ] || [ $COUNT == 15674 ] ||
[ $COUNT == 12224 ] ||  [ $COUNT == 16104 ] || [ $COUNT == 18381 ]; then
echo skiping $COUNT
else
        if [ -d "/var/lib/lxc/$COUNT" ]; then
        var1=`pct exec $COUNT ./sin-cli infinitynode mypeerinfo` || errorcheck
        echo $var1 `echo $COUNT`
        sleep 4
        fi
#       echo $COUNT
fi

(( COUNT++ ))
done

echo health check done at `date` >> status
