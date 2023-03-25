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
    command="$1"
    add_newline_after_command="$2"
    run_without_redirecting_output="$3"
    
    if $echo_on; then
        printf "> %s\n\n" "$command"
    fi
    
    if [[ "$run_without_redirecting_output" == "true" ]]; then
        fd_redirect=""
    else
        fd_redirect=">&3 2>&4"
    fi
    
    # shellcheck disable=SC2046
    if ! eval "$command" $(eval "echo ${fd_redirect}"); then
        print_error_and_exit "$command"
    fi
    
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
function raise_error_if_index_set {
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
    required_params_provided=($(seq 0 6 | xargs -I{} echo 0))
    
    # Default values for optional parameters
    true_echo_newline="false"
    false_echo_newline="false"
    exit_if_false="false"
    force_display_output="false"
        
    # Parses the parameter arguments
    # Based on https://stackoverflow.com/a/12128447
    while [[ ${1} ]]; do
        previous_argument="$1"
        case "${1}" in
            --check-command)
                param_idx=0
                raise_error_if_index_set required_params_provided[@] $param_idx "--check-command"
                required_params_provided[param_idx]=1
                check_command="${2}"
                shift
                ;;
            --true-print-before)
                param_idx=1
                raise_error_if_index_set required_params_provided[@] $param_idx "--true-print-before"
                required_params_provided[param_idx]=1
                true_print_before="${2}"
                shift
                ;;
            --true-print-after)
                param_idx=2
                raise_error_if_index_set required_params_provided[@] $param_idx "--true-print-after"
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
                raise_error_if_index_set required_params_provided[@] $param_idx "--true-command"
                required_params_provided[param_idx]=1
                true_command="${2}"
                shift
                ;;
            --false-print-before)
                param_idx=4
                raise_error_if_index_set required_params_provided[@] $param_idx "--false-print-before"
                required_params_provided[param_idx]=1
                false_print_before="${2}"
                shift
                ;;
            --false-print-after)
                param_idx=5
                raise_error_if_index_set required_params_provided[@] $param_idx "--false-print-after"
                required_params_provided[param_idx]=1
                false_print_after="${2}"
                shift
                ;;
            --false-command)
                param_idx=6
                raise_error_if_index_set required_params_provided[@] $param_idx "--false-command"
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
if [ "$(whoami)" == "root" ]; then
    printf "This script cannot be run as root. "
    printf "Please try again as the local user or without running commands such as sudo.\n\n"
    exit 1
fi

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

# Gets the operating system type
os_type="$(uname -s)"

# Checks if the operating system is supported and runs the appropriate installation function
if [ "$os_type" == "Darwin" ]; then
    bash_login_filename=".bash_profile"
    zsh_login_filename=".zprofile"
elif [ "$os_type" == "Linux" ]; then
    bash_login_filename=".bashrc"
    zsh_login_filename=".zshrc"
else
    printf "This script only supports macOS and Linux/WSL.\n\n"
    exit 1
fi

# Gets the user's GitHub email
if ! [[ -f "$HOME/.ssh/id_nik312123_github_rsa" ]]; then
    github_email_command="read -rp \"Enter the email associated with your GitHub account: \" "
    github_email_command+="github_email"
    
    if $echo_on; then
        printf "> $%s\n\n" "$github_email_command"
    fi
    
    if ! read -rp "Enter the email associated with your GitHub account: " github_email; then
        print_error_and_exit "$github_email_command"
    fi
    printf "\n"
    
    # Basic check to see if the email is valid (Source: https://www.regular-expressions.info/email.html)
    basic_email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if ! [[ $github_email =~ $basic_email_regex ]]; then
        printf "Please provide a valid email address.\n\n"
        exit 1
    fi
fi

# Check if the user has the ssh key id_nik312123_github_rsa in their ssh folder and if not, generate
ssh_key_false_command="ssh-keygen -t rsa -b 4096 -f \"$HOME/.ssh/id_nik312123_github_rsa\" -C "
ssh_key_false_command+="\"$github_email\""
run_command_conditional \
    --check-command "test -f ~/.ssh/id_nik312123_github_rsa" \
    --true-print-before $'GitHub SSH key already exists! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before $'GitHub SSH key does not exist. ❌\n\nGenerating SSH key... 🗝️\n\n' \
    --false-print-after $'GitHub SSH key has been created! ✅\n\n' \
    --false-command "$ssh_key_false_command"

# Adds the ssh-agent startup command to the login files if it is not already there
add_start_ssh_agent_false_after=$'SSH agent startup code has been added to login files! ✅\n\n'
add_start_ssh_agent_false_after+=$'Now, please restart your Terminal to use the updated bash and '
add_start_ssh_agent_false_after+=$'run this script again.\n\n'
add_start_ssh_agent_false_before=$'SSH agent is not running. ❌\n\n'
add_start_ssh_agent_false_before+=$'Adding code to start SSH agent in login files... 📝\n\n'
add_start_ssh_agent_false_command="printf '\neval \"\$(ssh-agent -s)\"\n' >> "
add_start_ssh_agent_false_command+="$HOME/$bash_login_filename && printf "
add_start_ssh_agent_false_command+="'\neval \"\$(ssh-agent -s)\"\n' >> $HOME/$zsh_login_filename"
run_command_conditional \
    --check-command "ps aux | grep \"ssh-agent\" | grep -v grep" \
    --true-print-before $'SSH agent is already running! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$add_start_ssh_agent_false_before" \
    --false-print-after "$add_start_ssh_agent_false_after" \
    --false-command "$add_start_ssh_agent_false_command" \
    --exit-if-false

# Creates the .ssh/config file if it does not already exist
ssh_config_false_before=$'SSH config file does not exist. ❌\n\n'
ssh_config_false_before+=$'Creating SSH config file... 📝\n\n'
run_command_conditional \
    --check-command "test -f ~/.ssh/config" \
    --true-print-before $'SSH config file already exists! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$ssh_config_false_before" \
    --false-print-after $'SSH config file has been created! ✅\n\n' \
    --false-command "touch ~/.ssh/config"

# Adds the SSH key to the SSH config file if it is not already there
add_key_to_ssh_config_false_before=$'SSH key has not been added to SSH config file. ❌\n\n'
add_key_to_ssh_config_false_before+=$'Adding SSH key to SSH config file... 📝\n\n'
add_key_to_ssh_config_text=$'\nHost github.com\n    IgnoreUnknown UseKeychain'
add_key_to_ssh_config_text+=$'\n    AddKeysToAgent yes\n    UseKeychain yes'
add_key_to_ssh_config_text+=$'\n    IdentityFile ~/.ssh/id_nik312123_github_rsa\n'
run_command_conditional \
    --check-command "grep -q 'id_nik312123_github_rsa' ~/.ssh/config" \
    --true-print-before $'SSH key has already been added to SSH config file! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$add_key_to_ssh_config_false_before" \
    --false-print-after $'SSH key has been added to SSH config file! ✅\n\n' \
    --false-command "printf '$add_key_to_ssh_config_text' >> $HOME/.ssh/config"

# Adds the SSH key to the ssh-agent if it is not already there
add_key_to_ssh_agent_false_before=$'SSH key has not been added to SSH agent. ❌\n\n'
add_key_to_ssh_agent_false_before+=$'Adding SSH key to SSH agent... 🕵️‍♂️\n\n'
run_command_conditional \
    --check-command "ssh-keygen -lf '$HOME/.ssh/id_nik312123_github_rsa.pub'" \
    --true-print-before $'SSH key has already been added to SSH agent! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$add_key_to_ssh_agent_false_before" \
    --false-print-after $'SSH key has been added to SSH agent! ✅\n\n' \
    --false-echo-newline \
    --false-command "ssh-add ~/.ssh/id_nik312123_github_rsa"

# Authenticates the gh CLI with GitHub
gh_authenticate_false_before=$'gh is not authenticated with GitHub. ❌\n\n'
gh_authenticate_false_before+=$'Authenticating gh with GitHub... 🔑\n'
run_command_conditional \
    --check-command "gh auth status -h \"github.com\"" \
    --true-print-before $'gh is already authenticated with GitHub! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$gh_authenticate_false_before" \
    --false-print-after $'gh has been authenticated with GitHub! ✅\n\n' \
    --false-echo-newline \
    --false-command "gh auth login -p \"ssh\" -h \"github.com\" --web </dev/null" \
    --force-display-output

printf "Congratulations! Your SSH key for GitHub is properly set up! 💻\n\n"
printf "Please quit and reopen the Terminal to finalize the process.\n\n"
