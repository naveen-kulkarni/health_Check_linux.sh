#!/bin/bash
##########################################################################################
# Name    :  LinuxHealthCheck_HTML.sh 	                                                #
# Version :  2                                                                          #
# Author  :  naveenvk88@gmail.com                                                   #
# Permission : 755                                                                      # 
# Shell script to check the server heath-check status.					#
##########################################################################################
set -a

currentpath="/home/naveen/scripts"

echo -n "Enter ip address and press enter: "
read ipaddress

echo -n "Enter username and press enter: "
read username

echo -n "Enter password and press enter: "
read -s password

echo -e "Press: 1 - OS Components
2 - Disk Usage
3 - Memory Stat
4 - Network Stat
5 - CPU Stat
6 - All"

#read input

echo -e "$ipaddress"
echo -e "$username"
#echo $password

echo -e "$input"

red=`tput setaf 1`
green=`tput setaf 2`
endColor=`tput sgr0`
orange=='\033[0;33m'
BLUE='\033[0;34m'
#hostname=$(hostname -f)
#kernel=$(uname -r)
#diskSpace=$(df -Ph)
#cpuTotal=$(cat /proc/cpuinfo |grep -i processor |wc -l)
#NOW=$(date +"%F")
#LOGFILE=$PWD/log_Precheck-$NOW.log
#configDir=$PWD/config
#logDir=$PWD/precheckLog
#dirType=($configDir )
#for DirType in "${dirType[@]}"
#do
#        if [ -d $DirType ]
#        then
#                echo ""
#        else
#                mkdir -p $DirType
#        fi
#done
#intfNames=$(ip a s |awk '{print $2}' |grep -i '^[b|e]'|awk -F ':' '{print $1}')
#intfNamesLog=$configDir/intfNames-$NOW.log
#gwIps=$(route -n |awk '{print $2}' |grep -v [A-Z]|grep -v ^0|sort -u)
#gwIps=$(route -n |awk '{print $2}' |grep -v [A-Z]|grep -v ^0|sort -u|head -1)
#gwIpLog=$configDir/gwIP-$NOW.log
#gwIpPingLog=$configDir/gatewayIPPing-$NOW.log
#echo $gwIps > $gwIpLog
#echo $intfNames > $intfNamesLog

#osCheck() {
#echo -e "${green} Hostname: $hostname ${endColor}"
#echo -e "${green} kernel: $kernel ${endColor}"
#echo -e "${green} Disk Space: $diskSpace ${endColor}"
#}

#echo -e "${BLUE} HEALTH CHECK OF $hostname AT $NOW ${endColor}"

#echo -e "##########################################################################################"

unset iofres
#echo "iofres is $iofres"

selinucCheck()
{
sestatTemp=$(sestatus |awk '{print $3}')
seConfig=$(cat /etc/selinux/config |egrep -w SELINUX|egrep -v '#' |awk -F '=' '{print $2}')
if [ "$sestatTemp" =  "$seConfig" ]
then
        #echo -e "${green}Selinux is enabled ${endColor}"
	echo -e "Selinux is enabled"
else
        #echo -e "${red}Selinux is disabled ${endColor}"
	echo -e "Selinux is disabled"
fi
}

network()
{

hostname=$(hostname -f)
echo $hostname
kernel=$(uname -r)
NOW=$(date +"%F")

configDir=$PWD/config
#logDir=$PWD/precheckLog
dirType=($configDir )
for DirType in "${dirType[@]}"
do
        if [ -d $DirType ]
        then
                echo ""
        else
                mkdir -p $DirType
        fi
done

intfNames=$(ip a s |awk '{print $2}' |grep -i '^[b|e]'|awk -F ':' '{print $1}')
intfNamesLog=$configDir/intfNames-$NOW.log
#gwIps=$(route -n |awk '{print $2}' |grep -v [A-Z]|grep -v ^0|sort -u)
gwIps=$(route -n |awk '{print $2}' |grep -v [A-Z]|grep -v ^0|sort -u|head -1)
gwIpLog=$configDir/gwIP-$NOW.log
gwIpPingLog=$configDir/gatewayIPPing-$NOW.log
echo $gwIps > $gwIpLog
echo $intfNames > $intfNamesLog

echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "############################### NETWORK STAT #########################################"

for ipping in `cat $gwIpLog`
do
        ping -c2 $ipping >>$gwIpPingLog      #gatewayIPPing-$NOW.log
        if [ $? -eq 0 ]
        then
                #echo -e "# ${green} Gateway IP is pinging:$ipping ${endColor} "
		echo -e "Gateway IP is pinging:$ipping"
        else
                #echo -e "# ${red} Gateway IP not pinging: $ipping ${endColor} "
		echo -e "Gateway IP not pinging: $ipping"
        fi
done

linkStat=yes
for linkDetect in `cat $intfNamesLog`
do
        ethStatus=$(ethtool $linkDetect|& grep detected |awk '{print $3}')
        if [ "$ethStatus" = "$linkStat" ]
        then
                #echo -e "# ${green} Link is detected for : $linkDetect ${endColor} "
		echo -e "Link is detected for : $linkDetect"
        else
                #echo -e "# ${red} Link is not detected for : $linkDetect ${endColor} "
		echo -e "Link is not detected for : $linkDetect"
        fi
done
}


serviceCheckere()
{
serviceType=(ntpd firewalld)
for srvc in "${serviceType[@]}"
do
        srv_Count=$(ps -ef |grep -i $srvc|grep -v grep |wc -l)
                if [ $srv_Count -gt 0 ]
                then
                        echo -e "${green}Service is running: $srvc ${endColor}"
        else
                echo -e "${red}Service is not running:: $srvc ${endColor}"
        fi
done
}
#####################################################################
mem()
{

hostname=$(hostname -f)
echo $hostname
kernel=$(uname -r)
NOW=$(date +"%F %T")
#echo -e "################################# ${BLUE} DISK USAGE ${endColor} #######################################"
echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "############################### MEMORY STAT #########################################"

MEMUSED="$(free -m | awk 'NR==2{printf "%d\n", $3*100/$2 }')"
        if [[ ${MEMUSED} -ge 90 ]];
        then
                #echo -e "# ${red} Memory above threshlod : $MEMUSED% ${endColor} "
		echo -e "Memory above threshlod : $MEMUSED% "
        else
                #echo -e "# ${green} Memory is under threshold : $MEMUSED% ${endColor} "
		echo -e "Memory is under threshold : $MEMUSED% "
        fi
}
#####################################################################
swp() {
echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "********"
SWAPUSED="$(free -m | awk 'NR==3{printf "%d\n", $3*100/$2 }')"
        if [[ ${SWAPUSED} -ge 50 ]];
        then
                #echo -e "# ${red} High swap usage : $SWAPUSED% ${endColor} "
		echo -e "High swap usage : $SWAPUSED%"
        elif [[ ${SWAPUSED} -ge 30 ]]; then
                #echo -e "# ${orange} Average swap usage : $SWAPUSED% ${endColor} "
		echo -e "Average swap usage : $SWAPUSED%"
        else
                #echo -e "# ${green} Normal swap usage :  $SWAPUSED% ${endColor} "
		echo -e "Normal swap usage :  $SWAPUSED%"
        fi
#echo -e "##########################################################################################"
}

load() {
hostname=$(hostname -f)
echo $hostname
kernel=$(uname -r)
NOW=$(date +"%F %T")
echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "############################### CPU STAT #############################################"
CORES=$(cat /proc/cpuinfo |grep -i processor |wc -l)
LOAD=$(awk '{print $3}' < /proc/loadavg)
        CPULOAD=$(echo | awk -v c="${CORES}" -v l="${LOAD}" '{print l*100/c}' | awk -F. '{print $1}')

if [[ ${CPULOAD} -ge 90 ]];
        then
                #echo -e "# ${red} High load: $CPULOAD% ${endColor} "
		echo -e "High load: $CPULOAD%"
        elif [[ ${CPULOAD} -ge 80 ]]; then
                #echo -e "# ${orange} Average load : $CPULOAD% ${endColor} "
		echo -e "Average load : $CPULOAD%"
        else
                #echo -e "# ${green} Normal load : $CPULOAD% ${endColor} "
		echo -e "Normal load : $CPULOAD%"
        fi
}



diskspace() {

hostname=$(hostname -f)
echo $hostname
kernel=$(uname -r)
NOW=$(date +"%F %T")
#echo -e "################################# ${BLUE} DISK USAGE ${endColor} #######################################"
echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "################################# DISK USAGE #######################################"

threshold="60"
i=2
result=`df -kh |grep -v "Filesystem" | awk '{ print $5 }' | sed 's/%//g'`
for percent in $result; do
if ((percent > threshold))
then
partition=`df -kh | head -$i | tail -1| awk '{print $1}'`
#echo "# ${red} $partition  -------> ${percent}% above threshold${endColor} " ;
echo -e "$partition > > ${percent}% above threshold" ;
else
#echo "Disk space is normal"
partition=`df -kh | head -$i | tail -1| awk '{print $1}'`
moutPoint=`df -kh | head -$i | tail -1| awk '{print $6}'`
#echo "# ${green} $partition ---> $moutPoint  ------> ${percent}% Normal ${endColor}"
echo -e "$partition > $moutPoint > ${percent}% Normal"
fi
let i=$i+1
done
#echo -e "##########################################################################################"

}



osComponents()
{
#echo -e "${BLUE} HEALTH CHECK OF $hostname AT $NOW ${endColor}"
#echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "############################### ${BLUE}OS COMPONENTS ${endColor} #######################################"
#echo -e "${BLUE}OS COMPONENTS ${endColor}"
#red=`tput setaf 1`
#green=`tput setaf 2`
#endColor=`tput sgr0`

hostname=$(hostname -f)
echo $hostname
kernel=$(uname -r)
NOW=$(date +"%F %T")
#diskSpace=$(df -Ph)
cpuTotal=$(cat /proc/cpuinfo |grep -i processor |wc -l)
serUptime=$(uptime |awk '{print $3$4$5$6}')
swapDisk=$(swapon -s |tail -1 |cut -f1|awk '{print $1}')
swapSpace=$(free -g |tail -1 |awk '{print $1$2}'|awk -F ":" '{print $2}')
memInfo=$(free -g |head -2 |awk '{print $1$2}' |tail -1|awk -F ":" '{print $2}')

echo -e "HEALTH CHECK OF $hostname AT $NOW"
#echo -e "############################### OS COMPONENTS #######################################"

osComp=($hostname $kernel $cpuTotal $serUptime $swapDisk $swapSpace $memInfo)
compName=(HostName Kernel CPU-Total Uptime Swap-Disk Swap-Space Memory)

length=${#compName[@]}
for ((i=0;i<$length;i++)); do
        #echo -e "# ${green} ${compName[$i]} : ${osComp[$i]} ${endColor} "
	#if [[ ! -z "${osComp[$i]}" ]]
	#then
		echo -e "${compName[$i]} : ${osComp[$i]}"
	#fi
done
#echo -e "##########################################################################################"
}

packetStat() {
#pkts=$(ping -c 3 198.123.13.12 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}'|sed 's/\%//')
echo -e "HEALTH CHECK"
pkts=$(ping -c 3 $(hostname -i) | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}'|sed 's/\%//')
if [ $pkts -eq 0 ]
then
        #echo -e "# ${green} $pkts% packet loss ${endColor}"
	echo -e "Packet loss:$pkts%"
else
        #echo -e "# ${red} $pkts% packet loss ${endColor}"
	echo -e "Packet loss:$pkts%"
fi
#echo -e "##########################################################################################"
}



sarIOW() {

echo "HEALTH CHECK"

#sar -u |awk '{print $9}'|grep -v -e '^$'|grep  -v "[[:alpha:][:space:]]."
 for i in $(sar -u |awk '{print $6}'|grep -v -e '^$'|grep  -v "[[:alpha:][:space:]]."|awk -F"." '{print $1}')

#for i in `cat $PWD/b`
 do
   #echo $i
   if [ $i -gt 30 ]
        then
                local RESULT="NO"
                echo "$RESULT"
                #echo "ok $i"
        else
               # echo "Not ok $i"
                 local RESULT="OK"
                echo "$RESULT"

        fi

 done
}

sarIOMain()
{
#iofres=("$@")
echo "HEALTH CHECK"
rpm -qa |grep sysstat 2>&1 > /dev/null
if [ $? -eq 1 ]
then
        #echo -e "# ${red} No SAR report for IOWait report ${endColor}"
	echo -e "# No SAR report for IOWait"
fi
#exit ;
#else

#for iostatus in "${iofres[@]}"
#do
#	echo "iostatus is $iostatus"
 #        if [[ " ${iostatus[@]} " =~ "NO" ]]
  #              then
#			#echo -e "# ${red} Todays $date SAR report of IOWait : Not OK  ${endColor}"
#			echo -e "Todays $date SAR report of IOWait : Not OK"
 #               else
#			#echo -e "# ${green} Todays $date SAR report of IOWait : OK ${endColor} "
#			echo -e "Todays $date SAR report of IOWait : OK"
 #       fi
#done
#fi
}


sarCpu() {

echo "HEALTH CHECK"
#sar -u |awk '{print $9}'|grep -v -e '^$'|grep  -v "[[:alpha:][:space:]]."
 for i in $(sar -u |awk '{print $8}'|grep -v -e '^$'|grep  -v "[[:alpha:][:space:]]."|awk -F"." '{print $1}')

#for i in `cat $PWD/b`
 do
   if [ $i -gt 90 ]
        then
                local RESULT="OK"
                echo "$RESULT"
                #echo "ok $i"
        else
               # echo "Not ok $i"
                 local RESULT="NO"
                echo "$RESULT"

        fi

 done
}

sarCpuMain()
{
fres=("$@")
echo "HEALTH CHECK"
rpm -qa |grep sysstat 2>&1 > /dev/null
if [ $? -eq 1 ]
then
#        echo -e "# ${red} No SAR report for CPU report ${endColor}"
	echo -e "No SAR report for CPU report"

#exit ;
else
#fres=("$@")
#fres=$(sarCpu)
for sstatus in "${fres[@]}"
do
         if [[ " ${sstatus[@]} " =~ "NO" ]]
                then
                	#echo -e "# ${red} Todays $date SAR report of CPU : Not OK  ${endColor}"
			echo -e "Todays $date SAR report of CPU : Not OK"

                else
                	#echo -e "# ${green} Todays $date SAR report of CPU : OK ${endColor} "
			echo -e "Todays $date SAR report of CPU : OK"
        fi
done
fi
#echo -e "########################################################################################"
}



if [ $input -eq 1 ]
then
(
	$currentpath/Connect_LinuxHC.sh "$(declare -f osComponents); osComponents" "$ipaddress" "$username" "$password" > $currentpath/linuxosoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/exit/) next; print}' $currentpath/linuxosoutput.hcremoveit > $currentpath/os.hcremoveit
	sed -i 's/\r//g' $currentpath/os.hcremoveit
	cat $currentpath/os.hcremoveit
) | mail -s "HEALTH CHECK OF $ipaddress - OS Components" swati.shrivastava@cgi.com

#fi

elif [ $input -eq 2 ]
then
(
	#echo -e "HEALTH CHECK OF $hostname AT $NOW\n"
	#echo -e "################################# DISK USAGE #######################################"
	#diskspace

	$currentpath/Connect_LinuxHC.sh "$(declare -f diskspace); diskspace" "$ipaddress" "$username" "$password" > $currentpath/linuxdiskoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/exit/) next; print}' $currentpath/linuxdiskoutput.hcremoveit > $currentpath/disk.hcremoveit
	sed -i 's/\r//g' $currentpath/disk.hcremoveit
	cat $currentpath/disk.hcremoveit

) | mail -s "HEALTH CHECK OF $ipaddress - Disk Usage" swati.shrivastava@cgi.com

#fi

elif [ $input -eq 3 ]
then
#network
(
	#echo -e "############################### MEMORY STAT #########################################"

	$currentpath/Connect_LinuxHC.sh "$(declare -f mem); mem" "$ipaddress" "$username" "$password" > $currentpath/linuxmemoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/exit/) next; print}' $currentpath/linuxmemoutput.hcremoveit > $currentpath/mem.hcremoveit
	sed -i 's/\r//g' $currentpath/mem.hcremoveit
	cat $currentpath/mem.hcremoveit

	$currentpath/Connect_LinuxHC.sh "$(declare -f swp); swp" "$ipaddress" "$username" "$password" > $currentpath/linuxswpoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxswpoutput.hcremoveit > $currentpath/swp.hcremoveit
	sed -i 's/\r//g' $currentpath/swp.hcremoveit
	cat $currentpath/swp.hcremoveit

	#mem
	#swp
) | mail -s "HEALTH CHECK OF $ipaddress - Memory Stat" swati.shrivastava@cgi.com

elif [ $input -eq 4 ]
then
(
	#echo -e "############################### ${BLUE}NETWORK STAT ${endColor} #######################################"

	$currentpath/Connect_LinuxHC.sh "$(declare -f network); network" "$ipaddress" "$username" "$password" > $currentpath/linuxnetworkoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/exit/) next; print}' $currentpath/linuxnetworkoutput.hcremoveit > $currentpath/network.hcremoveit
	sed -i 's/\r//g' $currentpath/network.hcremoveit
	cat $currentpath/network.hcremoveit

	$currentpath/Connect_LinuxHC.sh "$(declare -f packetStat); packetStat" "$ipaddress" "$username" "$password" > $currentpath/linuxpacketoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxpacketoutput.hcremoveit > $currentpath/packet.hcremoveit
	sed -i 's/\r//g' $currentpath/packet.hcremoveit
	cat $currentpath/packet.hcremoveit

	#network
	#packetStat
) | mail -s "HEALTH CHECK OF $ipaddress - Network Stat" swati.shrivastava@cgi.com

elif [ $input -eq 5 ]
then
(
	#echo -e "############################### ${BLUE}CPU STAT ${endColor} #############################################"

	$currentpath/Connect_LinuxHC.sh "$(declare -f load); load" "$ipaddress" "$username" "$password" > $currentpath/linuxloadoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/exit/) next; print}' $currentpath/linuxloadoutput.hcremoveit > $currentpath/load.hcremoveit
	sed -i 's/\r//g' $currentpath/load.hcremoveit
	cat $currentpath/load.hcremoveit

	$currentpath/Connect_LinuxHC.sh "$(declare -f sarIOW); sarIOW" "$ipaddress" "$username" "$password" > $currentpath/linuxsariowoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsariowoutput.hcremoveit > $currentpath/sariow.hcremoveit
	sed -i 's/\r//g' $currentpath/sariow.hcremoveit
	iofres=$(cat $currentpath/sariow.hcremoveit)
	
	#IFS='\n\r' read -a iofresarray <<< "$iofres"
	##echo "Array is $iofresarray[0]"
	#echo "iofres is $iofres"
	#cat $currentpath/linuxsariowoutput.hcremoveit

	$currentpath/Connect_LinuxHC.sh "$(declare -f sarIOMain); sarIOMain $iofres" "$ipaddress" "$username" "$password" > $currentpath/linuxsariooutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsariooutput.hcremoveit > $currentpath/sario.hcremoveit
	sed -i 's/\r//g' $currentpath/sario.hcremoveit
	cat $currentpath/sario.hcremoveit
	#cat $currentpath/linuxsariooutput.hcremoveit

	$currentpath/Connect_LinuxHC.sh "$(declare -f sarCpu); sarCpu" "$ipaddress" "$username" "$password" > $currentpath/linuxsarcpuoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsarcpuoutput.hcremoveit > $currentpath/sarcpu.hcremoveit
	sed -i 's/\r//g' $currentpath/sarcpu.hcremoveit
	fres=$(cat $currentpath/sarcpu.hcremoveit)

	$currentpath/Connect_LinuxHC.sh "$(declare -f sarCpuMain); sarCpuMain $fres" "$ipaddress" "$username" "$password" > $currentpath/linuxsarcpumainoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsarcpumainoutput.hcremoveit > $currentpath/sarcpumain.hcremoveit
	sed -i 's/\r//g' $currentpath/sarcpumain.hcremoveit
	cat $currentpath/sarcpumain.hcremoveit

	#load
	#sarIOMain
	#sarCpuMain
) | mail -s "HEALTH CHECK OF $ipaddress - CPU Stat" swati.shrivastava@cgi.com

elif [ $input -eq 6 ]
then

	$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f osComponents); osComponents" > $currentpath/linuxosoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxosoutput.hcremoveit > $currentpath/os.hcremoveit
	
	declare -a table
	table+="<table  style='border: 1px solid black; width:50%;padding: 5px;border-collapse: collapse;' >
  		<tr>
    			<th align='center'style='background-color: #FFCA33;border: 1px solid black;border-collapse: collapse;'colspan=2>OS COMPONENTS</th>
  		</tr>"
	while read p; do
	echo $p
	#table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
	table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"

	done < $currentpath/os.hcremoveit
	table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

	table+="<br>"

	$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f diskspace); diskspace" > $currentpath/linuxdiskoutput.hcremoveit
	awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxdiskoutput.hcremoveit > $currentpath/disk.hcremoveit

	table+="<table  style='border: 1px solid black; width:50%;padding: 5px;border-collapse: collapse;' >
  		<tr>
    			<th align='center'style='background-color: #FFCA33;border: 1px solid black;border-collapse: collapse;'colspan=3>DISK USAGE</th>
 		 </tr>"
        while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d'>' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d'>' -f2)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d'>' -f3)"</td></tr>"
        done < $currentpath/disk.hcremoveit
        table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0
	
	table+="<br>"

	$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f mem); mem" > $currentpath/linuxmemoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxmemoutput.hcremoveit > $currentpath/mem.hcremoveit

        table+="<table  style='border: 1px solid black; width:50%;padding: 5px;border-collapse: collapse;' >
                <tr>
                        <th align='center'style='background-color: #FFCA33;border: 1px solid black;border-collapse: collapse;'colspan=2>MEMORY STAT</th>
                 </tr>"
        while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
        done < $currentpath/mem.hcremoveit
#        table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

        $currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f swp); swp" > $currentpath/linuxswpoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxswpoutput.hcremoveit > $currentpath/swp.hcremoveit

        while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
        done < $currentpath/swp.hcremoveit
        table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

	table+="<br>"

	$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f network); network" > $currentpath/linuxnetworkoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxnetworkoutput.hcremoveit > $currentpath/network.hcremoveit

	table+="<table  style='border: 1px solid black; width:50%;padding: 5px;border-collapse: collapse;' >
                <tr>
                        <th align='center'style='background-color: #FFCA33;border: 1px solid black;border-collapse: collapse;'colspan=2>NETWORK STAT</th>
                 </tr>"
        while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
        done < $currentpath/network.hcremoveit
        #table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

        $currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f packetStat); packetStat" > $currentpath/linuxpacketoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxpacketoutput.hcremoveit > $currentpath/packet.hcremoveit

	while read p; do
        echo $p
	#table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"

        done < $currentpath/packet.hcremoveit
        table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

	table+="<br>"

        $currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f load); load" > $currentpath/linuxloadoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxloadoutput.hcremoveit > $currentpath/load.hcremoveit
#        sed -i 's/\r//g' $currentpath/load.hcremoveit
#        cat $currentpath/load.hcremoveit

	table+="<table  style='border: 1px solid black; width:50%;padding: 5px;border-collapse: collapse;' >
                <tr>
                        <th align='center'style='background-color: #FFCA33;border: 1px solid black;border-collapse: collapse;'colspan=2>CPU STAT</th>
                 </tr>"
        while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
	table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
        done < $currentpath/load.hcremoveit
#	table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0



        $currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f sarIOW); sarIOW" > $currentpath/linuxsariowoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsariowoutput.hcremoveit > $currentpath/sariow.hcremoveit

	if grep -q "NO" "/home/sshrivastava/scripts/sariow.hcremoveit"
	then
		echo "Todays SAR report of IOWait : Not OK" > $currentpath/sario.hcremoveit
	else
		echo "Todays SAR report of IOWait : OK" > $currentpath/sario.hcremoveit
	fi

        #IFS=$'\r\n' GLOBALIGNORE='*' command eval 'iofres=($(sudo cat /home/sshrivastava/scripts/sariow.hcremoveit))'

        #$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" """$(declare -f sarIOMain); sarIOMain "${iofres[@]}"""" > 	$currentpath/linuxsariooutput.hcremoveit
        #awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsariooutput.hcremoveit > $currentpath/sario.hcremoveit
#        cat $currentpath/sario.hcremoveit

	while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
        table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
	done < $currentpath/sario.hcremoveit
        #table+="</table>"

#echo $table > /home/sshrivastava/scripts/output.html
#exit 0

	$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" "$(declare -f sarCpu); sarCpu" > $currentpath/linuxsarcpuoutput.hcremoveit
        awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsarcpuoutput.hcremoveit > $currentpath/sarcpu.hcremoveit

	if grep -q "NO" "/home/sshrivastava/scripts/sarcpu.hcremoveit"
        then
                echo "Todays SAR report of CPU : Not OK" > $currentpath/sarcpumain.hcremoveit
        else
                echo "Todays SAR report of CPU : OK" > $currentpath/sarcpumain.hcremoveit
        fi

	#top -b -n1 | grep %Cpu >> $currentpath/sarcpumain.hcremoveit

        #IFS=$'\r\n' GLOBALIGNORE='*' command eval 'fres=($(sudo cat /home/sshrivastava/scripts/sarcpu.hcremoveit))'

        #$currentpath/Connect_LinuxHC.sh "$ipaddress" "$username" "$password" """$(declare -f sarCpuMain); sarCpuMain "${fres[@]}"""" > $currentpath/linuxsarcpumainoutput.hcremoveit
        #awk '(/HEALTH CHECK/&&++c==2),/exit/{if(/HEALTH CHECK|exit/) next; print}' $currentpath/linuxsarcpumainoutput.hcremoveit > $currentpath/sarcpumain.hcremoveit

	while read p; do
        echo $p
        #table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>$p</td></tr>"
        table+="<tr><td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f1)"</td>"
        table+="<td align='left'style='background-color: #FFD394;border: 1px solid black;border-collapse: collapse;'>"$(echo $p | cut -d':' -f2)"</td></tr>"
	done < $currentpath/sarcpumain.hcremoveit
	table+="</table>"

echo $table > $currentpath/output.html

#exit 0

#	sed -i 's/\r//g' $currentpath/fulloutput.hcremoveit
#	cat $currentpath/fulloutput.hcremoveit

# | mail -s "HEALTH CHECK OF $ipaddress - All Components" swati.shrivastava@cgi.com

mail -s "HEALTH CHECK OF $ipaddress - All Components" -a $currentpath/output.html swati.shrivastava@cgi.com

fi
