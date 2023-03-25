# Geocomputing Resources Script

The goal of this script is to install all software needed for geocomputing.

## Running geocomputing resources script

Note: This script can be run on macOS or Ubuntu (including Ubuntu via WSL on Windows).

To run the aforementioned installation script, you may run the following:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/install_geocomputing_requirements.sh" )
```

To run the script in verbose mode (prints commands being run and their outputs) add the `-v` flag like so:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/install_geocomputing_requirements.sh" ) -v
```

You may also simply download the script and run it as follows:

```bash
# Normal
./install_geocomputing_requirements.sh

# Verbose
./install_geocomputing_requirements.sh -v
```

Note that the script can be run multiple times without any issues. It will automatically detect what is already installed and will not reinstall them again.

In fact, it will ensure that all of the installed components are up to date and is therefore encouraged!

## Running GitHub ssh key setup script

Note: This script can be run on macOS or Windows (via Git Bash).

To run the aforementioned installation script, you may run the following:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/setup_ssh_key_for_github.sh" )
```

To run the script in verbose mode (prints commands being run and their outputs) add the `-v` flag like so:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/setup_ssh_key_for_github.sh" ) -v
```

You may also simply download the script and run it as follows:

```bash
# Normal
./setup_ssh_key_for_github.sh

# Verbose
./setup_ssh_key_for_github.sh -v
```
