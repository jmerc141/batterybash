#!/bin/bash

# requires bc
# 
# https://www.kernel.org/doc/html/latest/power/power_supply_class.html
# https://github.com/torvalds/linux/blob/master/include/linux/power_supply.h
#
# make terminal graph or spectrum(bar)?
# maybe just move cursor instead of clear
# check if file exists else dont show
#
#
#
#

# hide cursor
#tput civis
# enable exglob for regex
shopt -s extglob

# number of batteries list
declare -a batnum
# key value of filename and value
declare -A info
# all possible filenames
declare -a filenames
readarray -t filenames < ./filenames.txt

function printstuff() {
	w=${info['power_now']}
	v=${info['voltage_now']}
	a=$(bc <<<"scale=6;$w / $v")
	wh=${info['energy_now']}
	tm=$(bc <<<"scale=6;($wh / $w) * 60")
	h=$(( ${tm%.*} / 60 ))
	m=$(expr ${tm%.*} % 60)
	fdwh=${info['energy_full_design']}
	fwh=${info['energy_full']}
	space=15
	time=$(echo $h Hours $m Minutes)

	printf '%-30s' 'Battery Name:'
	printf '%s ' ${info['model_name']}
	printf '\n\u2502\n' #\u251c

	# Manufacture
	printf '\u251C\u2500%-14s%*s%-s\n' 'Serial Number' $space '' ${info['serial_number']}
	printf '\u251C\u2500%-14s%*s%-s ⚡\n' 'Status:' $space '' ${info['status']}
	printf '\u251c\u2500%-14s%*s%-sh%-sm\n' 'Time Remaining:' $space '' $h $m
	
	printf '\u251c\u2500%-14s\n' 'Capacity'
	printf '\u2502\t\u251c\u2500%16s%*s%-i%% (%s)\n' 'Percentage:' $space ''  ${info['capacity']} ${info['capacity_level']}
	printf '\u2502\t\u251c\u2500%16s%*s%-i%%\n' 'Alert Minimum:' $space '' ${info['capacity_alert-min']}
	printf '\u2502\t\u251c\u2500%16s%*s%-i%%\n' 'Alert Maximum:' $space '' ${info['capacity_alert_max']}
	printf '\u2502\t\u2514\u2500%16s%*s%-i%%\n' 'Error Margin:' $space '' ${info['capacity_error_margin']}

	printf '\u251c\u2500%-16s\n' 'Power'
	printf '\u2502\t\u251c\u2500%16s%*s%-g Watts\n' 'Power Usage:' $space '' $(bc <<<"scale=6;$w / 100000")
	if [[ "${!info[power_avg]}" ]]; then
		printf '\u2502\t\u2514\u2500%16s%*s%-g Watts\n' 'Power Average:' $space '' $(bc <<<"scale=6;${info['power_avg']} / 100000")
	fi
	
	
	printf '\u251c\u2500%-16s\n' 'Voltage'
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;$v / 100000")
	printf '\u2502\t%15s%*s%-g Volts\n' 'Maximum:' $space '' $(bc <<<"scale=6;${info['voltage_max']} / 100000")
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Minimum:' $space '' $(bc <<<"scale=6;${info['voltage_min']} / 100000")
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Average:' $space '' $(bc <<<"scale=6;${info['voltage_avg']} / 100000")
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Maximum Design:' $space '' $(bc <<<"scale=6;${info['voltage_max_design']} / 100000")
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Minimum Design:' $space '' $(bc <<<"scale=6;${info['voltage_min_design']} / 100000")
	printf '\u2502\t\u251c\u2500%16s%*s%-g Volts\n' 'Open Curcuit Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_ocv']} / 100000")
	printf '\u2502\t\u2514\u2500%16s%*s%-g Volts\n' 'Boot Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_boot']} / 100000")

	# Current / Amps
	# precharge_current charge_term_current
	printf '\u251c\u2500%16s\n' 'Current / Amps'
	if [[ " ${!info[@]} " =~ " ${current} " ]]; then
		printf '\u2502\t\u251c\u2500%16s%*s%-g Amps\n' 'Amps:' $space '' $(bc <<<"scale=6;${info['current_now']} / 100000")
		printf '\u2502\t\u251c\u2500%16s%*s%-g Amps\n' 'Amp Average:' $space '' $(bc <<<"scale=6;${info['current_avg']} / 100000")
		printf '\u2502\t\u251c\u2500%16s%*s%-g Amps\n' 'Maximum Amps:' $space '' $(bc <<<"scale=6;${info['current_max']} / 100000")
		printf '\u2502\t\u251c\u2500%16s%*s%-g Amps\n' 'Boot Amps:' $space '' $(bc <<<"scale=6;${info['current_boot']} / 100000")
	else
		# if no current reading use a=w/v
		printf '\u2502\t\u2514\u2500%15s%*s%-g Amps\n' 'Calculated Amps:' $space '' $a
	fi

	# Charge, now, full, empty, full_design, empty_design, avg, counter, behavior: Amp/hour
		# Charge control
	# Constant charge
	
	# Time
	if [[ "${info[voltage_now]}" ]]; then
		echo here
	else
		echo not
	fi
	
	# Temp

	printf '%15s%*s%-g Wh\n' 'Measured Wh:' $space '' $(bc <<<"scale=6;$wh / 100000")
	printf '%15s%*s%-g Wh\n' 'Design Full Wh:' $space '' $(bc <<<"scale=6;$fdwh / 100000")
	printf '%15s%*s%-g Wh\n' 'Measured Full Wh:' $space '' $(bc <<<"scale=6;$fwh / 100000")



	
	# energy_now / power_now = time remaining
}

function printkeys() {
	for i in ${!info[@]}; do
		echo $i
	done
}

# get BAT0, BAT1, etc
readarray -t batnum < <(find /sys/class/power_supply/BAT* | cut -d "/" -f 5)

# populate info with filenames and contents repectivley
for f in $(find /sys/class/power_supply/BAT1/!(u*) -type f); do
	# name of file
	key=$(echo $f | cut -d "/" -f 6)
	# file contents
	val=$(cat $f)
	# ignore zero values
	if [ -z '$val' ]; then echo "Null"; else info[$key]=$val; fi
done

printstuff


# loop until q
while :
do
	break
	sleep 1
	read -t 0.25 -N 1 input
	if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
		# exit script
		tput cnorm
		shopt -u extglob
		clear
		break
	fi
done
