#!/bin/bash

#Prerequisits
#EXPECT should be installed on all machines, or install by sudo apt-get install expect
#env variables JUMBUNE_HOME, HADOOP_HOME and AGENT_HOME should be set on the respected machines. 
#set the env variable DISPLAY in /etc/enviornment ie if the primary display device is at 0 export it as DISPLAY=:0
#run this to genreate scripts in automationscripts folder, after that run scp-script.sh and start-all.sh
#

#IP and location of the Jumbune Jar to be deployed
gitMachine="192.168.49.67"
pathToJar="/root/Desktop/Jenkins_NextHome/jobs/Jumbune-Community/lastSuccessful/archive/BD-Tools/Jumbune-Community/distribution/target/jumbune-dist-GA-1.0-SNAPSHOT-bin.jar"
gitUName="root"
gitPass="impetus"
#IP of NameNode
namenode="192.168.49.78"
NNUName="impadmin"
NNPass="jumbunecluster"
agentPort="5555"
#IP of Jumbune Machine
jumbune="192.168.49.78"
jumbuneUName="impadmin"
jumbunePass="jumbunecluster"
jumbune_home="/home/impadmin/Desktop/Jumbune_Home/"
#IP of selenium machine
selIp="192.168.49.81"
selUName="impadmin"
selPass="impetus321"
seleniumJar="/home/impadmin/selenium-server-standalone-2.35.0.jar"
seleniumTestJar="/home/impadmin/Desktop/Seleniumjar.jar"


#options
selEnable="0"
latestBuildEnable="0"

echo ""
echo "############################################"
echo "Please provide all the information required"
echo "############################################"
echo ""


read -p "Do you want to run selenium scripts as well y/n ? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    selEnable="1"
fi

read -p "Do you want to take the latest build y/n ? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    latestBuildEnable="1"
    
else 
	
echo
echo "Please make sure that the distribution jar is present in the home directory of the jumbune machine "
echo

fi




#Prompts for everything 
read -e -p "Enter the gitMachine IP: " -i "$gitMachine" variable
gitMachine=$variable


read -e -p "Enter the path to the Jar for the build: " -i "$pathToJar" variable
pathToJar=$variable


read -e -p "Enter the git user Name: " -i "$gitUName" variable
gitUName=$variable


read -e -p "Enter the git Password: " -i "$gitPass" variable
gitPass=$variable


read -e -p "Enter the namenode IP: " -i "$namenode" variable
namenode=$variable


read -e -p "Enter the name node user name: " -i "$NNUName" variable
NNUName=$variable


read -e -p "Enter the name node password: " -i "$NNPass" variable
NNPass=$variable


read -e -p "Enter the name node hadoop_home: " -i "$hadoop_home" variable
hadoop_home=$variable

read -e -p "Enter the agent port: " -i "$agentPort" variable
agentPort=$variable


read -e -p "Enter the jumbune machine IP: " -i "$jumbune" variable
jumbune=$variable


read -e -p "Enter the jumbune machine user name: " -i "$jumbuneUName" variable
jumbuneUName=$variable


read -e -p "Enter the jumbune machine Password: " -i "$jumbunePass" variable
jumbunePass=$variable


read -e -p "Enter the jumbune_home on the jumbune machine: " -i "$jumbune_home" variable
jumbune_home=$variable


read -e -p "Enter the selenium machine Ip: " -i "$selIp" variable
selIp=$variable


read -e -p "Enter the selenium machine User Name: " -i "$selUName" variable
selUName=$variable


read -e -p "Enter the selenium machine Password: " -i "$selPass" variable
selPass=$variable


read -e -p "Enter the location of the seleniumJar: " -i "$seleniumJar" variable
seleniumJar=$variable


read -e -p "Enter the location of the selenium Jar for tests: " -i "$seleniumTestJar" variable
seleniumTestJar=$variable

echo
echo

if [ "$selEnable" == "0" ]; then
	seleniumJar=""
	seleniumTestJar=""
else
	echo ""
fi



##Making the remote scripts that
mkdir -p automationscripts

rm -rf automationscripts/mainscript.sh
touch automationscripts/mainscript.sh
chmod +x automationscripts/mainscript.sh

if [ "$latestBuildEnable" == "1" ]; then
	
cat <<EOM > automationscripts/mainscript.sh
#!/usr/bin/expect -f
spawn scp $pathToJar $jumbuneUName@$jumbune:/home/$jumbuneUName/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$jumbunePass\r"
  }
}
interact

spawn ssh $jumbuneUName@$jumbune /home/$jumbuneUName/automationscripts/start.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode /home/$jumbuneUName/automationscripts/start-hadoop.sh
match_max 100000
expect "*?assword:*"
send -- "$NNPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune /home/$jumbuneUName/automationscripts/send-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode /home/$NNUName/automationscripts/start-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$NNPass\r"
send -- "\r"
expect eof

spawn ssh $selUName@$selIp /home/$selUName/automationscripts/startselenium.sh
match_max 100000
expect "*?assword:*"
send -- "$selPass\r"
send -- "\r"
expect eof


spawn ssh $selUName@$selIp /home/$selUName/automationscripts/selenium-script.sh
match_max 100000
expect "*?assword:*"
send -- "$selPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune $jumbune_home/bin/startWeb
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

EOM

else
cat <<EOM > automationscripts/mainscript.sh
#!/usr/bin/expect -f

spawn ssh $jumbuneUName@$jumbune /home/$jumbuneUName/automationscripts/start.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode /home/$jumbuneUName/automationscripts/start-hadoop.sh
match_max 100000
expect "*?assword:*"
send -- "$NNPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune /home/$jumbuneUName/automationscripts/send-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode /home/$NNUName/automationscripts/start-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$NNPass\r"
send -- "\r"
expect eof

spawn ssh $selUName@$selIp /home/$selUName/automationscripts/startselenium.sh
match_max 100000
expect "*?assword:*"
send -- "$selPass\r"
send -- "\r"
expect eof


spawn ssh $selUName@$selIp /home/$selUName/automationscripts/selenium-script.sh
match_max 100000
expect "*?assword:*"
send -- "$selPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune $jumbune_home/bin/startWeb
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

EOM


fi

rm -rf automationscripts/start.sh
touch automationscripts/start.sh
chmod +x automationscripts/start.sh
cat <<EOM > automationscripts/start.sh
#!/bin/bash
echo "started script first"
rm -rf $JUMBUNE_HOME
cd
automationscripts/deploy.sh


EOM

rm -rf automationscripts/start-hadoop.sh
touch automationscripts/start-hadoop.sh
chmod +x automationscripts/start-hadoop.sh
cat <<EOM > automationscripts/start-hadoop.sh
#!/bin/bash

echo "Killing and starting hadoop from scrach"
#exec $HADOOP_HOME/bin/stop-all.sh
exec $HADOOP_HOME/bin/start-all.sh

EOM
rm -rf automationscripts/send-agent.sh
touch automationscripts/send-agent.sh
chmod +x automationscripts/send-agent.sh
cat <<EOM > automationscripts/send-agent.sh
#!/usr/bin/expect -f
spawn scp $jumbune_home/agent-distribution/jumbune-remoting-GA-1.0-SNAPSHOT-agent.jar $namenode:/home/$NNUName/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$NNPass\r"
  }
}

EOM
rm -rf automationscripts/deploy.sh
touch automationscripts/deploy.sh
chmod +x automationscripts/deploy.sh
cat <<EOM > automationscripts/deploy.sh
#!/usr/bin/expect -f

set timeout -1
spawn /bin/bash
match_max 100000
expect "*"
send -- "cd /home/$jumbuneUName \r"
send -- "java -jar jumbune-dist-GA-1.0-SNAPSHOT-bin.jar"
expect -exact "dist-GA-1.0-SNAPSHOT-bin.jar"
send -- "\r"
expect "*Please provide IP address of the machine designed to run hadoop namenode daemon\r
"
send -- "$jumbune\r"
expect -exact "$jumbune\r
Username:\r
"
send -- "$jumbuneUName\r"
expect -exact "$jumbuneUName\r
Password:\r
"
send -- "$jumbunePass\r"
expect "*Please provide private key file path*"
send -- "/home/$jumbuneUName/.ssh/id_rsa\r"
expect "*!!! Jumbune deployment got completed successfully. !!!*"
expect "*:~*"
send -- "cd  $jumbune_home\r"
expect "*:~*"
send -- "chmod 700 bin/*\r"
expect "*:~*"
send -- "bin/startWeb\r"

EOM

rm -rf automationscripts/startselenium.sh
touch automationscripts/startselenium.sh
chmod +x automationscripts/startselenium.sh
cat <<EOM > automationscripts/startselenium.sh
#!/bin/bash
echo "####starting selenium and logging to seleniumlogs#####"
nohup java -jar $seleniumJar > seleniumlogs 2>&1 &
EOM
rm -rf automationscripts/start-agent.sh
touch automationscripts/start-agent.sh
chmod +x automationscripts/start-agent.sh
cat <<EOM > automationscripts/start-agent.sh
#!/bin/bash
echo "####starting agent and logging to agentconsolelogs#####"
nohup java -jar /home/$NNUName/jumbune-remoting-GA-1.0-SNAPSHOT-agent.jar $agentPort > agentconsolelogs 2>&1 &


EOM

rm -rf automationscripts/scp-script.sh
touch automationscripts/scp-script.sh
chmod +x automationscripts/scp-script.sh
cat <<EOM > automationscripts/scp-script.sh
#!/usr/bin/expect -f

spawn rsync --chmod=u+rwx,g+rwx,o+rwx mainscript.sh $gitUName@$gitMachine:/home/impadmin/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$gitPass\r"
    exp_send "\r"
  }
}

 

spawn rsync --chmod=u+rwx,g+rwx,o+rwx start.sh $jumbuneUName@$jumbune:/home/$jumbuneUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$jumbunePass\r"
    exp_send "\r"
  }
}
interact

spawn rsync --chmod=u+rwx,g+rwx,o+rwx deploy.sh $jumbuneUName@$jumbune:/home/$jumbuneUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$jumbunePass\r"
    exp_send "\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx send-agent.sh $jumbuneUName@$jumbune:/home/$jumbuneUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$jumbunePass\r"
    exp_send "\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx start-hadoop.sh $NNUName@$namenode:/home/$NNUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$NNPass\r"
    exp_send "\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx start-agent.sh $NNUName@$namenode:/home/$NNUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$NNPass\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx selenium-script.sh $selUName@$selIp:/home/$selUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$selPass\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx startselenium.sh $selUName@$selIp:/home/$selUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$selPass\r"
  }
}
interact
spawn rsync --chmod=u+rwx,g+rwx,o+rwx selenium-script.sh $selUName@$selIp:/home/$selUName/automationscripts/
expect {
  -re ".*es.*o.*" {
    exp_send "yes\r"
    exp_continue
  }
  -re ".*sword.*" {
    exp_send "$selPass\r"
  }
}
interact
EOM

rm -rf automationscripts/chmod-script.sh
touch automationscripts/chmod-script.sh
chmod +x automationscripts/chmod-script.sh
cat <<EOM > automationscripts/chmod-script.sh
#!/usr/bin/expect -f
spawn ssh $gitUName@$gitMachine chmod +x /home/$gitUName/automationscripts/mainscript.sh
match_max 100000
expect "*?assword:*"
send -- "$gitPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune chmod +x /home/$jumbuneUName/automationscripts/start.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode chmod +x /home/$NNUName/automationscripts/start-hadoop.sh
match_max 100000
expect "*?assword:*"
send -- "$NNPass\r"
send -- "\r"
expect eof

spawn ssh $jumbuneUName@$jumbune chmod +x /home/$jumbuneUName/automationscripts/send-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof

spawn ssh $NNUName@$namenode chmod +x /home/$jumbuneUName/automationscripts/start-agent.sh
match_max 100000
expect "*?assword:*"
send -- "$jumbunePass\r"
send -- "\r"
expect eof


EOM

rm -rf automationscripts/selenium-script.sh
touch automationscripts/selenium-script.sh
chmod +x automationscripts/selenium-script.sh
cat <<EOM > automationscripts/selenium-script.sh
#!/bin/bash
echo "!!!!!!!!!!!!STARTING TESTS!!!!!!!!!!!!!"
nohup java -jar $seleniumTestJar > seljarlogs 2>&1 &
EOM
rm -rf automationscripts/start-all.sh
touch automationscripts/start-all.sh
chmod +x automationscripts/start-all.sh
cat <<EOM > automationscripts/start-all.sh
#!/usr/bin/expect -f

spawn ssh $gitUName@$gitMachine /home/impadmin/automationscripts/mainscript.sh
match_max 100000
expect "*?assword:*"
send -- "$gitPass\r"
send -- "\r"
expect eof
EOM

rm -rf automationscripts/README
touch automationscripts/README
chmod +x automationscripts/README
cat <<EOM > automationscripts/README

Read Me
--------

There are some prerequisits for running this automation script:
--------------------------------------------------------------
*EXPECT should be installed on all machines, or install by sudo apt-get install expect
*env variables JUMBUNE_HOME, HADOOP_HOME and AGENT_HOME should be set on the respected machines. 
*set the env variable DISPLAY in /etc/enviornment ie if the primary display device is at 0 export it as DISPLAY=:0



In this folder there would be 11 scripts, each generated according to the IPs mentioned in the primary script which generated this folder and the scripts (ie mastershell.sh)

First run the "scp-script.sh" to transfer all the scripts to the respective machines. 

after that run the script "start-all.sh", it will start all the daemons on the respective machines ie. get the latest build from the provided path, deploy it on the designated jumbune machine, start the hadoop cluster, start the jumbune agent and start the slenium tests if required.



EOM

echo "#########################################################################################################################"
echo "Scripts generated to automaitionscripts/ folder. Please read the automaitionscripts/README file for further instructions."
echo "#########################################################################################################################"


