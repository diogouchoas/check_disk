#!/bin/bash
#
# Check disk space from all mounted partitions
# Version 0.1
# 
#
# by Diogo Uchoas Correa ( diogo.correa@animaeducacao.com.br )


while getopts "w:c:h" OPT; do
	case $OPT in
		"w") warning=$OPTARG;;
		"c") critical=$OPTARG;;
		"h") help;;
	esac
done

( [ "$warning" == "" ] || [ "$critical" == "" ] ) && echo "ERROR: You must specify warning and critical levels" && exit 3
[[ "$warning" -ge  "$critical" ]] && echo "ERROR: Critical level must be highter than warning level"  && exit 3

function help () 
{
	echo -e "\n\tThis plugin shows the % of used space of all mounted partitions, using the 'df' utility\n\n\t$0:\n\t\t-c <integer>\tIf the % of used space is above <integer>, returns CRITICAL state\n\t\t-w <integer>\tIf the % of used space is below CRITICAL and above <integer>, returns WARNING state" 
	exit 3
}
function fsopt () 
{
	for i in `cat /proc/filesystems |grep -v nodev |awk '{print $1}'`;do msg="$msg -t $i";done	
	echo $msg
}
function checkfs () 
{
	df -P -m $(fsopt) |grep -v Filesystem 
}
function buildarray () 
{
	output=$(checkfs)
	rows=$(echo "$output" | wc -l)
	
	for i in $(seq 1 $rows); do
		partitionname[$i]=$(echo "$output" |awk -v line="$i" 'FNR==line {print $6}')
		percentused[$i]=$(echo "$output" |awk -v line="$i" 'FNR==line {print $5}'|cut -d% -f1)
		mbtotal[$i]=$(echo "$output" |awk -v line="$i" 'FNR==line {print $2}')
		mbused[$i]=$(echo "$output" |awk -v line="$i" 'FNR==line {print $3}')

		if [[ `echo ${percentused[$i]}` -ge $critical ]]; then
	        status[$i]=2
		else if [[ `echo ${percentused[$i]}` -ge $warning ]]; then
	       	status[$i]=1
	    else
	       	status[$i]=0
	    fi
		fi
	done	
}

function buildmessage () 
{
	case "${status[@]}" in
		*"2"*)
			state=2
			message="CRITICAL" 
		;;
		*"1"*)
			state=1
			message="WARNING"
		;;
		*)
			state=0
			message="OK"
		;;
	esac

	for i in $(seq 1 $rows);do
		cmdoutput="$cmdoutput $(echo ${partitionname[$i]}):$(echo ${percentused[$i]})% Used "
	done	
	echo -n "Disk Usage $message - $cmdoutput |"

}
function perfdata () 
{
	for i in $(seq 1 $rows);do
		perfdata=" $perfdata $(echo ${partitionname[$i]})_pct=$(echo ${percentused[$i]})%;$warning;$critical;0;100; $(echo ${partitionname[$i]})_used=$(echo ${mbused[$i]})MiB;;;;; $(echo ${partitionname[$i]})_total=$(echo ${mbtotal[$i]})MiB;;;;; "
	done	
	echo "$perfdata"
}

buildarray
buildmessage
perfdata

exit $state
