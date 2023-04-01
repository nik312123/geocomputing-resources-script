#!/usr/bin/env bash
# Gets the environment's location of bash instead of assuming it to be /bin/bash.

# Author: Nikunj Chawla <tinyurl.com/nikunj-cs>

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Load the installation helper script and its functions
installation_common_load_succeeded=true
if [[ -r "$script_directory/installation_common.sh" ]]; then
    #shellcheck disable=SC1091
    if ! source "$script_directory/installation_common.sh"; then
        installation_common_load_succeeded=false
    fi
elif [ "${BASH_VERSION%%.*}" -ge 4 ]; then
    installation_common_url="https://raw.githubusercontent.com/nik312123/"
    installation_common_url+="geocomputing-resources-script/master/installation_common.sh"
    #shellcheck disable=SC1090
    if ! source <(curl -fsL "$installation_common_url" 2>&1 || echo "false"); then
        installation_common_load_succeeded=false
    fi
else
    printf "Your bash version is too old to fully run this script without downloading the " >&2
    printf "repository. ❌\n\nPlease download this repository by downloading it (green code " >&2
    printf "button, then Download ZIP) or by another means.\n\n" >&2
    exit 1
fi

# If the installation helper script could not be loaded, exit the script
if ! $installation_common_load_succeeded; then
    printf "Could not load the installation helper script. Please ensure that either the file " >&2
    printf "is in the same directory as this script or that you have an internet connection." >&2
    printf "\n\n" >&2
    exit 1
fi

# Prevents the user from executing this script as root as some elements of the script do not play
# well with root
root_check

# Sets up file descriptors 3 and 4 for the script, depending on whether or not the "-v" flag was
# passed
fd_setup "$@"

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
    printf "This script only supports macOS and Linux/WSL.\n\n" >&2
    exit 1
fi

# Gets the user's GitHub email
if ! [[ -f "$HOME/.ssh/id_nik312123_github_rsa" ]]; then
    github_email_command="read -rp \"Enter the email associated with your GitHub account: \" "
    github_email_command+="github_email"
    
    #shellcheck disable=SC2154
    if $echo_on; then
        printf "> $%s\n\n" "$github_email_command"
    fi
    
    if ! read -rp "Enter the email associated with your GitHub account: " github_email; then
        print_error_and_exit "$github_email_command"
    fi
    printf "\n"
    
    # Basic check to see if the email is valid
    # Source: https://www.regular-expressions.info/email.html
    basic_email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if ! [[ $github_email =~ $basic_email_regex ]]; then
        printf "Please provide a valid email address.\n\n" >&2
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
    --false-print-after $'\nGitHub SSH key has been created! ✅\n\n' \
    --false-command "$ssh_key_false_command"

# Adds the ssh-agent startup command to the login files if it is not already there
add_start_ssh_agent_false_after=$'SSH agent startup code has been added to login files! ✅\n\n'
add_start_ssh_agent_false_after+=$'Now, please restart your Terminal to load SSH agent and '
add_start_ssh_agent_false_after+=$'run this script again.\n\n'
add_start_ssh_agent_false_before=$'SSH agent is not running. ❌\n\n'
add_start_ssh_agent_false_before+=$'Adding code to start SSH agent in login files... 📝\n\n'
add_start_ssh_agent_false_command="printf '\neval \"\$(ssh-agent -s)\" >/dev/null\n' >> "
add_start_ssh_agent_false_command+="$HOME/$bash_login_filename && printf "
add_start_ssh_agent_false_command+="'\neval \"\$(ssh-agent -s)\" >/dev/null\n' >> $HOME/$zsh_login_filename"
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
gh_authenticate_command="gh auth login -p \"ssh\" "
gh_authenticate_command+="-s \"admin:public_key, gist, read:org, repo\" -h \"github.com\" --web "
gh_authenticate_command+="< /dev/null"
run_command_conditional \
    --check-command "gh auth status -h \"github.com\"" \
    --true-print-before $'gh is already authenticated with GitHub! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$gh_authenticate_false_before" \
    --false-print-after $'gh has been authenticated with GitHub! ✅\n\n' \
    --false-echo-newline \
    --false-command "$gh_authenticate_command" \
    --force-display-output

# Adds the SSH key to GitHub if it is not already there
github_add_key_false_before=$'Geocomputing SSH key is not added to GitHub. ❌\n\n'
github_add_key_false_before+=$'Adding geocomputing SSH key to GitHub. 🔑\n\n'
github_add_key_false_command="gh ssh-key add $HOME/.ssh/id_nik312123_github_rsa.pub -t "
github_add_key_false_command+="\"Geocomputing SSH key\""
run_command_conditional \
    --check-command "gh ssh-key list | grep -q \"Geocomputing SSH key\"" \
    --true-print-before $'Geocomputing SSH key is added to GitHub! ✅\n\n' \
    --true-print-after "" \
    --true-command "" \
    --false-print-before "$github_add_key_false_before" \
    --false-print-after $'Geocomputing SSH key has been added to GitHub! ✅\n\n' \
    --false-command "$github_add_key_false_command" \

printf "Congratulations! Your SSH key for GitHub is properly set up! 💻\n\n"
printf "Please quit and reopen the Terminal to finalize the process.\n\n"
