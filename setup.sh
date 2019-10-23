#!/bin/bash

MAX=10
n=`cat /proc/cpuinfo | grep "cpu cores" | uniq | awk '{print $NF}'`
VPSOS=`cat /etc/issue.net`
BITN=`uname -i`
#if [ $BITN == x86_64 ]; then
USER=$(whoami)
#mkdir /home/$USER/.sin
mkdir .sin
mnip=$(curl --silent ipinfo.io/ip)

#008 	
masternodeprivkey=$(cat sin/mnkey)
 #mnkey=$(sin-cli masternode genkey)

 

		


clean() {



#if new setup if old
if [ -f "status" ]; then
echo "Resetup pending, please wait." > status

service sind stop
killall -9 sind
sleep 1
#rm -rf status
rm -rf .sin
rm -rf /usr/local/bin/sin-cli
rm -rf /usr/local/bin/sind
rm -rf ubu18.*
rm -rf ubu16.*


        else
        echo "Starting..." > status
        fi
		

}






checkForUbuntuVersion() {
   echo "[1/${MAX}] Checking Ubuntu version..." > status
   
case $VPSOS in

*16.04*)
#echo -e "${CYAN}* You are running `cat /etc/issue.net` . Setup will continue.${NONE}";
#debug
echo -e "You are running `cat /etc/issue.net` . Please use Ubuntu 18 and run setup again." > status
exit


#wget https://github.com/008/sinbeet-sytem/raw/master/20190611/ubu16.zip
#test link
;;

*18.*)
echo -e "You are running `cat /etc/issue.net` Setup will continue." > status
wget https://github.com/008/sinbeet-sytem/raw/master/current/ubu18.zip
;;

*)
echo -e "You are running not compatible OS (Ubuntu 18 only). You are running `cat /etc/issue.net`. Please use Ubuntu 18 and run setup again." > status
##echo && echo "Installation cancelled" && echo;
exit
;;
esac
}
   
swaptest() {
        if [[ `cat /proc/swaps |grep /` ]]; then
	add_swap=n
	else
        add_swap=y
        fi
	}
	
updateAndUpgrade() {
    echo
    echo "[2/${MAX}] Running update and upgrade. Please wait..." > status
    echo
     dpkg --configure -a
     DEBIAN_FRONTEND=noninteractive apt-get update -y || echo "Can't update, try to reboot and fix that. (lock_is_held update?) " > status
     DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    echo -e "${CYAN}* Done${NONE}";
}

setupSwap() {
    echo -e "${BOLD}"
    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        swap_size="2G"
    else
        echo && echo -e "${NONE}[3/${MAX}] Swap space not created." > status
        echo -e "${NONE}${CYAN}* Done${NONE}";
    fi

    if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
        echo && echo -e "${NONE}[3/${MAX}] Adding swap space...${YELLOW}" > status
         fallocate -l $swap_size /swapfile
        sleep 2
         chmod 600 /swapfile
         mkswap /swapfile
         swapon /swapfile
        echo -e "/swapfile none swap sw 0 0" |  tee -a /etc/fstab > /dev/null 2>&1
         sysctl vm.swappiness=10
         sysctl vm.vfs_cache_pressure=50
        echo -e "vm.swappiness=10" |  tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "vm.vfs_cache_pressure=50" |  tee -a /etc/sysctl.conf > /dev/null 2>&1
        echo -e "${NONE}${CYAN}* Done${NONE}";
    fi
}


installDependencies() {


    
    libboost() {
	echo "installing libboost 15-45 min" > status
     apt-get install -y libssl1.0-dev
     apt-get install -y g++ python-dev autotools-dev libicu-dev libbz2-dev
    wget -O boost_1_58_0.tar.gz https://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz/download
    tar -xvzf boost_1_58_0.tar.gz
    cd boost_1_58_0/
    ./bootstrap.sh --prefix=/usr/local
    user_configFile=`find $PWD -name user-config.jam`
    echo "using mpi ;" >> $user_configFile
     ./b2 --with=all -j $n install 
     sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf'
     ldconfig
    cd
    ln -s /usr/lib/x86_64-linux-gnu/libevent_pthreads-2.1.so.6 /usr/lib/x86_64-linux-gnu/libevent_pthreads-2.0.so.5
    ln -s /usr/lib/x86_64-linux-gnu/libevent-2.1.so.6 /usr/lib/x86_64-linux-gnu/libevent-2.0.so.5
    }
    
    
     berkDB() {
	 
	 echo berkDB install > status
	 
	 wget http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz
     tar -xzvf db-4.8.30.tar.gz
     cd db-4.8.30/build_unix
     ../dist/configure --enable-cxx --disable-shared --with-pic
     export MALLOC_ARENA_MAX=1
     make -j $n
      make install

     #export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.4.8/include"
     #export BDB_LIB_PATH="/usr/local/BerkeleyDB.4.8/lib"
     # ln -s /usr/local/BerkeleyDB.4.8/lib/libdb-4.8.so /usr/lib/libdb-4.8.so
     # ln -s /usr/local/BerkeleyDB.4.8/lib/libdb_cxx-4.8.so /usr/lib/libdb_cxx-4.8.so
	 
      ln -s /usr/local/BerkeleyDB.4.8 /usr/include/db4.8
      ln -s /usr/include/db4.8/include/* /usr/include
      ln -s /usr/include/db4.8/lib/* /usr/lib
     cd ..
     cd ..
     }
     
    
    echo
    echo -e "[6/${MAX}] Installing dependencies. Please wait..." > status
    echo
     apt-get install -y git nano wget curl software-properties-common
     add-apt-repository ppa:bitcoin/bitcoin -y
     apt-get install -y mc htop autoconf automake libevent-dev libboost-all-dev build-essential libtool autotools-dev pkg-config libssl-dev
     apt-get install -y build-essential libtool pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libboost-all-dev libboost-program-options-dev
     apt-get install -y libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev unzip
    #libzmq3-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev
	apt-get install -y libdb4.8-dev libdb4.8++-dev || berkDB
	
	
    if [[ $VPSOS == *18.0* ]]; then
     apt-get install -y libssl1.0-dev || libboost
       
    fi
    
    
    if [[ $VPSOS == *18.1* ]]; then 
    
       libboost
       downloadwallet
       fastinstallWallet
       configureWallet
       startWallet
       end
       
     fi
    

}	




installFirewall() {
    echo
    echo -e "[4/${MAX}] Installing ufw firewall. Please wait..." > status
    echo
     apt install -y ufw
     ufw default deny incoming
     ufw default allow outgoing
     ufw allow ssh
    # ufw allow 8008
     ufw allow 20970/tcp # master port
    echo "y" |  ufw enable
    echo -e "${NONE}${CYAN}* Done${NONE}";
}


installFail2Ban() {
    echo
    echo -e "[5/${MAX}] Installing Fail2Ban. Please wait..." > status
    echo
    
     apt install -y fail2ban
     systemctl enable fail2ban
     systemctl start fail2ban

}



compileWallet() {
    echo
    echo -e "${NONE}${CYAN} [7/${MAX}] Compiling wallet. Please wait, this might take from 45 to 120 minutes to complete...${NONE}" > status
    echo
    echo
    #cd && mkdir sin && cd sin
    rm -rf sin sin-cli sind
    git clone --depth 1 $COINGITHUB sin
    cd sin
    
    #berkDB
     apt-get install -y libdb4.8-dev libdb4.8++-dev || berkDB
    
    chmod 755 src/leveldb/build_detect_platform
     chmod 755 autogen.sh
     ./autogen.sh
     ./configure --without-gui --without-miniupnpc --disable-zmq CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" --with-incompatible-bdb CFLAGS=-fPIC CXXFLAGS=-fPIC --enable-shared --disable-tests --disable-bench
    #--disable-dependency-tracking
     chmod 755 share/genbuild.sh
    export MALLOC_ARENA_MAX=1
     make -j $n
    echo -e "${NONE}${CYAN}* Done${NONE}";
}

installWallet() {
    echo
    echo -e "[8/${MAX}] Installing wallet. Please wait..." > status
     make install
    #cd src
    #strip sind
    #strip sin-cli
    #strip $COINTX
    # mv sind /usr/bin
    # mv sin-cli /usr/bin
    # mv $COINTX /usr/bin
    #cd &&  rm -rf sin
    #cd
    echo -e "${NONE}${CYAN}* Done${NONE}";
    

}

serviceInstall() {
    echo
    echo "serviceInstall start"
    echo
	

echo "[Unit]" > sind.service
echo "Description=SINovate distributed service daemon" >> sind.service
echo "After=network.target" >> sind.service

echo "[Service]" >> sind.service
echo "User=$USER" >> sind.service
echo "Group=$USER" >> sind.service

echo "Type=forking" >> sind.service
echo "PIDFile=/$USER/.sin/sind.pid" >> sind.service

echo "ExecStart=/usr/local/bin/sind -daemon -pid=/$USER/.sin/sind.pid -conf=/$USER/.sin/sin.conf -datadir=/$USER/.sin/" >> sind.service
echo "ExecStop=/usr/local/bin/sin-cli -conf=/$USER/.sin/sin.conf -datadir=/$USER/.sin/ stop" >> sind.service

echo "Restart=always" >> sind.service
echo "PrivateTmp=true" >> sind.service
echo "TimeoutStopSec=80s" >> sind.service
echo "TimeoutStartSec=11s" >> sind.service
echo "StartLimitInterval=120s" >> sind.service
echo "StartLimitBurst=5" >> sind.service

echo "[Install]" >> sind.service
echo "WantedBy=multi-user.target" >> sind.service



sleep 1

     cp sind.service /etc/systemd/system/

     systemctl daemon-reload
    sleep 3
    # systemctl start sind.service
     systemctl enable sind.service
    echo end

    }

configureWallet() {
    echo
    echo -e "[9/${MAX}] Configuring wallet. Please wait..." > status
	
	
	rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    rpcpass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
	
echo listen=1 > .sin/sin.conf
echo server=1 >> .sin/sin.conf
echo daemon=1 >> .sin/sin.conf
echo staking=0 >> .sin/sin.conf
echo rpcuser=${rpcuser} >> .sin/sin.conf
echo rpcpassword=${rpcpass} >> .sin/sin.conf
echo rpcallowip=127.0.0.1 >> .sin/sin.conf
echo rpcbind=127.0.0.1 >> .sin/sin.conf
echo maxconnections=24 >> .sin/sin.conf
echo masternode=1 >> .sin/sin.conf
echo masternodeprivkey=$masternodeprivkey >> .sin/sin.conf
echo bind=$mnip >> .sin/sin.conf
echo externalip=$mnip >> .sin/sin.conf
echo masternodeaddr=$mnip:20970 >> .sin/sin.conf
echo addnode=node1.sinovate.io >> .sin/sin.conf
echo addnode=node2.sinovate.io >> .sin/sin.conf
echo addnode=node3.sinovate.io >> .sin/sin.conf
echo addnode=node4.sinovate.io >> .sin/sin.conf
echo addnode=node5.sinovate.io >> .sin/sin.conf

sleep 1


}

startWallet() {
    echo
    echo -e "[10/${MAX}] Starting wallet daemon..." > status
    #sind -daemon
     systemctl start sind.service
    sleep 5

}


cron() {

crontab -r
rm -rf infinitynode_surveyor.sh
wget https://raw.githubusercontent.com/008/sinbeet-sytem/master/infinitynode_surveyor.sh
chmod +x infinitynode_surveyor.sh
bash infinitynode_surveyor.sh
crontab -l | { cat; echo "*/5 * * * * /root/infinitynode_surveyor.sh"; } | crontab -


}








end() {

echo System ready  > status
 
  rm -rf ubu16.*
  rm -rf ubu18.*
  rm -rf setup.sh
  #rm -rf sin
  rm -rf sin-cli
  rm -rf sind
  rm -rf sind.service
  
  exit
}



fastinstallWallet() {
    echo
    echo -e " Installing pre-compiled wallet" > status

unzip ubu*
chmod +x sin*
install -c sin-cli /usr/local/bin/sin-cli
install -c sind /usr/local/bin/sind
}



    clean
    checkForUbuntuVersion
	swaptest
    updateAndUpgrade
    setupSwap
    #installFail2Ban
    #installFirewall
    installDependencies
    #downloadwallet
    fastinstallWallet
    configureWallet
    serviceInstall
    startWallet
	cron
    end
	

   