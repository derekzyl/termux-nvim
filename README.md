# TERMUX AND NEOVIM

## Table Of Content
- [Introduction](#introduction)
- [Installations](#installations)
  - [F-Droid](#fdroid)
  - [Termux Installation](#termux-installation)
  - [Download Setup Script](#download-setup-script)
- [Termux setup](#termux-setup)
- [Neovim setup](#neovim-setup)
- [Terminal commands](#terminal-commands)
- [Nvim commands](#nvim-commands)
- [Other settings](#other-settings)

## Introduction
Termux is a powerful terminal emulator and Linux environment app for Android devices. It allows you to access a full-featured command-line interface on your smartphone or tablet, enabling you to run various Linux tools and utilities. Neovim, on the other hand, is an enhanced version of the popular Vim text editor, providing additional features and improvements.

Setting up Neovim within Termux provides a versatile and efficient text editing environment on your Android device. Here's a short guide to help you get started with

## Installations
The files that you will need to download on your device are:
### Fdroid
F-Droid is an alternative app store for Android devices that focuses on providing free and open-source software (FOSS) applications. It is a community-driven platform that offers a wide range of apps that respect user privacy, promote transparency, and adhere to open-source principles. F-Droid provides a decentralized and trustworthy source for downloading apps without relying on proprietary app stores.
- [click on this link to download F-Droid](https://f-droid.org/F-Droid.apk)
download and install the file on your Android devices

### Termux Installation
Termux is an Android application that provides a full-fledged Linux terminal emulator environment on your Android device.
when FDroid is installed, 
install the following packages from F-droid
- Termux:API 
- Unexpected keyboard -optional but best for code writing 
- Termux:Styling- to stylise termux

### Download setup script
 the setup script contains all the commands that you would need to setup termux, install common language servers and download neovim and setup neovim 
 - [use this link to download the shell script](https://drive.google.com/file/d/1Cknn7_lXDKycNNfVIXo8F4zbGGfGUMPn/view?usp=drivesdk)
 a peak at the shell script is shown below

  ```bash
#!/bin/sh
# welcome to shell script for termux startup and neovim setup
#  1 lets start with termux
# ------------------------
#  TERMUX
#------------------------

echo "TERMUX STARTUP"

pkg update -y
pkg upgrade

termux-setup-storage

echo "installing packages and dependencies"
echo -e "nodejs python neovim git python2 python2-dev python3 \n perl bash nano curl openssl openssh wget clang help nmap w3m \n hydra ruby macchanger dnsutils coreut "
package = "nodejs python neovim git python2 python2-dev python3 perl bash nano curl openssl openssh wget clang help nmap w3m hydra ruby macchanger dnsutils coreut "

pkg install -y $package

#  2 lets start with neovim
# ------------------------
#  NEOVIM
#------------------------

echo "NEOVIM STARTUP"
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
cd

foldername=".config"

if [ -d "$foldername" ]; then
    echo "moving to .config folder"
    cd .config

else
    echo "creating .config and changing directory to .config"
    mkdir $foldername && cd $foldername

fi

git clone https://github.com/derekzyl/nvim.git

  ```
### Termux Setup
At this point it is assumed that termux is installed, and the shell script is dowmloaded and its in your downloads folder.
to learn more abour terminal commands check the terminal commands section [here](#terminal-commands)
- first we setup storage copy this command: `termux-setup-storage` then paste it in termux and hit the enter key
- second we navigate to the script downloaded from my drive [here](#download-setup-script)
- thirdly navigate to the downloaded file path in termux; if your file folder default location is downloads, use this commands: just copy and paste in termux `cd && cd storage/downloads`
- for more reference on terminal commands check [here](#terminal-commands)
- run this command the moment you are in the nvim.sh directory: where you downloaded tge files to `sh nvim.sh`
- disclaimer: termux has just few file directory it can access in your storage folder they are:
  - dcim
  - downloads
  - movies
  - music
  - pictures
  - shared
when you see the installation finished message we will then move to neovim


### Neovim Setup
Neovim is a highly extensible text editor, based on the popular Vim editor. It was developed as a modernized and more maintainable version of Vim, with a focus on improved performance, extensibility, and compatibility.
in termux to enter into Neovim environment type
`nvim` and you are in neovim below are guided instructions 
- run `nvim` in termux to open neovim
- for the first time in nvim write pay attention to the colon before the commands
- `:PackerInstall` wait for it to execute click here to get more [info](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://github.com/wbthomason/packer.nvim&ved=2ahUKEwieida38fX_AhWzRkEAHbspAbkQFnoECBAQAQ&usg=AOvVaw25T6jdrrqjja05kt128cu7) 
- run `:PackerSync`
- run `:Mason` more [info](https://github.com/williamboman/mason.nvim)
- install markdown markdown-parser in the mason and any languge server or anything you need  there

- kindly type `cd && cd .config/nvim && nvim` this will take you to the neovim plugin Setup
- by now nerd tree is installed so `n`command will work in **Normal** mode to open and close drawers navigate to the `plugins.lua` file and make research on the installed plugins

### Nvim commands
these are a few commands check **VIM** or **NEOVIM** documentation for more information
#### general information
- in Normal mode is where you run your commands and the quickest path to normal mode is `esc` button
  - `:w` write/save 
  - `i` insert mode: to write text or code
  - `esc` to go back to normal mode
  - `q` quit
  - `q!` force quit
  
#### Moving around

- `h`, `j`, `k`, `l`: Move left, down, up, and right respectively.
- `gg`: Go to the beginning of the file.
- `G`: Go to the end of the file.
- `Ctrl + U`: Scroll half-page up.
- `Ctrl + D`: Scroll half-page down.
- `Ctrl + B`: Scroll one page up.
- `Ctrl + F`: Scroll one page down.
- `Ctrl + E`: Scroll one line down.
- `Ctrl + Y`: Scroll one line up.
- `Ctrl + O`: Jump back to previous location.
- `Ctrl + I`: Jump forward to next location.

#### Editing

- `i`: Enter insert mode at the current cursor position.
- `a`: Enter insert mode after the current cursor position.
- `A`: Enter insert mode at the end of the current line.
- `o`: Insert a new line below the current line and enter insert mode.
- `O`: Insert a new line above the current line and enter insert mode.
- `x`: Delete the character under the cursor.
- `dd`: Delete the current line.
- `yy`: Yank (copy) the current line.
- `p`: Paste the previously yanked or deleted text.

#### Formatting

- `=`: Auto-indent the selected lines or the current block.
- `>`: Increase the indentation of the selected lines or the current line.
- `<`: Decrease the indentation of the selected lines or the current line.
- `:1,10 s/^/    /`: Indent lines 1 to 10 with four spaces.
- `:1,10 s/    //`: Remove four leading spaces from lines 1 to 10.

#### Searching and replacing

- `/`: Start a forward search. Type the search pattern and press Enter.
- `?`: Start a backward search. Type the search pattern and press Enter.
- `n`: Move to the next occurrence of the search pattern.
- `N`: Move to the previous occurrence of the search pattern.
- `:s/search/replace/g`: Replace all occurrences of "search" with "replace" in the current line.
- `:%s/search/replace/g`: Replace all occurrences of "search" with "replace" in the entire file.

These are just a few examples of the many commands available in Neovim. You can refer to Neovim's documentation for more details and additional commands.

### Terminal commands

1. **cd**: Change directory. Used to navigate to different directories/folders.
   Example: `cd Documents` (changes to the "Documents" directory)

2. **ls**: List files and directories in the current directory.
   Example: `ls` (lists files and directories in the current directory)

3. **pwd**: Print working directory. Displays the current directory's full path.
   Example: `pwd` (displays the current directory's path)

4. **mkdir**: Make directory. Creates a new directory.
   Example: `mkdir new_directory` (creates a directory named "new_directory")

5. **rm**: Remove. Deletes files and directories.
   Example: `rm file.txt` (deletes the file "file.txt")

6. **cp**: Copy. Copies files and directories.
   Example: `cp file.txt new_directory` (copies "file.txt" to the "new_directory" directory)

7. **mv**: Move. Moves or renames files and directories.
   Example: `mv file.txt new_directory` (moves "file.txt" to the "new_directory" directory)

8. **cat**: Concatenate. Displays the contents of a file.
   Example: `cat file.txt` (displays the contents of "file.txt")

9. **grep**: Global regular expression print. Searches for patterns in files.
   Example: `grep "hello" file.txt` (searches for the word "hello" in "file.txt")

10. **chmod**: Change mode. Modifies file permissions.
    Example: `chmod +x script.sh` (gives execute permissions to "script.sh")

11. **sudo**: Superuser do. Executes a command with administrative/root privileges.
    Example: `sudo apt-get install package_name` (installs a package using administrative privileges)

12. **apt-get**: Advanced Packaging Tool. Manages software packages on Debian-based systems.
    Example: `apt-get install package_name` (installs a package)

13. **yum**: Yellowdog Updater Modified. Package manager for RPM-based Linux distributions.
    Example: `yum install package_name` (installs a package)

14. **ssh**: Secure Shell. Establishes a secure connection to a remote server.
    Example: `ssh user@hostname` (connects to a remote server)

15. **ping**: Sends network packets to a specific IP address to check connectivity.
    Example: `ping google.com` (sends packets to google.com to check network connectivity)



### Other Settings
below are some set ups to help beautify your termux
- T header follow link [here](https://github.com/remo7777/T-Header)
