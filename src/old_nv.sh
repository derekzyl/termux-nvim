#!/bin/bash
# Enhanced Termux setup script with developer environment configuration
# Preserves existing Neovim setup while enhancing overall experience

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Track successful and failed components
successful_components=()
failed_components=()

# Set up trap to handle interruptions gracefully
trap 'echo -e "\n${RED}Script interrupted. Cleaning up...${NC}"; exit 1' INT TERM

# Enhanced error handling function with recovery options
handle_error() {
    local exit_code=$1
    local error_message=$2
    local critical=${3:-true}  # Third parameter determines if error is critical
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}ERROR: $error_message (code: $exit_code)${NC}"
        
        if [ "$critical" = true ]; then
            echo -e "${RED}Critical error. Exiting...${NC}"
            exit 1
        else
            echo -e "${YELLOW}Non-critical error. Continuing execution...${NC}"
            track_component "$error_message" "failure"
            return 1
        fi
    fi
    return 0
}

# Function to track component installation status
track_component() {
    local component=$1
    local status=$2
    
    if [ "$status" = "success" ]; then
        successful_components+=("$component")
    else
        failed_components+=("$component")
    fi
}

# Show progress indicator for long-running commands
show_progress() {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0
    
    echo -n "$message "
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r$message ${spin:$i:1}"
        sleep 0.1
    done
    
    printf "\r$message Done!   \n"
}

# Check if a package is already installed
is_package_installed() {
    local package=$1
    if pkg list-installed | grep -q "^$package/"; then
        return 0 # Already installed
    else
        return 1 # Not installed
    fi
}

# Function to install a package with progress indicator
install_package() {
    local package=$1
    
    if is_package_installed "$package"; then
        echo -e "${GREEN}✅ $package already installed${NC}"
        track_component "$package" "success"
        return 0
    fi
    
    echo -e "${BLUE}Installing $package...${NC}"
    pkg install "$package" -y &> /dev/null &
    local pkg_pid=$!
    show_progress $pkg_pid "Installing $package..."
    wait $pkg_pid
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $package installed successfully${NC}"
        track_component "$package" "success"
        return 0
    else
        echo -e "${RED}❌ Failed to install $package${NC}"
        track_component "$package" "failure"
        return 1
    fi
}

# Install packages by category
install_packages() {
    local category=$1
    shift
    local packages=("$@")
    
    echo -e "\n${BLUE}Installing $category packages...${NC}"
    for package in "${packages[@]}"; do
        install_package "$package"
    done
    echo -e "${GREEN}Completed $category installations${NC}"
}

# Setup storage access
setup_storage() {
    echo -e "\n${CYAN}═══ STORAGE SETUP ═══${NC}"
    echo -e "${BLUE}Setting up storage access...${NC}"
    
    termux-setup-storage &> /dev/null &
    local storage_pid=$!
    show_progress $storage_pid "Configuring storage access..."
    wait $storage_pid
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Storage access configured successfully${NC}"
        track_component "Storage setup" "success"
    else
        echo -e "${YELLOW}⚠️  Storage access may not be properly configured${NC}"
        echo "You might need to manually approve storage permissions in Android settings"
        track_component "Storage setup" "failure"
    fi
}

# Change Termux repository
change_repo() {
    echo -e "\n${CYAN}═══ REPOSITORY CONFIGURATION ═══${NC}"
    echo -e "${BLUE}Updating Termux repositories...${NC}"
    
    termux-change-repo 
   
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Repository updated successfully${NC}"
        track_component "Repository update" "success"
    else
        echo -e "${YELLOW}⚠️  Repository update encountered issues${NC}"
        echo "Continuing with default repositories"
        track_component "Repository update" "failure"
    fi
}

# Update and Upgrade Termux
update_termux() {
    echo -e "\n${CYAN}═══ SYSTEM UPDATE ═══${NC}"
    echo -e "${BLUE}Updating package lists...${NC}"
    pkg update -y &> /dev/null &
    local update_pid=$!
    show_progress $update_pid "Updating package lists..."
    wait $update_pid
    handle_error $? "Failed to update packages" true
    
    echo -e "${BLUE}Upgrading installed packages...${NC}"
    pkg upgrade -y &> /dev/null &
    local upgrade_pid=$!
    show_progress $upgrade_pid "Upgrading packages..."
    wait $upgrade_pid
    handle_error $? "Failed to upgrade packages" true
    
    echo -e "${GREEN}✅ Termux updated and upgraded successfully${NC}"
    track_component "System update" "success"
}

# Clean up disk space
cleanup_disk_space() {
    echo -e "\n${CYAN}═══ DISK CLEANUP ═══${NC}"
    echo -e "${BLUE}Cleaning up disk space...${NC}"
    
    local before_size=$(du -sh $PREFIX/var/cache/apt/archives 2>/dev/null | cut -f1)
    echo "Package cache size before cleanup: $before_size"
    
    # Clean package cache
    apt clean &> /dev/null
    handle_error $? "Failed to clean apt cache" false
    
    # Remove package lists
    rm -rf $PREFIX/var/lib/apt/lists/* &> /dev/null
    handle_error $? "Failed to remove package lists" false
    
    local after_size=$(du -sh $PREFIX/var/cache/apt/archives 2>/dev/null | cut -f1)
    echo "Package cache size after cleanup: $after_size"
    
    # Remove unnecessary npm cache
    if command -v npm &> /dev/null; then
        npm cache clean --force &> /dev/null
        handle_error $? "Failed to clean npm cache" false
    fi
    
    echo -e "${GREEN}✅ Disk space cleanup completed${NC}"
    track_component "Disk cleanup" "success"
}

# Setup SSH keys
setup_ssh_keys() {
    echo -e "\n${CYAN}═══ SSH CONFIGURATION ═══${NC}"
    echo -e "${BLUE}Setting up SSH keys...${NC}"
    
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        echo "Generating new SSH key pair..."
        
        read -p "Enter your email for the SSH key (or press Enter to skip): " ssh_email
        
        if [ -n "$ssh_email" ]; then
            mkdir -p ~/.ssh
            chmod 700 ~/.ssh
            
            ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
            local result=$?
            handle_error $result "Failed to generate SSH key" false
            
            if [ $result -eq 0 ]; then
                # Start ssh-agent
                eval "$(ssh-agent -s)"
                
                # Add key to agent
                ssh-add ~/.ssh/id_ed25519
                handle_error $? "Failed to add SSH key to agent" false
                
                echo -e "${GREEN}SSH key generated successfully!${NC}"
                echo "Your public key is:"
                cat ~/.ssh/id_ed25519.pub
                
                echo "Would you like to copy this key to the clipboard? [y/N]"
                read -p "> " copy_key
                
                if [[ "$copy_key" =~ ^[Yy]$ ]]; then
                    # Check if termux-api is installed for clipboard access
                    if ! command -v termux-clipboard-set &> /dev/null; then
                        echo "Installing termux-api for clipboard access..."
                        pkg install termux-api -y
                    fi
                    
                    cat ~/.ssh/id_ed25519.pub | termux-clipboard-set
                    echo -e "${GREEN}Public key copied to clipboard!${NC}"
                fi
                
                echo "Remember to add this key to your GitHub/GitLab account"
                track_component "SSH key setup" "success"
            fi
        else
            echo "SSH key setup skipped"
        fi
    else
        echo "SSH key already exists"
        echo "Would you like to view your public key? [y/N]"
        read -p "> " view_key
        
        if [[ "$view_key" =~ ^[Yy]$ ]]; then
            cat ~/.ssh/id_ed25519.pub
        fi
        track_component "SSH key setup" "success"
    fi
}

# Setup Git configuration
setup_git_config() {
    echo -e "\n${CYAN}═══ GIT CONFIGURATION ═══${NC}"
    echo -e "${BLUE}Setting up Git configuration...${NC}"
    
    if [ -z "$(git config --global user.name)" ]; then
        read -p "Enter your Git username (or press Enter to skip): " git_username
        if [ -n "$git_username" ]; then
            git config --global user.name "$git_username"
        fi
    else
        echo "Git username already configured: $(git config --global user.name)"
    fi
    
    if [ -z "$(git config --global user.email)" ]; then
        read -p "Enter your Git email (or press Enter to skip): " git_email
        if [ -n "$git_email" ]; then
            git config --global user.email "$git_email"
        fi
    else
        echo "Git email already configured: $(git config --global user.email)"
    fi
    
    # Configure helpful Git aliases
    echo "Setting up helpful Git aliases..."
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    # Set default editor for Git
    git config --global core.editor "nvim"
    
    # Set default branch name
    git config --global init.defaultBranch main
    
    echo -e "${GREEN}✅ Git configuration completed!${NC}"
    track_component "Git configuration" "success"
}

# Setup Python development environment
setup_python_env() {
    echo -e "\n${CYAN}═══ PYTHON ENVIRONMENT SETUP ═══${NC}"
    echo -e "${BLUE}Setting up Python development environment...${NC}"
    
    # Ensure pip is up to date
    pip install --upgrade pip &> /dev/null
    handle_error $? "Failed to upgrade pip" false

    # Ask about creating a default virtual environment
    echo "Would you like to create a default Python virtual environment? [y/N]"
    read -p "> " create_venv
    
    if [[ "$create_venv" =~ ^[Yy]$ ]]; then
        # Create venv directory if it doesn't exist
        if [ ! -d ~/venvs ]; then
            mkdir -p ~/venvs
        fi
        
        # Create default venv
        echo "Creating default Python virtual environment..."
        python -m venv ~/venvs/default &> /dev/null
        handle_error $? "Failed to create virtual environment" false
        
        # Add venv activation aliases to .bashrc
        if ! grep -q "alias activate-default=" ~/.bashrc; then
            echo -e "\n# Python virtual environment aliases" >> ~/.bashrc
            echo "alias activate-default='source ~/venvs/default/bin/activate'" >> ~/.bashrc
            echo "alias create-venv='python -m venv'" >> ~/.bashrc
        fi
        
        echo -e "${GREEN}✅ Default Python virtual environment created${NC}"
        echo "You can activate it with: source ~/venvs/default/bin/activate"
        echo "Or use the alias 'activate-default' after restarting terminal"
        
        track_component "Python virtual environment" "success"
    else
        echo "Python virtual environment setup skipped"
    fi
    
    # Install common Python development tools
    echo "Would you like to install common Python development tools? [y/N]"
    read -p "> " install_py_tools
    
    if [[ "$install_py_tools" =~ ^[Yy]$ ]]; then
        python_tools=("pytest" "black" "isort" "flake8" "mypy" "ipython")
        
        for tool in "${python_tools[@]}"; do
            echo "Installing $tool..."
            pip install $tool &> /dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ $tool installed${NC}"
            else
                echo -e "${YELLOW}⚠️  Failed to install $tool${NC}"
            fi
        done
        
        track_component "Python development tools" "success"
    else
        echo "Python development tools installation skipped"
    fi
}

# Setup shell configuration
setup_shell_config() {
    echo -e "\n${CYAN}═══ SHELL CONFIGURATION ═══${NC}"
    echo -e "${BLUE}Setting up shell configuration...${NC}"
    
    # Create .bashrc if it doesn't exist
    if [ ! -f ~/.bashrc ]; then
        touch ~/.bashrc
    fi

    echo "Which shell would you prefer to use?"
    echo "1) Bash (default)"
    echo "2) Zsh (with Oh-My-Zsh)"
    read -p "> " shell_choice
    
    case $shell_choice in
        2)
            # Install Zsh
            if ! is_package_installed "zsh"; then
                install_package "zsh"
            fi
            
            # Install Oh-My-Zsh
            if [ ! -d ~/.oh-my-zsh ]; then
                echo "Installing Oh-My-Zsh..."
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
                handle_error $? "Failed to install Oh-My-Zsh" false
            fi
            
            # Configure Zsh
            if [ -f ~/.zshrc ]; then
                # Backup existing .zshrc
                cp ~/.zshrc ~/.zshrc.bak
                
                # Add custom configuration
                cat >> ~/.zshrc << 'EOF'

# Custom Termux configuration
export EDITOR=nvim
ZSH_THEME="robbyrussell"

# Enable plugins
plugins=(git python pip npm node)

# Custom aliases
alias py='python'
alias cls='clear'
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias nv='nvim'
alias reload='source ~/.zshrc'

# Development shortcuts
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "Cannot extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Set PATH
export PATH=$PATH:~/.local/bin
EOF
                
                echo -e "${GREEN}✅ Zsh configured with Oh-My-Zsh${NC}"
                echo "To change your default shell to Zsh, run: chsh -s zsh"
                
                track_component "Zsh configuration" "success"
            fi
            ;;
        *)
            # Configure enhanced Bash
            echo "Which Bash customization level do you prefer?"
            echo "1) Minimal - Just a few essential aliases"
            echo "2) Standard - Common development aliases and functions"
            echo "3) Full - Comprehensive customization with enhanced prompt"
            read -p "> " bash_config_choice
            
            case $bash_config_choice in
                1)
                    # Minimal configuration
                    cat >> ~/.bashrc << 'EOF'

# Minimal shell configuration
alias ll='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias py='python'
alias nv='nvim'

# Set editor
export EDITOR=nvim
EOF
                    ;;
                2)
                    # Standard configuration
                    cat >> ~/.bashrc << 'EOF'

# Enhanced shell configuration
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias py='python'
alias nv='nvim'
alias gst='git status'
alias gl='git log --oneline'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias reload='source ~/.bashrc'

# Development shortcuts
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "Cannot extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Set environment variables
export EDITOR=nvim
export PATH=$PATH:~/.local/bin
EOF
                    ;;
                3)
                    # Full configuration with enhanced prompt
                    # Install starship prompt if selected
                    echo "Would you like to install Starship prompt? [y/N]"
                    read -p "> " install_starship
                    
                    if [[ "$install_starship" =~ ^[Yy]$ ]]; then
                        # Install starship
                        curl -fsSL https://starship.rs/install.sh | sh -s -- -y &> /dev/null
                        handle_error $? "Failed to install Starship prompt" false
                        
                        # Add to bashrc
                        echo 'eval "$(starship init bash)"' >> ~/.bashrc
                        
                        echo -e "${GREEN}✅ Starship prompt installed${NC}"
                        track_component "Starship prompt" "success"
                    fi
                    
                    # Add full bash configuration
                    cat >> ~/.bashrc << 'EOF'

# Comprehensive shell configuration
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'
alias py='python'
alias py3='python3'
alias nv='nvim'
alias vi='nvim'
alias vim='nvim'

# Git aliases
alias gst='git status'
alias gl='git log --oneline'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias reload='source ~/.bashrc'

# Package management
alias pki='pkg install'
alias pks='pkg search'
alias pku='pkg update && pkg upgrade'
alias pkc='pkg clean'

# Development shortcuts
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "Cannot extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Git branch in prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Enhanced prompt if starship is not installed
if ! command -v starship &> /dev/null; then
  export PS1="\[\033[38;5;39m\]\u\[\033[38;5;15m\]@\[\033[38;5;51m\]\h \[\033[38;5;201m\]\w \[\033[38;5;11m\]\$(parse_git_branch)\[\033[38;5;15m\]\$ "
fi

# Set environment variables
export EDITOR=nvim
export PATH=$PATH:~/.local/bin:~/bin

# Add history settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Enable programmable completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
EOF
                    ;;
            esac
            echo -e "${GREEN}✅ Bash configuration completed${NC}"
            track_component "Bash configuration" "success"
            ;;
    esac
}

# Install terminal productivity tools
install_terminal_tools() {
    echo -e "\n${CYAN}═══ TERMINAL PRODUCTIVITY TOOLS ═══${NC}"
    echo -e "${BLUE}Setting up terminal productivity tools...${NC}"
    
    echo "Which productivity tools would you like to install?"
    echo "1) File managers (nnn, ranger)"
    echo "2) Text processing tools (fzf, ripgrep, bat)"
    echo "3) Network tools (nmap, netcat)"
    echo "4) All of the above"
    echo "5) None"
    read -p "> " tools_choice
    
    case $tools_choice in
        1|4)
            # File managers
            file_managers=("nnn" "ranger")
            install_packages "File manager" "${file_managers[@]}"
            ;;
        2|4)
            # Text processing tools
            text_tools=("fzf" "ripgrep" "bat" "jq")
            install_packages "Text processing" "${text_tools[@]}"
            
            # Add fzf config to shell if installed
            if is_package_installed "fzf"; then
                if ! grep -q "fzf" ~/.bashrc; then
                    echo -e "\n# FZF configuration" >> ~/.bashrc
                    echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' >> ~/.bashrc
                    echo 'export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"' >> ~/.bashrc
                fi
                
                # Add bat config if installed
                if is_package_installed "bat"; then
                    echo 'alias cat="bat --paging=never"' >> ~/.bashrc
                fi
            fi
            ;;
        3|4)
            # Network tools
            network_tools=("nmap" "netcat-openbsd" "openssh")
            install_packages "Network" "${network_tools[@]}"
            ;;
        5)
            echo "Skipping terminal productivity tools installation"
            ;;
    esac
}

# Setup Neovim LSP plugins
setup_neovim_extras() {
    echo -e "\n${CYAN}═══ NEOVIM SETUP ═══${NC}"
    echo -e "${BLUE}Setting up  Neovim language support...${NC}"
    
    # Install language servers via npm
    echo "Installing language servers..."
    npm_packages=("pyright" "typescript" "typescript-language-server" "bash-language-server")
    
    for package in "${npm_packages[@]}"; do
        echo "Installing $package globally..."
        npm install -g $package &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ $package installed${NC}"
        else
            echo -e "${YELLOW}⚠️  Failed to install $package${NC}"
        fi
    done


   if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim || { echo "Error cloning Neovim"; exit 1; }
else
    echo "Packer.nvim already installed, skipping clone."
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