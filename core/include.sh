#!/bin/bash
declare -A Commands
declare -A Descriptions
declare -a Groups 
flag_default=0

function register(){
	local value=(${Commands[$1]})
	value+=("$2")
	if [ -z "${Commands[$1]}" ]; then
		Groups+=($1)
	fi
	Commands[$1]="${value[*]}"
	Descriptions[$2]=$3
}


function command_exists(){
	for group in "${Groups[@]}"; do
		local command_group=(${Commands[$group]})
		for command in "${command_group[@]}"; do
			if [ "$command" == "$1" ]; then
				return 1
			fi
		done
	done
	return 0
}

function command_print(){
	info "./install.sh [command]"
	echo "Commands:"
	for key in "${Groups[@]}" ; do
		echo -e "    $key : "
		local command_group=(${Commands[$key]})
		for command in "${command_group[@]}"; do
			echo -e "        $command : $(yellow ${Descriptions[$command]})"
		done
	done
	echo -e "    ALL"
}

function parse_options(){
	local arguments=()
	for opt in "$@"; do
		case "$opt" in
			-h|--help)
				command_print
				exit 0
				;;
			-y|--yes)
				flag_default=1
				;;
			*)
				arguments+=("$opt")
				;;
		esac
	done
	if [ -z $arguments ] ; then
		command_print
		exit 0
	fi
	for opt in "${arguments[@]}"; do
		command_run $opt
		pwd
		if [ $? -eq 2 ]; then
			. $WORK_DIR/core/load_environment.sh
		fi
		
		chown $USER:$GROUP -R /work/
	done

}

function command_run(){
	local status=0
	for group in "${Groups[@]}"; do
		local command_group=(${Commands[$group]})
		status=0
		if [ "$1" == "$group" ] ; then
			status=1
		elif [ "$1" == "ALL" ]; then
			status=2
		fi
		for command in "${command_group[@]}"; do
			if [ $status -ne 0 ] ; then
				info "Running $command"
				$command
				result=$?
				if [ $result -eq 1 ]; then
					error "Failed to run $command"
					exit 1
				fi
				if [ $result -eq 2 ]; then
					for script in $(ls /work/profile/); do
						. /work/profile/$script
					done
				fi
				cd $CACHE_DIR
			elif [ "$1" == "$command" ]; then
				info "Running $command"
				$command
				result=$?
				if [ $result -eq 1 ]; then
					error "Failed to run $command"
					exit 1
				fi
				cd $CACHE_DIR
				return $result
			fi
		done
		if [ $status -eq 1 ]; then
			return 0;
		fi
	done
	if [ $status -eq 2 ]; then
		exit 0
	fi
	error "Command $1 not found"
	return 0
}

function ask_user(){
	local default=$1
	local args=($@)
	#declare -A args=($@)
	args=("${args[@]:1}")
	declare -A option_map
	info "Please enter option or option's number"
	for ((i=0; i<${#}-1; i++));do
		option_map[${args[$i]}]=$i
		if [ "$default" == "${args[$i]}" ]; then
			default=$i
			echo -e "$i): $( yellow ${args[$i]})"
		else
			echo -e "$i): ${args[$i]}"
		fi
	done
	while true ; do
		echo -n ""
		if [ $flag_default -eq 1 ]; then
			echo -e $(yellow "${args[$default]}")
			return $default
		fi
		
		read -r -t 0
		read -p "Enter your choice: " choice
		if [ -z "$choice" ]; then
			return $default
		else
			for key in "${!option_map[@]}";do
				if [ "$key" = "$choice" ] || [ "${option_map[$key]}" = "$choice" ]; then
					return ${option_map[$key]}
				fi
			done
			error "Invalid choice"
			
		fi
	done
}


function make_para(){
	local args=("$@")
	local var_value=(${!#})
	for ((i=0; i<${#}-1; i++));do
		var_name=${args[$i]}
		echo "local $var_name=${var_value[$i]}"
	done
}

function check_dir(){
	if ! [ -e "$1" ]; then
		sudo mkdir $1
		sudo chown $USER:$GROUP $1
	fi
}

function set_config(){
	eval $(make_para name "$*")
	check_dir $CACHE_DIR/flags
	if ! [ -e "$name" ]; then
		touch $CACHE_DIR/flags/$name
	fi
}

function get_config(){
	eval $(make_para name "$*")
	check_dir $CACHE_DIR/flags
	if [ -e "$CACHE_DIR/flags/$name" ]; then
		return 1
	fi
	return 0
}
