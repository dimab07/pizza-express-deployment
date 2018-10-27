#!/bin/bash

############################################################################
# Script to deploy Pizza-Express application based on Node.js and Redis db #
############################################################################

SCRIPT_BASE_NAME="${0##*/}"
LOG_FILE="/tmp/${SCRIPT_BASE_NAME%.sh}.log"

#################[ FUNCTIONS ]#################

print_log() {

	# $1 - log file; $2 - text
	if [ "$#" = "2" ]; then
		echo "[$(date +"%F %T")] ${2}" >> ${1}
	fi

}

print_both() {

	# $1 - log file; $2 - text
	if [ "$#" = "2" ]; then
		echo "[$(date +"%F %T")] ${2}" >> ${1}
		echo "$2"
	fi

}

# print_enter() - Trace of function entering
print_enter() {

	print_log "$LOG_FILE" "--> ${FUNCNAME[1]}"

}

# print_leave() - Trace of exit from function or(and) script
# Usage:
# if $# = 0 : (print: <-- FUNCNAME)
# if $# = 1 : (print: ${1} EXIT_CODE <-- FUNCNAME)
# if $# = 2 : (print: ${2} EXIT_CODE <-- ${1} SCRIPT_NAME <-- FUNCNAME)
print_leave() {

	case "$#" in
		"0") print_log "$LOG_FILE" "<-- ${FUNCNAME[1]}" ;;
		"1") print_log "$LOG_FILE" "${1} <-- ${FUNCNAME[1]}" ;;
		"2") print_log "$LOG_FILE" "${2} <-- ${1} <-- ${FUNCNAME[1]}" ;;
	esac

}

check_required_user() {

	print_enter

	local REQIRED_USER="root"
	local WHOAMI="$(whoami)"

	print_log "$LOG_FILE" "REQIRED_USER='${REQIRED_USER}'"

	if [ "$WHOAMI" != "$REQIRED_USER" ]; then
		print_both "$LOG_FILE" "You must be logged in as ${REQIRED_USER} user - current user is '${WHOAMI}'."
		print_leave "1"
		return 1
	fi

	print_leave "0"
	return 0

}

does_executable_exist() {

	print_enter

	local EXE_TO_CHEK="$(which ${1} 2> /dev/null)"

	print_log "$LOG_FILE" "EXE_TO_CHEK='${EXE_TO_CHEK}'"

	if [ -z "$EXE_TO_CHEK" ]; then
		print_both "$LOG_FILE" "Error: Fail to determine '${1}' executable location. Probably it is not installed."
		print_leave "1"
		return 1
	fi
	if [ ! -x ${EXE_TO_CHEK} ]; then
		print_both "$LOG_FILE" "Error: The '${EXE_TO_CHEK}' executable does not have executable permissions or it does not exist."
		print_leave "1"
		return 1
	fi

	print_leave "0"
	return 0

}

check_required_executables() {

	print_enter

	local -a EXE_LIST=("docker" "docker-compose")
	local iterable_exe

	for iterable_exe in "${EXE_LIST[@]}"
	do
		does_executable_exist "$iterable_exe" || { print_leave "1" ; return 1 ; }
	done

	print_leave "0"
	return 0

}

check_prerequisites() {

	print_enter

	check_required_user || { print_leave "1" ; return 1 ; }

	check_required_executables || { print_leave "1" ; return 1 ; }

	print_leave "0"
	return 0

}

run_cmd() {

	print_enter

	local CMD_TO_RUN="$1"
	local ERR_MSG="$2"

	if ! (${CMD_TO_RUN}); then
		[ "$ERR_MSG" != "Do_Not_Print_Error" ] && print_both "$LOG_FILE" "Error: ${ERR_MSG}. CMD: '${CMD_TO_RUN}'"
		print_leave "1"
		return 1
	fi

	print_leave "0"
	return 0

}

deploy_pizza_express() {

	print_enter

	local PIZZA_DEP_DIR="pizza"
	local DOCKER_COMPOSE_CMD="docker-compose up -d"
	local ERR_MSG="Fail to deploy Pizza-Express with Docker Compose"

	echo -e "\n--> Deploying Pizza-Express with Docker Compose:\n"

	cd ${PIZZA_DEP_DIR}/

	run_cmd "$DOCKER_COMPOSE_CMD" "$ERR_MSG" || { print_leave "1" ; return 1 ; }
	echo -e "\n#=#=#=#=#=#=#=#=#=#=#=#=#=#\n"

	print_leave "0"
	return 0

}

wait_for_web_server() {

	print_enter

	local WAIT_TIME="60"
	local web_srv_status="Down"

	while [[ "$web_srv_status" = "Down" && "WAIT_TIME" -gt "0" ]]
	do
		run_cmd "$CURL_CMD" "Do_Not_Print_Error" &> /dev/null && web_srv_status="Up"
		(( WAIT_TIME-- ))
		sleep 1
	done
	[ "$web_srv_status" = "Down" ] && { print_leave "1" ; return 1 ; }

	print_leave "0"
	return 0

}

validate_pizza_web_server() {

	print_enter

	local WEB_SRV_URL="http://127.0.0.1:8081"
	local CURL_CMD="curl -Is ${WEB_SRV_URL}"
	local CURL_OUTPUT

	echo -e "--> Validating Pizza-Express Web server on '${WEB_SRV_URL}':\n"

	if ! (wait_for_web_server); then
		print_both "$LOG_FILE" "Error: Pizza-Express Web server validation failed."
		print_leave "1"
		return 1
	fi

	CURL_OUTPUT="$(run_cmd "$CURL_CMD" "Do_Not_Print_Error")"
	if ! (echo "$CURL_OUTPUT" | egrep -qs "200[\t ]OK"); then
		print_both "$LOG_FILE" "Error: Not 200 OK status has returned from Pizza-Express Web server."
		echo -e "\n${CURL_OUTPUT}"
		print_leave "1"
		return 1
	fi

	echo "${CURL_OUTPUT}"
	echo -e "#=#=#=#=#=#=#=#=#=#=#=#=#=#\n"

	print_leave "0"
	return 0

}

run_uni_tests() {

	print_enter

	local DOCKER_CMD="docker run --rm -ti --net pizza_new_net dimab07/pizza-express npm test"
	local ERR_MSG="Uni-tests Failed!"

	echo "--> Running Pizza-Express Uni-tests:"

	run_cmd "$DOCKER_CMD" "$ERR_MSG" || { print_leave "1" ; return 1 ; }
	echo -e "#=#=#=#=#=#=#=#=#=#=#=#=#=#\n"

	print_leave "0"
	return 0

}

print_deployment_info() {

	print_enter

	local DOCKER_COMPOSE_CMD="docker-compose ps"

	echo -e "--> Pizza-Express services info:\n"

	${DOCKER_COMPOSE_CMD}
	echo -e "\n#=#=#=#=#=#=#=#=#=#=#=#=#=#\n"

	print_leave "0"
	return 0

}

run_deployment_suite() {

	print_enter

	check_prerequisites || { print_leave "1" ; return 1 ; }

	deploy_pizza_express || { print_leave "1" ; return 1 ; }

	validate_pizza_web_server || { print_leave "1" ; return 1 ; }

	run_uni_tests || { print_leave "1" ; return 1 ; }

	print_deployment_info

	print_leave "0"
	return 0

}

#################[ RUNTIME ]#################

umask 0022

echo "" >> ${LOG_FILE}
print_both "$LOG_FILE" "#=#=#=#[ Starting Pizza-Express deployment ]#=#=#=#"

run_deployment_suite ; EXIT_CODE="$?"

print_log "$LOG_FILE" "#=#=#=#[ (${SCRIPT_BASE_NAME}.sh) Finish -> $([ "$EXIT_CODE" -ne "0" ] && echo -n "Fail!" || echo -n "Completed") <- ]#=#=#=#"
echo "Done"

exit ${EXIT_CODE}

