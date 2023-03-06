#!/bin/bash

# battop beat me to it
# requires bc
# 
# https://www.kernel.org/doc/html/latest/power/power_supply_class.html
# https://github.com/torvalds/linux/blob/master/include/linux/power_supply.h
#
# make terminal graph or spectrum(bar)?
# 
# 
# 
#
#
# usage: watch bash batterybash.sh

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
	#echo $(tput cols) = terminal colums

	printf '%-36s' 'Battery Name:'
	printf '%s ' ${info['model_name']}
	printf '\n\u2502\n' #\u251c

	# Manufacturer
	printf '\u251C\u2500%-19s%*s%-s\n' 'Manufacturer:' $space '' ${info['manufacturer']}
	if [[ ${info['manufacture_year']} != 'N\A' ]];then
		printf '\u251C\u2500%-19s%*s%-s/%-s/%-s\n' 'Manufacture Date:' $space '' ${info['manufacture_month']} ${info['manufacture_day']} ${info['manufacture_year']}
	fi
	printf '\u251C\u2500%-19s%*s%-s %-s\n' 'Serial Number:' $space '' ${info['serial_number']}
	printf '\u251C\u2500%-20s%*s%-s\n' '⚡Status:' $space '' ${info['status']}
	if [ ${info['calibrate']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Calibrate:' $space '' ${info['calibrate']}
	fi
	if [ ${info['type']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Type:' $space '' ${info['type']}
	fi
	if [ ${info['scope']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Scope:' $space '' ${info['scope']}
	fi
	if [ ${info['usb_type']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'USB Type:' $space '' ${info['usb_type']}
	fi
	if [ ${info['cycle_count']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Cycle Count:' $space '' ${info['cycle_count']}
	fi
	if [ ${info['charge_type']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Charge Type:' $space '' ${info['charge_type']}
	fi
	if [ ${info['present']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Present:' $space '' ${info['present']}
	fi
	if [ ${info['online']} != 'N\A' ]; then
		printf '\u251C\u2500%-19s%*s%-s\n' 'Online:' $space '' ${info['online']}
	fi
	if [ ${info['health']} != 'N\A' ]; then
		printf '\u251C\u2500%-20s%*s%-s\n' 'Health:' $space '' ${info['health']}
	fi
	if [ ${info['authentic']} != 'N\A' ]; then
		printf '\u251C\u2500%-20s%*s%-s\n' 'Authentic:' $space '' ${info['authentic']}
	fi
	
	printf '\u251c\u2500%-14s\n' 'Capacity'
	printf '\u2502\t\u251c\u2500%16s%*s%-s%% (%s)\n' 'Percentage:' $space ''  ${info['capacity']} ${info['capacity_level']}
	if [ ${info['capacity_alert_min']} != "N\A" ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%-s%%\n' 'Alert Minimum:' $space '' ${info['capacity_alert_min']}
	fi
	if [ ${info['capacity_alert_max']} != "N\A" ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%-s%%\n' 'Alert Maximum:' $space '' ${info['capacity_alert_max']}
	fi
	if [ ${info['capacity_error_margin']} != "N\A" ]; then
		printf '\u2502\t\u2514\u2500%16s%*s%-s%%\n' 'Error Margin:' $space '' ${info['capacity_error_margin']}
	fi

	# energy_now / power_now = time remaining
	# charge_now / current_now = time remaining
	# Time
	printf '\u251c\u2500%-16s\n' 'Time'
	if [[ -z $(ls /sys/class/power_supply/BAT0 | grep -i 'time_*') ]]; then
		# Calculated time
		hrs=0
		mins=0
		gettime
		printf '\u2502\t\u251c\u2500%16s%*s%-sh %-sm \n' 'Time Remaining:' $space '' $hrs $mins
	else
		if [ ${info['time_to_empty_now']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%-s Seconds\n' 'Time Remaining:' $space '' ${info['time_to_empty_now']}
			printf '\u2502\t\u251c\u2500%16s%*s%s Seconds\n' 'Average Life:' $space '' ${info['time_to_empty_avg']}
		fi
		if [ ${info['time_to_full_now']} != 'N\A' ];then
			printf '\u2502\t\u251c\u2500%16s%*s%-s Seconds\n' 'Seconds Until Full:' $space '' ${info['time_to_full_now']}
			printf '\u2502\t\u2514\u2500%16s%*s%s Seconds\n' 'Average Charge Time:' $space '' ${info['time_to_empty_avg']}
		fi
	fi

	# Power (Watts)
	printf '\u251c\u2500%-16s\n' 'Power'
	if [ ${info['power_now']} == 'N\A' ]; then
		watts=$((${info['voltage_now']} * ${info['current_now']}))
		printf '\u2502\t\u251c\u2500%16s%*s%-g Watts\n' 'Power Usage:' $space '' $(bc <<<"scale=6;$watts / 1000000000000")
	else
		if [ ${info['power_now']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%-g Watts\n' 'Power Usage:' $space '' $(bc <<<"scale=6;${info['power_now']} / 1000000")
		fi
		if [[ ${info['power_avg']} != 'N\A' ]]; then
			printf '\u2502\t\u2514\u2500%16s%*s%-g Watts\n' 'Power Average:' $space '' $(bc <<<"scale=6;${info['power_avg']} / 1000000")
		fi
		if [[ ${info['input_power_limit']} != 'N\A' ]]; then
			printf '\u2502\t\u2514\u2500%16s%*s%-g Watts\n' 'Power Limit:' $space '' $(bc <<<"scale=6;${info['input_power_limit']} / 1000000")
		fi
	fi
	
	# Voltage, assume always exists
	printf '\u251c\u2500%-16s\n' 'Voltage'
	if [ ${info['voltage_now']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_now']} / 1000000")
	fi
	if [ ${info['voltage_max']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage Max:' $space '' $(bc <<<"scale=6;${info['voltage_max']} / 1000000")
	fi
	if [ ${info['voltage_min']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage Min:' $space '' $(bc <<<"scale=6;${info['voltage_min']} / 1000000")
	fi
	if [ ${info['voltage_avg']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage Avg:' $space '' $(bc <<<"scale=6;${info['voltage_avg']} / 1000000")
	fi
	if [ ${info['voltage_max_design']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Max Design:' $space '' $(bc <<<"scale=6;${info['voltage_max_design']} / 1000000")
	fi
	if [ ${info['voltage_min_design']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Min Design:' $space '' $(bc <<<"scale=6;${info['voltage_min_design']} / 1000000")
	fi
	if [ ${info['voltage_ocv']} != 'N\A' ]; then
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Open Circuit Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_ocv']} / 1000000")
	fi
	if [ ${info['voltage_boot']} != 'N\A' ]; then
		printf '\u2502\t\u2514\u2500%16s%*s%g Volts\n' 'Boot Voltage:' $space '' $(bc <<<"scale=6;${info['voltage_boot']} / 1000000")
	fi
	if [ ${info['input_voltage_limit']} != 'N\A' ]; then
		printf '\u2502\t\u2514\u2500%16s%*s%g Volts\n' 'Voltage Limit:' $space '' $(bc <<<"scale=6;${info['input_voltage_limit']} / 1000000")
	fi

	# Current / Amps
	# precharge_current charge_term_current
	if [ ${info['current_now']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Current / Amps'
		printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current:' $space '' $(bc <<<"scale=6;${info['current_now']} / 1000000")
		if [ ${info['current_max']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current Maximum:' $space '' ${info['current_max']}
		fi
		if [ ${info['current_avg']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current Average:' $space '' ${info['current_avg']}
		fi
		if [ ${info['current_boot']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current Boot:' $space '' ${info['current_boot']}
		fi
		if [ ${info['precharge_current']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Precharge Current:' $space '' ${info['precharge_current']}
		fi
		if [ ${info['charge_term_current']} != 'N\A' ]; then
			printf '\u2502\t\u2514\u2500%16s%*s%g Amps\n' 'Charge Term Current:' $space '' ${info['charge_term_current']}
		fi
		if [ ${info['input_current_limit']} != 'N\A' ]; then
			printf '\u2502\t\u2514\u2500%16s%*s%g Volts\n' 'Current Limit:' $space '' $(bc <<<"scale=6;${info['input_current_limit']} / 1000000")
		fi
	else
		# calculate amps
		echo calc
	fi

	# Amp Hour info
	if [ ${info['charge_now']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Amp Hours (Ah)'
		printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Ah Remaining:' $space '' $(bc <<<"scale=6;${info['charge_now']} / 1000000")
		if [ ${info['charge_full']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Full Ah:' $space '' $(bc <<<"scale=6;${info['charge_full']} / 1000000")
		fi
		if [ ${info['charge_full_design']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Full Ah Design:' $space '' $(bc <<<"scale=6;${info['charge_full_design']} / 1000000")
		fi
		if [ ${info['charge_empty']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Empty Ah:' $space '' $(bc <<<"scale=6;${info['charge_empty']} / 1000000")
		fi
		if [ ${info['charge_counter']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Charge Counter:' $space '' $(bc <<<"scale=6;${info['charge_counter']} / 1000000")
		fi
		if [ ${info['charge_avg']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Average Ah:' $space '' $(bc <<<"scale=6;${info['charge_avg']} / 1000000")
		fi
		if [ ${info['charge_empty_design']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Ah\n' 'Empty Ah:' $space '' $(bc <<<"scale=6;${info['charge_empty_design']} / 1000000")
		fi
		if [ ${info['charge_full']} != 'N\A' ] && [ ${info['charge_full_design']} != 'N\A' ]; then
			bathealth=$(bc <<<"scale=6;${info['charge_full_design']} / ${info['charge_full']}")
			printf '\u2502\t\u251c\u2500%16s%*s%g %%\n' 'Capacity Health:' $space '' $(bc <<<"scale=6;$bathealth * 100")
		fi
	else
		# No Amp Hour info
		printf '\u2502\t\n'
	fi

	if [ ${info['energy_now']} != 'N\A' ]; then
		# watt hour info
		printf '\u251c\u2500%s\n' 'Watt Hours (Wh)'
		if [ ${info['energy_full']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Wh\n' 'Full Wh:' $space '' $(bc <<<"scale=6;${info['energy_full']} / 1000000")
		fi
		if [ ${info['energy_full_design']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Wh\n' 'Full Wh Design:' $space '' $(bc <<<"scale=6;${info['energy_full_design']} / 1000000")
		fi
		if [ ${info['energy_empty']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Wh\n' 'Empty Wh:' $space '' $(bc <<<"scale=6;${info['energy_empty']} / 1000000")
		fi
		if [ ${info['energy_avg']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Wh\n' 'Average Ah:' $space '' $(bc <<<"scale=6;${info['energy_avg']} / 1000000")
		fi
		if [ ${info['energy_empty_design']} != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g Wh\n' 'Empty Ah:' $space '' $(bc <<<"scale=6;${info['charge_empty_design']} / 1000000")
		fi
		if [ ${info['energy_full']} != 'N\A' ] && [ ${info['energy_full_design']} != 'N\A' ]; then
			bathealth=$(bc <<<"scale=6;${info['energy_full_design']} / ${info['energy_full']}")
			printf '\u2502\t\u251c\u2500%16s%*s%g %%\n' 'Capacity Health:' $space '' $(bc <<<"scale=6;$bathealth * 100")
		fi
	else
		printf '\u2502\t\n'
	fi
	
	# Temp
	if [ ${info['temp']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Tempurature (C)'
		printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Tempurature:' $space '' $(bc <<<"scale=6;${info['temp']} * 10")
		if [ ${info}['temp_ambient'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Ambient Temp:' $space '' $(bc <<<"scale=6;${info['temp_ambient']} * 10")
		fi
		if [ ${info}['temp_max'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Max Temp:' $space '' $(bc <<<"scale=6;${info['temp_max']} * 10")
		fi
		if [ ${info}['temp_min'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Minimum Temp:' $space '' $(bc <<<"scale=6;${info['temp_ambient']} * 10")
		fi
		if [ ${info}['temp_alert_max'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Temp Alert Max:' $space '' $(bc <<<"scale=6;${info['temp_alert_max']} * 10")
		fi
		if [ ${info}['temp_alert_min'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Temp Alert Min:' $space '' $(bc <<<"scale=6;${info['temp_alert_min']} * 10")
		fi
		if [ ${info}['temp_ambient_alert_max'] != 'N\A' ]; then
			printf '\u2502\t\u251c\u2500%16s%*s%g C\n' 'Temp Ambient Alert Max:' $space '' $(bc <<<"scale=6;${info['temp_ambient_alert_max']} * 10")
		fi
		if [ ${info}['temp_ambient_alert_min'] != 'N\A' ]; then
			printf '\u2502\t\u2514\u2500%16s%*s%g C\n' 'Temp Ambient Alert Min:' $space '' $(bc <<<"scale=6;${info['temp_ambient_alert_min']} * 10")
		fi
	else
		printf '\u2502\t\n'
	fi
	
	# Charge control
	if [ ${info['charge_control_limit']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Charge Control'
		printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Limit:' $space '' $(bc <<<"scale=6;${info['charge_control_limit']} / 1000000")
		printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Limit Max:' $space '' $(bc <<<"scale=6;${info['charge_control_limit_max']} / 1000000")
		printf '\u2502\t\u251c\u2500%16s%*s%-s %%\n' 'Start %:' $space '' ${info['charge_control_start_threshold']}
		printf '\u2502\t\u251c\u2500%16s%*s%-s %%\n' 'End %:' $space '' ${info['charge_control_end_threshold']}
	fi

	# Constant charge
	if [ ${info['constant_charge_current']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Constant Charge Current'
		printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current:' $space '' $(bc <<<"scale=6;${info['constant_charge_current']} / 1000000")
		printf '\u2502\t\u251c\u2500%16s%*s%g Amps\n' 'Current Max:' $space '' $(bc <<<"scale=6;${info['constant_charge_current_max']} / 1000000")
	fi
	if [ ${info['constant_charge_voltage']} != 'N\A' ]; then
		printf '\u251c\u2500%s\n' 'Constant Charge Voltage'
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage:' $space '' $(bc <<<"scale=6;${info['constant_charge_voltage']} / 1000000")
		printf '\u2502\t\u251c\u2500%16s%*s%g Volts\n' 'Voltage Max:' $space '' $(bc <<<"scale=6;${info['constant_charge_voltage_max']} / 1000000")
	fi

	printf '\u2514\n'

}

function gettime() {
	if [ ${info['power_now']} != 'N\A' ] && [ ${info['energy_now']} != 'N\A' ]; then
		v=${info['voltage_now']}
		w=${info['power_now']}
		a=$(bc <<<"scale=6;$w / $v")
		wh=${info['energy_now']}
		tm=$(bc <<<"scale=6;($wh / $w) * 60")
		h=$(( ${tm%.*} / 60 ))
		m=$(expr ${tm%.*} % 60)
		hrs=$h
		mins=$m
	elif [ ${info['current_now']} != 'N\A' ] && [ ${info['charge_now']} != 'N\A' ]; then
		v=${info['voltage_now']}
		a=${info['current_now']}
		ah=${info['charge_now']}
		tm=$(bc <<<"scale=6;($ah / $a) * 60")
		h=$(( ${tm%.*} / 60 ))
		m=$(expr ${tm%.*} % 60)
		hrs=$h
		mins=$m
	fi
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
	for f in $(find /sys/class/power_supply/BAT0/ -maxdepth 1 -type f); do
		# name of file
		key=$(echo $f | cut -d "/" -f 6)
		# file contents
		val=$(cat $f)
		# ignore zero values
		info[$key]=$val
	done
}

# get BAT0, BAT1, etc
#readarray -t batnum < <(find /sys/class/power_supply/BAT* | cut -d "/" -f 5)

popinfo
#convert
printstuff
