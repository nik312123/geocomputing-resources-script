# Geocomputing Resources Script

The goal of this script is to install all software needed for geocomputing.

## 1. Running geocomputing resources script

### Introduction:

This script's purpose is to install any necessary geocomputing resources for your machine.

This script can be run on macOS or Ubuntu (including Ubuntu via WSL on Windows).

Note that the script can be run multiple times without any issues. It will automatically detect what is already installed and will not reinstall them again.

In fact, it will ensure that all of the installed components are up to date and is therefore encouraged!

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

## 2. Running GitHub SSH key setup script

### Introduction:

This script's purpose is to set up your SSH key for use with GitHub. Note that this specific script is only made to work for a single device by nature.

This script can be run on macOS or Ubuntu (including Ubuntu via WSL on Windows).

Note that the script can be run multiple times without any issues. It will automatically detect what is already installed and will not reinstall them again.

In fact, it will ensure that all of the installed components are up to date and is therefore encouraged!

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

### Moving SSH key to a different device:

If you originally ran the SSH key setup script on a device (let's say device A) and want to instead have the SSH key set up on another device (let's say device B), then you can run the following to remove the key from your GitHub account on device A:

```bash
gh ssh-key delete -y "$(gh ssh-key list | grep "Geocomputing SSH key" | awk -F '\t' '{print $NF}')"
```

Then, you can run the script above normally on device B.

### Adding the SSH key to a multiple devices:

Alternatively, if you want to create multiple SSH keys for different devices, then you can run the aforementioned SSH setup script for one device and then [follow this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) for any additional SSH keys.

## Video guides:

### 1. Geocomputing initial setup

- [Windows video](https://youtu.be/FTM1roZ5Cvw)
- [Ubuntu video](https://youtu.be/FTM1roZ5Cvw?t=514) (Note: Reuse of Windows video but starts at 8:34 due to sufficient similarity)
- [macOS video](https://youtu.be/vA9tWClzT2g)

### 2. PyCharm setup completion and usage

- [OS-independent video](https://youtu.be/ziNgTmoSyko)
