#!/usr/bin/env bash
# Gets the environment's location of bash instead of assuming it to be /bin/bash.

# Author: Nikunj Chawla <tinyurl.com/nikunj-cs>

# Prints an error message about running a command and exits the script
function print_error_and_exit {
    printf "\nAn error occurred in running the command: %s\n" "$1"
    printf "Try restarting the Terminal and running the script again with the -v flag.\n"
    printf "If the problem still occurs, contact tinyurl.com/nikunj-cs\n\n"
    exit 1
}

# Tries to run a command and exits the script if it fails
function try_running_command {
    local command="$1"
    local add_newline_after_command="$2"
    local run_without_redirecting_output="$3"
    
    if $echo_on; then
        printf "> %s\n\n" "$command"
    fi
    
    local command_execution_status
    if [[ "$run_without_redirecting_output" == "true" ]]; then
        eval "$command"
        command_execution_status="$?"
    else
        eval "$command" 1>&3 2>&4
        command_execution_status="$?"
    fi
    
    if [[ "$command_execution_status" != "0" ]]; then
        print_error_and_exit "$command"
    fi
    
    local display_output
    if $echo_on || [[ "$run_without_redirecting_output" == "true" ]]; then
        display_output=true
    else
        display_output=false
    fi
    
    if $display_output && [[ "$add_newline_after_command" == "true" ]]; then
        printf "\n"
    fi
}

# Raises an error if the parameter is provided more than once
function raise_parameter_provided_more_than_once_error {
    printf "The %s parameter was provided more than once.\n\n" "$1" >&2
    exit 1
}

# Raises an error if the given required parameter is provided more than once
# Takes in the array, index, and name of the parameter
function raise_error_if_idx_set {
    declare -a arr=("${!1}")
    
    if [ "${arr[$2]}" -eq 1 ]; then
        raise_parameter_provided_more_than_once_error "$3"
    fi
}

# Runs the true command if the check command is true, and the false command otherwise. If running
# the true command, prints the true_print_before before the true_command and the true_print_after
# after the true_command. If running the false command, prints the false_print_before before the
# false_command and the false_print_after after the false_command. If true_echo_newline is provided,
# prints a newline after the true_command if echo_on is true. If false_echo_newline is provided,
# prints a newline after the false_command if echo_on is true. If exit_if_false is set, exits the
# script with an error if the check command is false. If --force-display-output is set, force the
# output of the true and false commands to be displayed even if echo_on is false.
function run_command_conditional {
    # Parameter arguments
    local check_command true_print_before true_print_after true_echo_newline true_command
    local false_print_before false_print_after false_echo_newline false_command exit_if_false
    local force_display_output
    
    # Array of 0s and 1s, where the index represents the parameter and the value represents whether
    # the parameter was provided
    read -ra required_params_provided < <(printf '0%.0s ' $(seq 0 6))
    
    # Default values for optional parameters
    true_echo_newline="false"
    false_echo_newline="false"
    exit_if_false="false"
    force_display_output="false"
        
    # Parses the parameter arguments
    # Based on https://stackoverflow.com/a/12128447
    while [[ ${1} ]]; do
        local previous_argument="$1"
        local param_idx
        
        case "${1}" in
            --check-command)
                param_idx=0
                raise_error_if_idx_set required_params_provided[@] $param_idx "--check-command"
                required_params_provided[param_idx]=1
                check_command="${2}"
                shift
                ;;
            --true-print-before)
                param_idx=1
                raise_error_if_idx_set required_params_provided[@] $param_idx "--true-print-before"
                required_params_provided[param_idx]=1
                true_print_before="${2}"
                shift
                ;;
            --true-print-after)
                param_idx=2
                raise_error_if_idx_set required_params_provided[@] $param_idx "--true-print-after"
                required_params_provided[param_idx]=1
                true_print_after="${2}"
                shift
                ;;
            --true-echo-newline)
                if [[ "$true_echo_newline" == "true" ]]; then
                    raise_parameter_provided_more_than_once_error "--true-echo-newline"
                fi
                true_echo_newline="true"
                ;;
            --true-command)
                param_idx=3
                raise_error_if_idx_set required_params_provided[@] $param_idx "--true-command"
                required_params_provided[param_idx]=1
                true_command="${2}"
                shift
                ;;
            --false-print-before)
                param_idx=4
                raise_error_if_idx_set required_params_provided[@] $param_idx "--false-print-before"
                required_params_provided[param_idx]=1
                false_print_before="${2}"
                shift
                ;;
            --false-print-after)
                param_idx=5
                raise_error_if_idx_set required_params_provided[@] $param_idx "--false-print-after"
                required_params_provided[param_idx]=1
                false_print_after="${2}"
                shift
                ;;
            --false-command)
                param_idx=6
                raise_error_if_idx_set required_params_provided[@] $param_idx "--false-command"
                required_params_provided[param_idx]=1
                false_command="${2}"
                shift
                ;;
            --false-echo-newline)
                if [[ "$false_echo_newline" == "true" ]]; then
                    raise_parameter_provided_more_than_once_error "--false-echo-newline"
                fi
                false_echo_newline="true"
                ;;
            --exit-if-false)
                if [[ "$exit_if_false" == "true" ]]; then
                    raise_parameter_provided_more_than_once_error "--exit-if-false"
                fi
                exit_if_false="true"
                ;;
            --force-display-output)
                if [[ "$force_display_output" == "true" ]]; then
                    raise_parameter_provided_more_than_once_error "--force-display-output"
                fi
                force_display_output="true"
                ;;
            *)
                printf "Unknown parameter: %s\n" "$1" >&2
                return 1
        esac
        
        # Checks if the parameter argument is missing
        if ! shift; then
            printf "Missing parameter argument for %s." "$previous_argument" >&2
            return 1
        fi
    done
    
    # Checks if all the required arguments were passed
    for element in "${required_params_provided[@]}"; do
        if [ "$element" -eq 0 ]; then
            printf -- "Usage: run_command_conditional --check-command <command> " >&2
            printf -- "--true-print-before <string> --true-print-after <string> " >&2
            printf -- "[--true-echo-newline] --true-command <command> " >&2
            printf -- "--false-print-before <string> --false-print-after <string> " >&2
            printf -- "[--false-echo-newline] --false-command <command> " >&2
            printf -- "[--exit-if-false] [--force-display-output]\n\n" >&2
            return 1
        fi
    done
    
    # Runs the check command and runs the true or false command depending on the result
    if eval "$check_command" >/dev/null 2>&1; then
        printf "%s" "$true_print_before"
        
        # Runs the true command if it is not empty
        if [[ -n "$true_command" ]]; then
            try_running_command "$true_command" "$true_echo_newline" "$force_display_output"
        fi
        
        printf "%s" "$true_print_after"
    else
        printf "%s" "$false_print_before"
        
        # Runs the false command if it is not empty
        if [[ -n "$false_command" ]]; then
            try_running_command "$false_command" "$false_echo_newline" "$force_display_output"
        fi
        
        printf "%s" "$false_print_after"
        
        if [[ "$exit_if_false" == "true" ]]; then
            exit 1
        fi
    fi
}

# Prevents the user from executing this script as root as homebrew does not play well with root
function root_check {
    if [ "$(whoami)" == "root" ]; then
        printf "This script cannot be run as root. "
        printf "Please try again as the local user or without running commands such as sudo.\n\n"
        exit 1
    fi
}

# Sets up file descriptors 3 and 4 for the script, depending on whether or not the "-v" flag was
# passed
function fd_setup {
    # If there are more than 1 command-line arguments entered, exit the script
    if [ "$#" -gt 1 ]; then
        printf "This script only supports up to one command-line argument.\n\n"
        exit 1
    # Otherwise, if one command-line argument was entered, throw an error if it is not "-v" and enable
    # echoing/verbose mode otherwise
    elif [ "$#" -eq 1 ]; then
        if [ "$1" != "-v" ]; then
            printf "The only command line argument accepted is the '-v' flag for verbose mode.\n\n"
            exit 1
        fi
        
        # File descriptor 3 is used to redirect stdout to stdout in this case and 4 to redirect stderr
        # to stderr
        if ! exec 3>&1; then
            print_error_and_exit "exec 3>&1"
        fi
        if ! exec 4>&2; then
            print_error_and_exit "exec 4>&2"
        fi
        echo_on=true
    # If no command-line arguments were entered, don't enable echoing
    else
        # File descriptor 3 is used to redirect stdout to /dev/null in this case and 4 to redirect
        # stderr to /dev/null
        if ! exec 3>/dev/null; then
            print_error_and_exit "exec 3>/dev/null"
        fi
        if ! exec 4>&3; then
            print_error_and_exit "exec 4>&3"
        fi
        echo_on=false
    fi
}
