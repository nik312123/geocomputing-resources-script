#!/usr/bin/env bash
# Gets the environment's location of bash instead of assuming it to be /bin/bash.

# Author: Nikunj Chawla <tinyurl.com/nikunj-cs>

# Prints an error message about running a command and exits the script
function print_error_and_exit {
    printf "\nAn error occurred in running the command: %s\n" "$1"
    printf "Try running the script again, and if the problem still occurs, "
    printf "contact tinyurl.com/nikunj-cs\n\n"
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

# Installs a Homebrew package if it is not installed, and updates it if it is installed
function run_homebrew_install {
    true_before=$'Homebrew\'s '"$1"$' is installed! ✅\n\nUpdating '"$1"$'... Please be patient. This may take some time. '"$2"$'\n\n'
    true_after=$'Homebrew\'s '"$1"$' is updated! ✅\n\n'
    false_before=$'Homebrew\'s '"$1"$' was not found. ❌\n\nInstalling Homebrew\'s '"$1"$'... Please be patient. This may take some time. '"$2"$'\n\n'
    false_after=$'Homebrew\'s '"$1"$' is installed! ✅\n\n'
    
    run_command_conditional \
    --check-command "brew list $1" \
    --true-print-before "$true_before" \
    --true-print-after "$true_after" \
    --true-echo-newline "true" \
    --true-command "brew upgrade $1" \
    --false-print-before "$false_before" \
    --false-print-after "$false_after" \
    --false-echo-newline "true" \
    --false-command "brew install $1" \
    --exit-if-false "false"
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

# Installs Xcode Command Line Tools if they are not already installed
run_command_conditional \
    --check-command "xcode-select -p" \
    --true-print-before $'Xcode Command Line Tools are installed! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before $'Xcode Command Line Tools were not found. ❌\n\nInstalling Xcode Command Line Tools... 🛠️\nFollow the prompt that pops up!\n\n' \
    --false-print-after $'After the installation of the Xcode Command Line Tools is complete, execute this script again.\n\n' \
    --false-echo-newline "true" \
    --false-command "xcode-select --install" \
    --exit-if-false "true"

# Installs homebrew if it does not already exist or updates it if it does
run_command_conditional \
    --check-command "brew help" \
    --true-print-before $'Homebrew is installed! ✅\n\nUpdating homebrew... (Please be patient. This may take some time.) 🍺\n\n' \
    --true-print-after $'Homebrew is updated! ✅\n\n' \
    --true-echo-newline "true" \
    --true-command "brew update" \
    --false-print-before $'Homebrew was not found. ❌\n\nInstalling homebrew... (Please be patient. This may take some time.) 🍺\n\n' \
    --false-print-after $'\nHomebrew is installed! ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "yes \"\" | INTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\"" \
    --exit-if-false "false"

# If Homebrew is installed, calculates the difference between the position of /usr/bin and
# Homebrew's bin
if brew help >/dev/null 2>&1; then
    usr_bin="/usr/bin"
    brew_bin="$(brew --prefix)/bin"
    remainder_usr_bin="${PATH#*"$usr_bin"}"
    remainder_brew_bin="${PATH#*"$brew_bin"}"
    usr_bin_brew_bin_position_diff="$(( ${#remainder_brew_bin} - ${#remainder_usr_bin} ))"
fi

# Checks to see if Homebrew's binary directory is in your path (and at least has a higher presence
# than /usr/bin) and puts it at the beginning of your path if not
if ! brew help >/dev/null 2>&1 || [[ "$PATH" != *"$(brew --prefix)/bin"* ]] \
|| [ "$usr_bin_brew_bin_position_diff" -lt "0" ]; then
    printf "\$(brew --prefix)/bin/ is not in your \$PATH. ❌\n\n"
    printf "Adding \$(brew --prefix)/bin/ to your \$PATH... 📂\n\n"
    
    # If ~/.bash_profile does not exist, create it!
    run_command_conditional \
        --check-command "test -f ~/.bash_profile" \
        --true-print-before "" \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before $'~/.bash_profile could not be found. Creating it for you... 📝\n\n' \
        --false-print-after $'~/.bash_profile created!\n\n' \
        --false-echo-newline "false" \
        --false-command "touch ~/.bash_profile" \
        --exit-if-false "false"
    
    # If ~/.zprofile does not exist, create it!
    run_command_conditional \
        --check-command "test -f ~/.zprofile" \
        --true-print-before "" \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before $'~/.zprofile could not be found. Creating it for you... 📝\n\n' \
        --false-print-after $'~/.zprofile created!\n\n' \
        --false-echo-newline "false" \
        --false-command "touch ~/.zprofile" \
        --exit-if-false "false"
    
    if $echo_on; then
        printf "> if [ -d \"/opt/homebrew\" ]; then\n"
        printf ">     brew_prefix=\"/opt/homebrew\"\n"
        printf "> else\n"
        printf ">    brew_prefix=\"/usr/local\"\n"
        printf "> fi\n\n"
    fi
    
    # Retrieve brew prefix
    if [ -d "/opt/homebrew" ]; then
        brew_prefix="/opt/homebrew"
    else
        brew_prefix="/usr/local"
    fi
    
    if $echo_on; then
        printf "> printf -v load_homebrew_string \"\\\neval \\\\\"\\\$(\\\\\"%%s/bin/brew\\\\\" "
        printf "shellenv)\\\\\"\\\n\\\" \"\$brew_prefix\"\n\n"
    fi
    
    printf -v load_homebrew_string "\\neval \"\$(\"%s/bin/brew\" shellenv)\"\\n" "$brew_prefix"
    
    # Adds Homebrew's binary directory to the beginning of your $PATH variable in your .bash_profile
    # and spits an error if it fails
    try_running_command "printf "%s" \"\$load_homebrew_string\" >> ~/.bash_profile" "false"
    
    # Adds Homebrew's binary directory to the beginning of your $PATH variable in your .zprofile and
    # spits an error if it fails
    try_running_command "printf "%s" \"\$load_homebrew_string\" >> ~/.zprofile" "false"
    
    # Add Homebrew's binary directory to path for the purposes of the rest of this script as well
    eval "$("$brew_prefix/bin/brew" shellenv)"
fi

printf "%s/bin/ is in your \$PATH! ✅\n\n" "$(brew --prefix)"

# Installs a higher version of bash through homebrew if not already using homebrew's bash
run_homebrew_install "bash" "📺"

# Checks if homebrew's bash is in the list of available Terminal shells and adds it if not
run_command_conditional \
    --check-command "grep -q \"\$(brew --prefix)/bin/bash\" /etc/shells" \
    --true-print-before $'The updated bash is in the list of available Terminal shells! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before $'The updated bash is not in the list of available Terminal shells. ❌\n\nAdding the updated bash to the list of Terminal shells... 📜\n\n' \
    --false-print-after $'The updated bash is now in the list of available Terminal shells! ✅\n\n' \
    --false-echo-newline "true" \
    --false-command "sudo sh -c 'printf \"\n\$(brew --prefix)/bin/bash\n\" >> /etc/shells'" \
    --exit-if-false "false"

# If your bash version is not 5.0+, link Terminal to the newest version installed if /bin/bash is
# the default
run_command_conditional \
    --check-command "[[ \${BASH_VERSION%%.*} -gt 4 ]]" \
    --true-print-before $'Your bash version is up to date in your current shell! ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before $'Your current bash is not up to date in your current shell. ❌\n\nUpdating your current bash for your shell... 🔼\n\n' \
    --false-print-after $'Your current bash is now up to date in your current shell! ✅\n\nNow, please restart your Terminal to use the updated bash.\n\n' \
    --false-echo-newline "false" \
    --false-command "if [ \"\$SHELL\" = \"/bin/bash\" ]; then chsh -s \"\$(brew --prefix)/bin/bash\"; fi" \
    --exit-if-false "true"

# Uninstalls Anaconda if it is installed
run_command_conditional \
    --check-command "which conda" \
    --true-print-before $'Anaconda is installed. ❌\n\nUninstalling Anaconda... 🗑\n\n' \
    --true-print-after $'Anaconda is uninstalled. ✅\n\n' \
    --true-echo-newline "true" \
    --true-command "conda install anaconda-clean --yes && anaconda-clean --yes && { rm -rf ~/.anaconda_backup; rm -rf ~/anaconda3; rm -rf ~/opt/anaconda3; sudo rm -rf /Applications/Anaconda-Navigator.app; sudo rm -rf /usr/local/anaconda3; sudo rm -rf /opt/anaconda3; } && true" \
    --false-print-before $'Anaconda is not installed. ✅\n\n' \
    --false-print-after "" \
    --false-echo-newline "false" \
    --false-command "" \
    --exit-if-false "false"

# Installs python3 through Homebrew if not already installed
run_homebrew_install "python3" "🐍"

# Sets up pip and python aliases if not already set up
run_command_conditional \
    --check-command "type pip" \
    --true-print-before $'pip and python are properly aliased. ✅\n\n' \
    --true-print-after "" \
    --true-echo-newline "false" \
    --true-command "" \
    --false-print-before $'pip and python are not properly aliased. ❌\n\nAliasing pip and python... 🔗\n\n' \
    --false-print-after $'pip and python are properly aliased. ✅\n\n' \
    --false-echo-newline "false" \
    --false-command "printf '\nalias pip=\"python3 -m pip3\"\n' >> ~/.bash_profile && printf 'alias python=\"python3\"\n' >> ~/.bash_profile && printf '\nalias pip=\"python3 -m pip3\"\n' >> ~/.zprofile && printf 'alias python=\"python3\"\n' >> ~/.zprofile" \

# Installs gdal through Homebrew if not already installed
run_homebrew_install "gdal" "🌎"

# Installs or updates the required Python packages
run_command_conditional \
    --check-command "true" \
    --true-print-before $'Updating or installing required Python packages... 📦\n\n' \
    --true-print-after $'Required Python packages installed or updated! ✅\n\n' \
    --true-echo-newline "true" \
    --true-command "python3 -m pip install --upgrade -r \"https://gist.githubusercontent.com/nik312123/5f6e7031c023d32881b4adbb2185d38a/raw/4b2f8340c428c8689b1cc468b9da64e9c5fcba97/requirements.txt\"" \
    --false-print-before "" \
    --false-print-after "" \
    --false-echo-newline "false" \
    --false-command "" \
    --exit-if-false "false"

printf "Congratulations! Your computer should be completely set up! 💻\n\n"
printf "Please quit and reopen the Terminal to finalize the process.\n\n"
