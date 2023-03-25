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

# Installs a Homebrew package if it is not installed, and updates it if it is installed
function run_homebrew_install {
    true_before=$'Homebrew\'s '"$1"$' is installed! ✅\n\nUpdating '"$1"$'... Please be patient. '
    true_before+=$'This may take some time. '"$2"$'\n\n'
    true_after=$'Homebrew\'s '"$1"$' is updated! ✅\n\n'
    false_before=$'Homebrew\'s '"$1"$' was not found. ❌\n\nInstalling Homebrew\'s '"$1"$'... '
    false_before+=$'Please be patient. This may take some time. '"$2"$'\n\n'
    false_after=$'Homebrew\'s '"$1"$' is installed! ✅\n\n'
    
    run_command_conditional \
    --check-command "brew list $1" \
    --true-print-before "$true_before" \
    --true-print-after "$true_after" \
    --true-echo-newline "true" \
    --true-command "HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade $1" \
    --false-print-before "$false_before" \
    --false-print-after "$false_after" \
    --false-echo-newline "true" \
    --false-command "HOMEBREW_NO_AUTO_UPDATE=1 brew install $1" \
    --exit-if-false "false"
}

# Creates the bash and zsh login files if they do not exist
function create_bash_login_files {
    bash_login_filename="$1"
    zsh_login_filename="$2"
    
    # If the bash login file does not exist, create it!
        bash_login_false_before="$HOME/$bash_login_filename"$' could not be found. Creating it '
        bash_login_false_before+=$'for you... 📝\n\n'
        run_command_conditional \
            --check-command "test -f \"$HOME/$bash_login_filename\"" \
            --true-print-before "" \
            --true-print-after "" \
            --true-echo-newline "false" \
            --true-command "" \
            --false-print-before "$bash_login_false_before" \
            --false-print-after "$HOME/$bash_login_filename"$' created!\n\n' \
            --false-echo-newline "false" \
            --false-command "touch \"$HOME/$bash_login_filename\"" \
            --exit-if-false "false"
        
        # If the zsh login file does not exist, create it!
        zsh_login_false_before="$HOME/$zsh_login_filename"$' could not be found. Creating it '
        zsh_login_false_before+=$'for you... 📝\n\n'
        run_command_conditional \
            --check-command "test -f \"$HOME/$zsh_login_filename\"" \
            --true-print-before "" \
            --true-print-after "" \
            --true-echo-newline "false" \
            --true-command "" \
            --false-print-before "$zsh_login_false_before" \
            --false-print-after "$HOME/$zsh_login_filename"$' created!\n\n' \
            --false-echo-newline "false" \
            --false-command "touch \"$HOME/$zsh_login_filename\"" \
            --exit-if-false "false"
}

# Uninstalls Anaconda if it is installed
function uninstall_anaconda {
    anaconda_paths=(
        "$HOME/.conda"
        "$HOME/.condarc"
        "$HOME/.continuum"
        "$HOME/.anaconda_backup"
        "$HOME/anaconda*"
        "$HOME/.spyder*"
        "$HOME/opt/anaconda*"
        "/Applications/Anaconda-Navigator.app"
        "/usr/local/anaconda*"
        "/opt/anaconda*"
        "/usr/local/bin/anaconda*"
        "/usr/local/bin/conda*"
        "/usr/bin/anaconda*"
        "/usr/bin/conda*"
        "$HOME/bin/anaconda*"
        "$HOME/bin/conda*"
        "/usr/share/applications/anaconda-navigator.desktop"
        "/usr/share/applications/anaconda.desktop"
        "/usr/share/icons/hicolor/*/apps/anaconda.png"
    )
    
    anaconda_true_command="conda install anaconda-clean --yes && anaconda-clean --yes && { "
    for path in "${anaconda_paths[@]}"; do
        anaconda_true_command+="sudo rm -rf $path; "
    done
    anaconda_true_command+="}; true"
    run_command_conditional \
        --check-command "command -v conda || command -v anaconda" \
        --true-print-before $'Anaconda is installed. ❌\n\nUninstalling Anaconda... 🗑\n\n' \
        --true-print-after $'Anaconda is uninstalled. ✅\n\n' \
        --true-echo-newline "true" \
        --true-command "$anaconda_true_command" \
        --false-print-before $'Anaconda is not installed. ✅\n\n' \
        --false-print-after "" \
        --false-echo-newline "false" \
        --false-command "" \
        --exit-if-false "false"
}

# Upgrades pip
function upgrade_pip {
    run_command_conditional \
        --check-command "true" \
        --true-print-before $'Ensuring pip is up to date... 📚\n\n' \
        --true-print-after $'pip is up to date! ✅\n\n' \
        --true-echo-newline "true" \
        --true-command "python3 -m pip install --upgrade pip" \
        --false-print-before "" \
        --false-print-after "" \
        --false-echo-newline "false" \
        --false-command "" \
        --exit-if-false "false"
}

# Adds aliases for pip and python if they are not aliased
function alias_python3_and_pip {
    bash_login_filename="$1"
    zsh_login_filename="$2"
    
    if [[ "$SHELL" == *"/zsh" ]]; then
        user_profile="$zsh_login_filename"
    else
        user_profile="$bash_login_filename"
    fi
    
    python_check_command="grep -q 'alias python=\"python3\"' \"$HOME/$user_profile\" && "
    python_check_command+="grep -q 'alias pip=\"python3 -m pip\"' \"$HOME/$user_profile\""
    python_alias_false_before=$'pip and python are not properly aliased. ❌\n\nAliasing pip and '
    python_alias_false_before+=$'python... 🔗\n\n'
    python_alias_false_command="printf '\nalias python=\"python3\"\n' >> "
    python_alias_false_command+="$HOME/$bash_login_filename && printf 'alias pip=\"python3 -m "
    python_alias_false_command+="pip\"\n' >> $HOME/$bash_login_filename && printf '\nalias "
    python_alias_false_command+="python=\"python3\"\n' >> $HOME/$zsh_login_filename && printf "
    python_alias_false_command+="'alias pip=\"python3 -m pip\"\n' >> $HOME/$zsh_login_filename"
    run_command_conditional \
        --check-command "$python_check_command" \
        --true-print-before $'pip and python are properly aliased. ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$python_alias_false_before" \
        --false-print-after $'pip and python are properly aliased. ✅\n\n' \
        --false-echo-newline "false" \
        --false-command "$python_alias_false_command" \
        --exit-if-false "false"
}

# Installs or updates the required Python packages
function install_required_python_packages {
    python_package_true_command="python3 -m pip install --upgrade -r "
    python_package_true_command+="\"https://raw.githubusercontent.com/nik312123/"
    python_package_true_command+="geocomputing-resources-script/master/requirements.txt\""
    run_command_conditional \
        --check-command "true" \
        --true-print-before $'Installing or updating the required Python packages... 📦\n\n' \
        --true-print-after $'The required Python packages have been installed or updated! ✅\n\n' \
        --true-echo-newline "true" \
        --true-command "$python_package_true_command" \
        --false-print-before "" \
        --false-print-after "" \
        --false-echo-newline "false" \
        --false-command "" \
        --exit-if-false "false"
}

function install_requirements_macos {
    # Installs Xcode Command Line Tools if they are not already installed
    xcode_false_before=$'Xcode Command Line Tools were not found. ❌\n\nInstalling Xcode Command '
    xcode_false_before+=$'Line Tools... 🛠️\nFollow the prompt that pops up!\n\n'
    xcode_false_after=$'After the installation of the Xcode Command Line Tools is complete, '
    xcode_false_after+=$'execute this script again.\n\n'
    run_command_conditional \
        --check-command "xcode-select -p" \
        --true-print-before $'Xcode Command Line Tools are installed! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$xcode_false_before" \
        --false-print-after "$xcode_false_after" \
        --false-echo-newline "true" \
        --false-command "xcode-select --install" \
        --exit-if-false "true"
    
    # Installs homebrew if it does not already exist or updates it if it does
    homebrew_true_before=$'Homebrew is installed! ✅\n\nUpdating homebrew and its packages... '
    homebrew_true_before+=$'(Please be patient. This may take some time.) 🍺\n\n'
    homebrew_false_before=$'Homebrew was not found. ❌\n\nInstalling homebrew... (Please be '
    homebrew_false_before+=$'patient. This may take some time.) 🍺\n\n'
    homebrew_false_command="yes \"\" | INTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://"
    homebrew_false_command+="raw.githubusercontent.com/Homebrew/install/master/install.sh)\""
    run_command_conditional \
        --check-command "brew help" \
        --true-print-before "$homebrew_true_before" \
        --true-print-after $'Homebrew is updated! ✅\n\n' \
        --true-echo-newline "true" \
        --true-command "brew update && brew upgrade && brew cleanup --prune=all -s" \
        --false-print-before "$homebrew_false_before" \
        --false-print-after $'\nHomebrew is installed! ✅\n\n' \
        --false-echo-newline "false" \
        --false-command "$homebrew_false_command" \
        --exit-if-false "false"
    
    # Creates the bash and zsh login files if they do not exist
    bash_login_filename=".bash_profile"
    zsh_login_filename=".zprofile"
    create_bash_login_files "$bash_login_filename" "$zsh_login_filename"
    
    # If Homebrew is installed, calculates the difference between the position of /usr/bin and
    # Homebrew's bin
    if brew help >/dev/null 2>&1; then
        usr_bin="/usr/bin"
        brew_bin="$(brew --prefix)/bin"
        remainder_usr_bin="${PATH#*"$usr_bin"}"
        remainder_brew_bin="${PATH#*"$brew_bin"}"
        usr_bin_brew_bin_position_diff="$(( ${#remainder_brew_bin} - ${#remainder_usr_bin} ))"
    fi
    
    # Checks to see if Homebrew's binary directory is in your path (and at least has a higher
    # presence than /usr/bin) and puts it at the beginning of your path if not
    if ! brew help >/dev/null 2>&1 || [[ "$PATH" != *"$(brew --prefix)/bin"* ]] \
    || [ "$usr_bin_brew_bin_position_diff" -lt "0" ]; then
        printf "\$(brew --prefix)/bin/ is not in your \$PATH. ❌\n\n"
        printf "Adding \$(brew --prefix)/bin/ to your \$PATH... 📂\n\n"
        
        # Retrieve brew prefix
        
        # Apple silicon macOS prefix
        if [ -d "/opt/homebrew" ]; then
            brew_prefix="/opt/homebrew"
        # Intel macOS prefix
        else
            brew_prefix="/usr/local"
        fi
        
        if $echo_on; then
            printf "> printf -v load_homebrew_string \"\\\\\\\neval \\\\\"\\\$(\\\\\"%%s/bin/brew"
            printf "\\\\\" shellenv)\\\\\"\\\\\\\n\" \"\$brew_prefix\"\n\n"
        fi
        
        printf -v load_homebrew_string "\\neval \"\$(\"%s/bin/brew\" shellenv)\"\\n" "$brew_prefix"
        
        # Adds Homebrew's binary directory to the beginning of your $PATH variable in your bash
        # login file and spits an error if it fails
        load_brew_bash="printf \"%s\" \"\$load_homebrew_string\" >> $HOME/$bash_login_filename"
        try_running_command "$load_brew_bash" "false"
        
        # Adds Homebrew's binary directory to the beginning of your $PATH variable in your zsh login
        # file and spits an error if it fails
        load_brew_zsh="printf \"%s\" \"\$load_homebrew_string\" >> $HOME/$zsh_login_filename"
        try_running_command "$load_brew_zsh" "false"
        
        printf "%s/bin/ is in your \$PATH! ✅\n\n" "$brew_prefix"
        printf "Now, please restart your Terminal to load Homebrew properly into your \$PATH and "
        printf "run this script again.\n\n"
        exit 1
    fi
    
    printf "%s/bin/ is in your \$PATH! ✅\n\n" "$(brew --prefix)"
    
    # Installs a higher version of bash through homebrew if not already using homebrew's bash
    run_homebrew_install "bash" "📺"
    
    # Checks if homebrew's bash is in the list of Terminal shells and adds it if not
    bash_false_before=$'The updated bash is not in the list of Terminal shells. ❌\n\n'
    bash_false_before+=$'Adding the updated bash to the list of Terminal shells... 📜\n\n'
    bash_false_after=$'The updated bash is now in the list of Terminal shells! ✅\n\n'
    run_command_conditional \
        --check-command "grep -q \"\$(brew --prefix)/bin/bash\" /etc/shells" \
        --true-print-before $'The updated bash is in the list of Terminal shells! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$bash_false_before" \
        --false-print-after "$bash_false_after" \
        --false-echo-newline "true" \
        --false-command "sudo sh -c 'printf \"\n$(brew --prefix)/bin/bash\n\" >> /etc/shells'" \
        --exit-if-false "false"
    
    # If your bash version is not 5.0+, link Terminal to the newest version installed if /bin/bash
    # is the default
    bash_version_false_before=$'Your current bash is not up to date in your current shell. ❌\n\n'
    bash_version_false_before+=$'Updating your current bash for your shell... 🔼\n\n'
    bash_version_false_after=$'Your current bash is now up to date in your current shell! ✅\n\n'
    bash_version_false_after+=$'Now, please restart your Terminal to use the updated bash and run '
    bash_version_false_after+=$'this script again.\n\n'
    bash_version_false_command="if [ \"\$SHELL\" = \"/bin/bash\" ]; then chsh -s "
    bash_version_false_command+="\"\$(brew --prefix)/bin/bash\"; fi"
    run_command_conditional \
        --check-command "[[ \${BASH_VERSION%%.*} -gt 4 ]]" \
        --true-print-before $'Your bash version is up to date in your current shell! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$bash_version_false_before" \
        --false-print-after "$bash_version_false_after" \
        --false-echo-newline "false" \
        --false-command "$bash_version_false_command" \
        --exit-if-false "true"
    
    # Installs git through homebrew if not already installed
    run_homebrew_install "git" "🐙"
    
    # Installs gh through homebrew if not already installed
    run_homebrew_install "gh" "🐙"
    
    # Uninstalls Anaconda if it is installed
    uninstall_anaconda
    
    # Installs python3 through Homebrew if not already installed
    run_homebrew_install "python3" "🐍"
    
    # Upgrades pip if not already up to date
    upgrade_pip
    
    # Sets up pip and python aliases if not already set up
    alias_python3_and_pip "$bash_login_filename" "$zsh_login_filename"
    
    # Installs GDAL through Homebrew if not already installed
    run_homebrew_install "GDAL" "🌎"
    
    # Installs or updates the required Python packages
    install_required_python_packages
}

function install_requirements_linux_wsl {
    # Updates apt packages if they are not already up to date and installs some script dependencies
    # if they are not already installed
    run_command_conditional \
        --check-command "true" \
        --true-print-before $'Ensuring apt packages are up to date... 📦\n\n' \
        --true-print-after $'Apt packages are up to date! ✅\n\n' \
        --true-echo-newline "true" \
        --true-command "sudo apt update -y && sudo apt upgrade -y" \
        --false-print-before "" \
        --false-print-after "" \
        --false-echo-newline "false" \
        --false-command "" \
        --exit-if-false "false"
    
    # Installs script dependencies if they are not already installed
    script_dependencies="build-essential bash procps curl file git"
    script_dependencies_check_command=""
    for dependency in $script_dependencies; do
        script_dependencies_check_command+="dpkg -s $dependency && "
    done
    script_dependencies_check_command=${script_dependencies_check_command% && }
    script_dependencies_false_before=$'Script dependencies are not installed. ❌\n\n'
    script_dependencies_false_before+=$'Installing script dependencies... 🧱\n\n'
    run_command_conditional \
        --check-command "$script_dependencies_check_command" \
        --true-print-before $'Script dependencies are installed! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$script_dependencies_false_before" \
        --false-print-after $'Script dependencies have been installed! ✅\n\n' \
        --false-echo-newline "true" \
        --false-command "sudo apt install $script_dependencies -y" \
        --exit-if-false "false"
    
    # Installs gh if it is not already installed
    gh_keyring_path="/usr/share/keyrings/githubcli-archive-keyring.gpg"
    gh_install_false_command="curl -fsSL "
    gh_install_false_command+="https://cli.github.com/packages/githubcli-archive-keyring.gpg | "
    gh_install_false_command+="sudo dd of=$gh_keyring_path"
    gh_install_false_command+=" && sudo chmod go+r $gh_keyring_path"
    gh_install_false_command+=" && echo \"deb [arch=$(dpkg --print-architecture) signed-by="
    gh_install_false_command+="$gh_keyring_path] https://cli.github.com/packages stable main\" "
    gh_install_false_command+="| sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    gh_install_false_command+=" && sudo apt update -y && sudo apt install gh -y"
    run_command_conditional \
        --check-command "command -v gh" \
        --true-print-before $'gh is installed! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before $'gh is not installed. ❌\n\nInstalling gh... 🐙\n\n' \
        --false-print-after $'gh has been installed! ✅\n\n' \
        --false-echo-newline "true" \
        --false-command "$gh_install_false_command" \
        --exit-if-false "false"
    
    # Creates the bash and zsh login files if they do not exist
    bash_login_filename=".bashrc"
    zsh_login_filename=".zshrc"
    create_bash_login_files "$bash_login_filename" "$zsh_login_filename"
    
    # Adds your local bin to your path if it is not already in your path
    local_bin_check_command="grep -q 'export PATH=\"\$HOME/.local/bin:\$PATH\"' "
    local_bin_check_command+="\"$HOME/$bash_login_filename\""
    local_bin_false_before=$'Your local bin is not in your path. ❌\n\n'
    local_bin_false_before+=$'Adding your local bin to your path... 📂\n\n'
    local_bin_false_after=$'Your local bin is now in your path! ✅\n\nNow, please restart your '
    local_bin_false_after+=$'Terminal to load your local bin properly into your $PATH and run this '
    local_bin_false_after+=$'script again.\n\n'
    local_bin_false_command="printf \"\\nexport PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\\n\""
    local_bin_false_command+=" >> $HOME/$bash_login_filename"
    local_bin_false_command+=" && printf \"\\nexport PATH=\\\"\\\$HOME/.local/bin:\\\$PATH\\\"\\n\""
    local_bin_false_command+=" >> $HOME/$zsh_login_filename"
    run_command_conditional \
        --check-command "$local_bin_check_command" \
        --true-print-before $'Your local bin is already in your path! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$local_bin_false_before" \
        --false-print-after "$local_bin_false_after" \
        --false-echo-newline "false" \
        --false-command "$local_bin_false_command" \
        --exit-if-false "true"
    
    # Uninstalls Anaconda if it is installed
    uninstall_anaconda
    
    # Install python3 and pip3 through apt if not already installed
    python3_false_before=$'python3 and pip3 are not installed. ❌\n\n'
    python3_false_before+=$'Installing python3 and pip3... 🐍\n\n'
    run_command_conditional \
        --check-command "dpkg -s python3 && dpkg -s python3-pip" \
        --true-print-before $'python3 and pip3 are installed. ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$python3_false_before" \
        --false-print-after $'python3 and pip3 have been installed! ✅\n\n' \
        --false-echo-newline "true" \
        --false-command "sudo apt install python3 python3-pip -y" \
        --exit-if-false "false"
    
    # Upgrades pip if not already up to date
    upgrade_pip
    
    # Sets up pip and python aliases if not already set up
    alias_python3_and_pip "$bash_login_filename" "$zsh_login_filename"
    
    # Adds the apt repository for GDAL if not already added
    gdal_repository_check_command="apt-cache policy | grep -q "
    gdal_repository_check_command+="\"ppa.launchpadcontent.net/ubuntugis/ppa/ubuntu\""
    gdal_repository_false_before=$'The apt repository for GDAL was not installed. ❌\n\n'
    gdal_repository_false_before+=$'Adding the apt repository for GDAL... 📦\n\n'
    run_command_conditional \
        --check-command "$gdal_repository_check_command" \
        --true-print-before $'The apt repository for GDAL is added! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before "$gdal_repository_false_before" \
        --false-print-after "The apt repository for GDAL has been added! ✅\n\n" \
        --false-echo-newline "true" \
        --false-command "sudo add-apt-repository ppa:ubuntugis/ppa -y && sudo apt update -y" \
        --exit-if-false "false"
    
    # Installs GDAL through apt if not already installed
    run_command_conditional \
        --check-command "dpkg -s gdal-bin && dpkg -s libgdal-dev && dpkg -s python3-gdal" \
        --true-print-before $'GDAL is installed! ✅\n\n' \
        --true-print-after "" \
        --true-echo-newline "false" \
        --true-command "" \
        --false-print-before $'GDAL is not installed. ❌\n\nInstalling GDAL... 🌎\n\n' \
        --false-print-after $'GDAL has been installed! ✅\n\n' \
        --false-echo-newline "false" \
        --false-command "sudo apt install gdal-bin libgdal-dev python3-gdal -y" \
        --exit-if-false "true"
    
    # Installs or updates the required Python packages
    install_required_python_packages
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
    install_requirements_macos
elif [ "$os_type" == "Linux" ]; then
    install_requirements_linux_wsl
else
    printf "This script only supports macOS and Linux/WSL.\n\n"
    exit 1
fi

printf "Congratulations! Your computer should be completely set up! 💻\n\n"
printf "Please quit and reopen the Terminal to finalize the process.\n\n"
