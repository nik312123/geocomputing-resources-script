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
    if $echo_on; then
        printf "> %s\n\n" "$1"
    fi
    
    if ! eval "$1" >&3 2>&4; then
        print_error_and_exit "$1"
    fi
    
    if $echo_on && [[ "$2" == "true" ]]; then
        printf "\n"
    fi
}

# Raises an error if any parameter is provided more than once
# Takes in the array, index, and name of the parameter
function raise_error_if_index_set {
    declare -a arr=("${!1}")
    
    if [ "${arr[$2]}" -eq 1 ]; then
        printf "The %s parameter was provided more than once.\n\n" "$3" >&2
        exit 1
    fi
}

# If the result of evaluating the check command is true (no error), prints the true-related print
# arguments and runs the true_command argument. Otherwise, prints the false-related print arguments
# and runs the false_command argument, exiting the script with an error if exit_if_false is true.
# The true_echo_newline and false_echo_newline arguments are used to determine whether to print a
# newline after the true and false commands, respectively, if echo_on is true.
function run_command_conditional {
    # Parameter arguments
    local check_command true_print_before true_print_after true_echo_newline true_command
    local false_print_before false_print_after false_echo_newline false_command exit_if_false
    
    required_params_provided=($(seq 0 9 | xargs -I{} echo 0))
    
    # Parses the parameter arguments
    # Based on https://stackoverflow.com/a/12128447
    while [[ ${1} ]]; do
        case "${1}" in
            --check-command)
                raise_error_if_index_set required_params_provided[@] 0 "--check-command"
                required_params_provided[0]=1
                check_command=${2}
                shift
                ;;
            --true-print-before)
                raise_error_if_index_set required_params_provided[@] 1 "--true-print-before"
                required_params_provided[1]=1
                true_print_before=${2}
                shift
                ;;
            --true-print-after)
                raise_error_if_index_set required_params_provided[@] 2 "--true-print-after"
                required_params_provided[2]=1
                true_print_after=${2}
                shift
                ;;
            --true-echo-newline)
                raise_error_if_index_set required_params_provided[@] 3 "--true-echo-newline"
                required_params_provided[3]=1
                true_echo_newline=${2}
                shift
                ;;
            --true-command)
                raise_error_if_index_set required_params_provided[@] 4 "--true-command"
                required_params_provided[4]=1
                true_command=${2}
                shift
                ;;
            --false-print-before)
                raise_error_if_index_set required_params_provided[@] 5 "--false-print-before"
                required_params_provided[5]=1
                false_print_before=${2}
                shift
                ;;
            --false-print-after)
                raise_error_if_index_set required_params_provided[@] 6 "--false-print-after"
                required_params_provided[6]=1
                false_print_after=${2}
                shift
                ;;
            --false-command)
                raise_error_if_index_set required_params_provided[@] 7 "--false-command"
                required_params_provided[7]=1
                false_command=${2}
                shift
                ;;
            --false-echo-newline)
                raise_error_if_index_set required_params_provided[@] 8 "--false-echo-newline"
                required_params_provided[8]=1
                false_echo_newline=${2}
                shift
                ;;
            --exit-if-false)
                raise_error_if_index_set required_params_provided[@] 9 "--exit-if-false"
                required_params_provided[9]=1
                exit_if_false=${2}
                shift
                ;;
            *)
                printf "Unknown parameter: %s\n" "$1" >&2
                return 1
        esac
        
        # Checks if the parameter argument is missing
        if ! shift; then
            printf "Missing parameter argument." >&2
            return 1
        fi
    done
    
    # Checks if all the required arguments were passed
    for element in "${required_params_provided[@]}"; do
        if [ "$element" -eq 0 ]; then
            printf -- "Usage: run_command_conditional --check-command <command> " >&2
            printf -- "--true-print-before <string> --true-print-after <string> " >&2
            printf -- "--true-echo-newline <true/false> --true-command <command> " >&2
            printf -- "--false-print-before <string> --false-print-after <string> " >&2
            printf -- "--false-echo-newline <true/false> --false-command <command> " >&2
            printf -- "--exit-if-false <true/false>\n\n" >&2
            return 1
        fi
    done
    
    # Runs the check command and runs the true or false command depending on the result
    if eval "$check_command" >/dev/null 2>&1; then
        printf "%s" "$true_print_before"
        
        # Runs the true command if it is not empty
        if [[ -n "$true_command" ]]; then
            try_running_command "$true_command" "$true_echo_newline"
        fi
        
        printf "%s" "$true_print_after"
    else
        printf "%s" "$false_print_before"
        
        # Runs the false command if it is not empty
        if [[ -n "$false_command" ]]; then
            try_running_command "$false_command" "$false_echo_newline"
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
elif [ "$os_type" == "MINGW"* ]; then
    bash_login_filename=".bashrc"
    zsh_login_filename=".zshrc"
else
    printf "This script only supports macOS and Git Bash.\n\n"
    exit 1
fi

# Gets the user's GitHub email
github_email_command="read -rp \"Enter the email associated with your GitHub account: \" "
github_email_command+="github_email"

if $echo_on; then
    printf "> ${github_email_command}\n\n"
fi

if ! read -rp "Enter the email associated with your GitHub account: " github_email; then
    print_error_and_exit "$github_email_command"
fi

# Performs a basic check to see if the email is valid
basic_email_regex="^\w+@\w+$"
if ! [[ $github_email =~ $basic_email_regex ]]; then
    printf "Please provide a valid email address.\n\n"
    exit 1
fi

# Check if the user has the ssh key id_nik312123_github_rsa in their ssh folder and if not, generate
ssh_key_false_command="ssh-keygen -t rsa -b 4096 -f \"$HOME/.ssh/id_nik312123_github_rsa\" -C "
ssh_key_false_command+="\"$github_email\""
run_command_conditional \
    --check-command "test -f ~/.ssh/id_nik312123_github_rsa" \
    --true-print-before $'GitHub SSH key already exists! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before $'GitHub SSH key does not exist. ❌\n\nGenerating SSH key... 🗝️\n\n' \
    --false-print-after $'GitHub SSH key has been created! ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "$ssh_key_false_command" \
    --exit-if-false "false"

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
    --check-command "ps aux | grep "ssh-agent" | grep -v grep" \
    --true-print-before $'SSH agent is already running! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before "$add_start_ssh_agent_false_before" \
    --false-print-after "$add_start_ssh_agent_false_after" \
    --false-echo-newline "false" \
    --false-command "$add_start_ssh_agent_false_command" \
    --exit-if-false "true"

# Creates the .ssh/config file if it does not already exist
ssh_config_false_before=$'SSH config file does not exist. ❌\n\n'
ssh_config_false_before+=$'Creating SSH config file... 📝\n\n'
run_command_conditional \
    --check-command "test -f ~/.ssh/config" \
    --true-print-before $'SSH config file already exists! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before "$ssh_config_false_before" \
    --false-print-after $'SSH config file has been created! ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "touch ~/.ssh/config" \
    --exit-if-false "false"

# Adds the SSH key to the SSH config file if it is not already there
add_key_to_ssh_config_false_before=$'SSH key has not been added to SSH config file. ❌\n\n'
add_key_to_ssh_config_false_before+=$'Adding SSH key to SSH config file... 📝\n\n'
add_key_to_ssh_config_text=$'Host github.com\n    AddKeysToAgent yes\n    UseKeychain yes\n'
add_key_to_ssh_config_text+=$'    IdentityFile ~/.ssh/id_nik312123_github_rsa\n'
run_command_conditional \
    --check-command "grep -q 'id_nik312123_github_rsa' ~/.ssh/config" \
    --true-print-before $'SSH key has already been added to SSH config file! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before "$add_key_to_ssh_config_false_before" \
    --false-print-after $'SSH key has been added to SSH config file! ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "printf '$add_key_to_ssh_config_text' >> $HOME/.ssh/config"

# Adds the SSH key to the ssh-agent if it is not already there
add_key_to_ssh_agent_false_before=$'SSH key has not been added to SSH agent. ❌\n\n'
add_key_to_ssh_agent_false_before+=$'Adding SSH key to SSH agent... 🕵️‍♂️\n\n'
run_command_conditional \
    --check-command "ssh-keygen -lf '$HOME/id_nik312123_github_rsa.pub'" \
    --true-print-before $'SSH key has already been added to SSH agent! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before "$add_key_to_ssh_agent_false_before" \
    --false-print-after $'SSH key has been added to SSH agent! ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "ssh-add ~/.ssh/id_nik312123_github_rsa"

printf "Congratulations! Your SSH key for GitHub is properly set up! 💻\n\n"
printf "Please quit and reopen the Terminal to finalize the process.\n\n"
printf "Also, please add your .\n\n"