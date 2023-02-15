#!/bin/bash

# requires bc
# 
# https://www.kernel.org/doc/html/latest/power/power_supply_class.html
# https://github.com/torvalds/linux/blob/master/include/linux/power_supply.h
#
# make terminal graph or spectrum(bar)?
# maybe just move cursor instead of clear
# try to not show if N/A
# get rid of conver tfunction and put if statement in printstuff
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
declare -A info=( [status]='N\A'
		[charge_type]='N\A'
		[health]='N\A'
		[present]='N\A'
		[online]='N\A'
		[authentic]='N\A'
		[technology]='N\A'
		[cycle_count]='N\A'
		[capacity_level]='N\A'
		[temp]='N\A'
		[temp_max]='N\A'
		[temp_min]='N\A'
		[temp_alert_min]='N\A'
		[temp_alert_max]='N\A'
		[temp_ambient]='N\A'
		[temp_ambient_alert_min]='N\A'
		[temp_ambient_alert_max]='N\A'
		[time_to_empty_now]='N\A'
		[time_to_empty_avg]='N\A'
		[time_to_full_now]='N\A'
		[time_to_full_avg]='N\A'
		[type]='N\A'
		[usb_type]='N\A'
		[scope]='N\A'
		[charge_counter]='N\A'
		[calibrate]='N\A'
		[manufacture_year]='N\A'
		[manufacture_month]='N\A'
		[manufacture_day]='N\A'
		[charge_behaviour]='N\A'
		# convert
		[constant_charge_current]='N\A'
		[constant_charge_current_max]='N\A'
		[constant_charge_voltage]='N\A'
		[constant_charge_voltage_max]='N\A'
		[charge_control_limit]='N\A'
		[charge_control_limit_max]='N\A'
		[charge_control_start_threshold]='N\A'
		[charge_control_end_threshold]='N\A'
		[input_current_limit]='N\A'
		[input_voltage_limit]='N\A'
		[input_power_limit]='N\A'
		[energy_full_design]='N\A'
		[energy_empty_design]='N\A'
		[energy_full]='N\A'
		[energy_empty]='N\A'
		[energy_now]='N\A'
		[energy_avg]='N\A'
		[precharge_current]='N\A'
		[charge_term_current]='N\A'
		[voltage_max]='N\A'
		[voltage_min]='N\A'
		[voltage_max_design]='N\A'
		[voltage_min_design]='N\A'
		[voltage_now]='N\A'
		[voltage_avg]='N\A'
		[voltage_ocv]='N\A'
		[voltage_boot]='N\A'
		[current_max]='N\A'
		[current_now]='N\A'
		[current_avg]='N\A'
		[current_boot]='N\A'
		[power_now]='N\A'
		[power_avg]='N\A'
		[charge_full_design]='N\A'
		[charge_empty_design]='N\A'
		[charge_full]='N\A'
		[charge_empty]='N\A'
		[charge_now]='N\A'
		[charge_avg]='N\A'
		# percents
		[capacity]='N\A'
		[capacity_alert_min]='N\A'
		[capacity_alert_max]='N\A'
		[capacity_error_margin]='N\A'
		# chars
		[model_name]='N\A'
		[manufacturer]='N\A'
		[serial_number]='N\A' )

function printstuff() {
	# Assume voltage_now model_name serial_number 
	# capacity status always exists	

	space=15
	echo $(tput cols)

	printf '%-31s' 'Battery Name:'
	printf '%s ' ${info['model_name']}
	printf '\n\u2502\n' #\u251c

	# Manufacture
	printf '\u251C\u2500%-14s%*s%-s\n' 'Manufacturer:' $space '' ${info['manufacturer']}
	printf '\u251C\u2500%-14s%*s%-s\n' 'Serial Number:' $space '' ${info['serial_number']}
	printf '\u251C\u2500%-14s%*s%-s\n' '⚡Status:' $space '' ${info['status']}
	
	printf '\u251c\u2500%-14s\n' 'Capacity'
	printf '\u2502\t\u251c\u2500%16s%*s%-s%% (%s)\n' 'Percentage:' $space ''  ${info['capacity']} ${info['capacity_level']}
	printf '\u2502\t\u251c\u2500%16s%*s%-s%%\n' 'Alert Minimum:' $space '' ${info['capacity_alert_min']}
	printf '\u2502\t\u251c\u2500%16s%*s%-s%%\n' 'Alert Maximum:' $space '' ${info['capacity_alert_max']}
	printf '\u2502\t\u2514\u2500%16s%*s%-s%%\n' 'Error Margin:' $space '' ${info['capacity_error_margin']}

	# Time
	printf '\u251c\u2500%-16s\n' 'Time'
	if [[ -z $(ls /sys/class/power_supply/BAT1 | grep -i 'time_*') ]]; then
		echo Calculated time here
	else
		if [ ${info['time_to_empty_now']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%-s Seconds\n' 'Time Remaining:' $space '' ${info['time_to_empty_now']}
			printf '\u2502\t\u2514\u2500%16s%*s%s Seconds\n' 'Average Life:' $space '' ${info['time_to_empty_avg']}
		fi
		if [ ${info['time_to_full_now']} != 'N\A' ];then
			printf '\u2502\t\u251c\u2500%16s%*s%-s Seconds\n' 'Seconds Until Full:' $space '' ${info['time_to_full_now']}
			printf '\u2502\t\u2514\u2500%16s%*s%s Seconds\n' 'Average Charge Time:' $space '' ${info['time_to_empty_avg']}
		fi
	fi

	# Power (Watts)
	if [[ -z $(ls /sys/class/power_supply/BAT1 | grep -i 'power_*') ]]; then
		echo No power readings
	else
		printf '\u251c\u2500%-16s\n' 'Power'
		if [ ${info['power_now']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%-g Watts\n' 'Power Usage:' $space '' $(bc <<<"scale=6;${info['power_now']} / 100000")
		fi
		if [[ ${info['power_avg']} != 'N\A' ]]; then
			printf '\u2502\t\u2514\u2500%16s%*s%-g Watts\n' 'Power Average:' $space '' ${info['power_avg']}
		fi
	fi
	
	
	# Voltage, assume always exists
	printf '\u251c\u2500%-16s\n' 'Voltage'
	if [ ${info['voltage_now']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_now']} / 100000")
	fi
	if [ ${info['voltage_max']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_max']} / 100000")
	fi
	if [ ${info['voltage_min']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_min']} / 100000")
	fi
	if [ ${info['voltage_avg']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_avg']} / 100000")
	fi
	if [ ${info['voltage_max_design']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_max_design']} / 100000")
	fi
	if [ ${info['voltage_min_design']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_min_design']} / 100000")
	fi
	if [ ${info['voltage_ocv']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_ocv']} / 100000")
	fi
	if [ ${info['voltage_boot']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%s Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_boot']} / 100000")
	fi

	# Current / Amps
	# precharge_current charge_term_current
	if [ ${info['current_now']} != 'N\A' ]; then
		printf '\u251c\u2500%16s\n' 'Current / Amps'
		printf '\u2502\t\u2514\u2500%16s%*s%s Amps\n' 'Current:' $space '' ${info['current_now']}
		printf '\u2502\t\u2514\u2500%16s%*s%s Amps\n' 'Current Maximum:' $space '' ${info['current_max']}
		printf '\u2502\t\u2514\u2500%16s%*s%s Amps\n' 'Current Average:' $space '' ${info['current_avg']}
		printf '\u2502\t\u2514\u2500%16s%*s%s Amps\n' 'Current Boot:' $space '' ${info['current_boot']}
	fi

	# Charge, now, full, empty, full_design, empty_design, avg, counter, behavior: Amp/hour
	

	# Charge control

	# Constant charge
	
	# Temp

	printf '%15s%*s%-g Wh\n' 'Measured Wh:' $space '' $(bc <<<"scale=6;$wh / 100000")
	printf '%15s%*s%-g Wh\n' 'Design Full Wh:' $space '' $(bc <<<"scale=6;$fdwh / 100000")
	printf '%15s%*s%-g Wh\n' 'Measured Full Wh:' $space '' $(bc <<<"scale=6;$fwh / 100000")

	
	# energy_now / power_now = time remaining
}

function gettime() {
	if [ -n $info['power_now'] ] && [ -n $info['energy_now'] ]; then
		v=${info['voltage_now']}
		w=${info['power_now']}
		a=$(bc <<<"scale=6;$w / $v")
		wh=${info['energy_now']}
		tm=$(bc <<<"scale=6;($wh / $w) * 60")
		h=$(( ${tm%.*} / 60 ))
		m=$(expr ${tm%.*} % 60)
		time=$(echo $h Hours $m Minutes)
	elif [ -n $info['current_now'] ] && [ -n $info['charge_now'] ]; then
		v=${info['voltage_now']}
		w=${info['power_now']}
		a=${info['current_now']}
		ah=${info['charge_now']}
		tm=$(bc <<<"scale=6;($ah / $a) * 60")
		h=$(( ${tm%.*} / 60 ))
		m=$(expr ${tm%.*} % 60)
		time=$(echo $h Hours $m Minutes)
	fi
	return $time
}

function printkeys() {
	for i in ${!info[@]}; do
		echo $i
	done
}

function printvals() {
	for i in ${info[@]}; do
		echo $i
	done
}

function printinfo() {
	for i in ${!info[@]}; do
		echo $i ': ' ${info[$i]}
	done
}

function popinfo() {
	# populate info with filenames and contents repectivley
	# from /sys/class/power_supply
	for f in $(find /sys/class/power_supply/BAT1/!(u*) -type f); do
		# name of file
		key=$(echo $f | cut -d "/" -f 6)
		# file contents
		val=$(cat $f)
		# ignore zero values
		info[$key]=$val
	done
}

# get BAT0, BAT1, etc
readarray -t batnum < <(find /sys/class/power_supply/BAT* | cut -d "/" -f 5)

popinfo
convert
printstuff

tmp=$(ls /sys/class/power_supply/BAT1 | grep -i 'energy_*')
num=`echo $tmp | wc -w`
echo $num
for (( c=1; c<=$num; c++ ));do
	t2=`echo $tmp | cut -d ' ' -f $c`
	echo ${info[$t2]}

done

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
