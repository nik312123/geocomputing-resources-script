# Geocomputing Resources Script

The goal of this script is to install all software needed for geocomputing.

## 1. Running geocomputing resources script

### Introduction:

Note: This script can be run on macOS or Ubuntu (including Ubuntu via WSL on Windows).

### Remote installation methods:

To run the aforementioned installation script if you have bash 4 or higher, you may run the following:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/install_geocomputing_requirements.sh" )
```

To run the script in verbose mode (prints commands being run and their outputs) in bash 4 or higher, add the `-v` or `--verbose` flag like so:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/install_geocomputing_requirements.sh" ) -v
```

### Local installation methods:

macOS unfortunately does not have bash 4 or higher by default (check your bash version by running `echo "$BASH_VERSION"` in Terminal). As such, if you do not have a high enough version of bash, you will need to either clone this repository to run the script locally or download the repository as a zip and run the script locally.

It would also be worth downloading the repository and running the script locally if you have a slow internet connection.

To run this script locally, navigate into the unzipped or cloned repository using `cd geocomputing-resources-script`, and inside of it, you may run one of the following:

```bash
# Normal
./install_geocomputing_requirements.sh

# Verbose (can also use --verbose)
./install_geocomputing_requirements.sh -v
```

Note that the script can be run multiple times without any issues. It will automatically detect what is already installed and will not reinstall them again.

In fact, it will ensure that all of the installed components are up to date and is therefore encouraged!

## 2. Running GitHub SSH key setup script


### Introduction:

Note: This script can be run on macOS or Ubuntu (including Ubuntu via WSL on Windows).

### Remote installation methods:

To run the aforementioned installation script on bash 4 or higher, you may run the following:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/setup_ssh_key_for_github.sh" )
```

To run the script in verbose mode (prints commands being run and their outputs) on bash 4 or higher, add the `-v` or `--verbose` flag like so:

```bash
bash <( curl -fsSL "https://raw.githubusercontent.com/nik312123/geocomputing-resources-script/master/setup_ssh_key_for_github.sh" ) -v
```

### Local installation methods:

macOS unfortunately does not have bash 4 or higher by default (check your bash version by running `echo "$BASH_VERSION"` in Terminal). As such, if you do not have a high enough version of bash, you will need to either clone this repository to run the script locally or download the repository as a zip and run the script locally.

It would also be worth downloading the repository and running the script locally if you have a slow internet connection.

To run this script locally, navigate into the unzipped or cloned repository using `cd geocomputing-resources-script`, and inside of it, you may run one of the following:

```bash
# Normal
./setup_ssh_key_for_github.sh

# Verbose (can also use --verbose)
./setup_ssh_key_for_github.sh -v
```
