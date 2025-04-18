#!/bin/bash
# Termux startup and Neovim setup script

# Function to check and handle errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred. Exiting..."
        exit 1
    fi
}

# Function to install a package
install_package() {
    pkg install "$1" -y || { echo "Error installing $1"; exit 1; }
    echo "$1 installed"
}

echo "TERMUX STARTUP"

# Prompt for storage access
termux-setup-storage || { echo "Error setting up storage"; exit 1; }

# Change termux repository
termux-change-repo || { echo "Error changing repository"; exit 1; }

echo "Updating and upgrading Termux"
pkg update -y || { echo "Error updating"; exit 1; }
pkg upgrade -y || { echo "Error upgrading"; exit 1; }

echo "Installing packages and dependencies"
echo "-----------------------------"

# List of packages to install
packages="python neovim nodejs git curl openssl openssh wget gh build-essential  tmux  wget curl "

for package in $packages; do
    install_package "$package"
done

# Neovim Setup
echo "NEOVIM STARTUP"

echo "installing neovim dependencies \n"

echo "install pyright globaly \n"

npm install -g pyright
npm install -g typescript typescript-language-server

if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || { echo "Error cloning Neovim"; exit 1; }
else
    echo "Destination path '~/.local/share/nvim/site/pack/packer/start/packer.nvim' already exists and is not an empty directory. Skipping clone."
fi

cd

foldername=".config"

if [ -d "$foldername" ]; then
    echo "Moving to .config folder"
    cd .config || { echo "Error changing to .config"; exit 1; }
else
    echo "Creating .config and changing directory to .config"
    mkdir "$foldername" && cd "$foldername" || { echo "Error creating .config"; exit 1; }
fi



nvim_dir="nvim"

if [ ! -d "$nvim_dir" ]; then
    echo "Cloning the git repository for Neovim plugin setup"
    git clone https://github.com/derekzyl/nvim.git || { echo "Error cloning Neovim repository"; exit 1; }
else
    echo "An existing 'nvim' folder was found. Do you want to delete it and clone again? [y|Y|n|N]"

    read -p "[y|Y|n|N]"  user_input_nvim

    if [ "$user_input_nvim" = "y" ] || [ "$user_input_nvim" = "Y" ]; then
        echo "Removing the 'nvim' folder..."
        rm -rf "$nvim_dir"

        echo "Removed 'nvim' folder, cloning 'nvim.git'..."
        git clone https://github.com/derekzyl/nvim.git || { echo "Error cloning Neovim repository"; exit 1; }
    else
        echo "Exiting 'nvim' plugin cloning."
    fi
fi
nvim_config_folder="~/.config/nvim/pack/nvim/start/nvim-lspconfig"

if [! -d "$nvim_config_folder" ]; then
  git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/nvim/start/nvim-lspconfig
fi    

echo "Would you want to make Neovim your default code editor in Termux? [Y|y|N|n]"

read -p  "[y|Y|n|N]"  user_input_neovim

if [ "$user_input_neovim" = "y" ] || [ "$user_input_neovim" = "Y" ]; then
    ln -s /data/data/com.termux/files/usr/bin/nvim ~/bin/termux-file-editor || { echo "Error creating symlink";}
    echo "You have made Neovim your code editor"
else
    echo "You chose not to make Neovim your default code editor."
fi

echo "Would you want to add beautifications to your Termux like a custom name and extra shortcuts? [Y|y|N|n]"

read -p "[y|Y|n|N]" user_input_t


echo "$user_input_t"

if [ "$user_input_t" = "y" ] || [ "$user_input_t" = "Y" ]; then
    cd || { echo "Error changing to home directory"; exit 1; }
    git clone https://github.com/remo7777/T-Header.git || { echo "Error cloning T-Header repository"; exit 1; }
    cd T-Header/ || { echo "Error changing to T-Header directory"; exit 1; }
    bash t-header.sh || { echo "Error running t-header.sh"; exit 1; }
    echo "Successfully beautified Termux and added some nice looks"
    echo "-----------------------------------"
    echo "To remove the banner and custom name, use this:"
    echo "cd ~/T-Header && bash t-header.sh --remove && exit"
else
    echo "You chose not to add beautifications to Termux."
fi

echo "Happy hacking!!! 😊😊⚡⚡⚡😎😎"
