# Termux & Neovim Development Environment Setup

A comprehensive guide to setting up a powerful development environment on Android using Termux and Neovim.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Installation](#detailed-installation)
  - [Installing F-Droid and Termux](#installing-f-droid-and-termux)
  - [Running the Setup Script](#running-the-setup-script)
  - [Configuring Neovim](#configuring-neovim)
- [Usage Guide](#usage-guide)
  - [Essential Terminal Commands](#essential-terminal-commands)
  - [Neovim Commands](#neovim-commands)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

**Termux** is a powerful terminal emulator and Linux environment for Android that provides a full-featured command-line interface on your mobile device. **Neovim** is a modern, extensible text editor based on Vim, offering enhanced performance and plugin support.

This guide helps you create a complete mobile development environment with:
- ✅ Full Linux terminal on Android
- ✅ Modern text editor with syntax highlighting
- ✅ Package management and development tools
- ✅ Git integration and SSH support
- ✅ Language servers for code completion

## 📱 Prerequisites

- Android device (Android 7.0+ recommended)
- At least 2GB free storage space
- Stable internet connection for downloads

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

1. **Install F-Droid**: [Download F-Droid APK](https://f-droid.org/F-Droid.apk)
2. **Install Termux packages** from F-Droid:
   - Termux
   - Termux:API
   - Termux:Styling (optional)
3. **Download and run setup script**: [Get Setup Script](https://drive.google.com/file/d/1mGu6xzJUPi4VaKBi-8IseojU_AvW8HdT/view?usp=drive_link)
4. **Execute setup** in Termux: `bash nv.sh`

### Option 2: Manual Setup

Follow the [detailed installation guide](#detailed-installation) below for step-by-step instructions.

## 🔧 Detailed Installation

### Installing F-Droid and Termux

#### Step 1: Install F-Droid
F-Droid is an open-source app store that provides privacy-focused, free software for Android.

1. Download F-Droid APK from [f-droid.org](https://f-droid.org/F-Droid.apk)
2. Enable "Unknown Sources" in Android settings if prompted
3. Install the downloaded APK

#### Step 2: Install Termux Components
From F-Droid, install the following apps:

| App | Purpose | Required |
|-----|---------|----------|
| **Termux** | Main terminal emulator | ✅ Yes |
| **Termux:API** | Android API access | ✅ Yes |
| **Termux:Styling** | Terminal themes | ⚪ Optional |
| **Unexpected Keyboard** | Coding-friendly keyboard | ⚪ Recommended |

### Running the Setup Script

#### Step 1: Initial Termux Setup
```bash
# Open Termux and allow it to complete first-time setup
# Then enable storage access
termux-setup-storage
```

#### Step 2: Download and Execute Script
```bash
# Navigate to downloads folder
cd ~/storage/downloads

# Make script executable (if needed)
chmod +x nv.sh

# Convert line endings if you encounter errors
dos2unix nv.sh

# Run the setup script
bash nv.sh
```

The script will:
- Update Termux packages
- Install development tools (Python, Node.js, Git, etc.)
- Configure shell environment
- Install and configure Neovim
- Set up optional productivity tools

### Configuring Neovim

#### Step 1: Initial Neovim Setup
```bash
# Launch Neovim
nvim
```

#### Step 2: Install Plugins
In Neovim, run these commands (note the colon prefix):
```vim
:PackerInstall
:PackerSync
:Mason
```

#### Step 3: Configure Language Servers
In Mason (`:Mason`), install language servers for your preferred languages:
- `markdown-parser` for Markdown support
- `lua-language-server` for Lua
- `pyright` for Python
- Add others as needed

#### Step 4: Explore Configuration
```bash
# Navigate to Neovim config
cd ~/.config/nvim
nvim .
```

Use `n` in normal mode to toggle the file tree (NerdTree) and explore the configuration files.

## 📖 Usage Guide

### Essential Terminal Commands

#### Navigation
```bash
cd <directory>    # Change directory
ls               # List files and folders  
pwd              # Show current directory path
cd ~             # Go to home directory
cd ..            # Go up one directory
```

#### File Operations
```bash
mkdir <name>     # Create directory
rm <file>        # Delete file
rm -rf <dir>     # Delete directory and contents
cp <src> <dest>  # Copy file/directory
mv <src> <dest>  # Move/rename file/directory
```

#### File Content
```bash
cat <file>       # Display file contents
less <file>      # View file with pagination
grep "<text>" <file>  # Search for text in file
```

#### System
```bash
chmod +x <file>  # Make file executable
sudo <command>   # Run command as administrator
ping <host>      # Test network connectivity
```

### Neovim Commands

#### Modes
- **Normal Mode**: Navigate and run commands (press `Esc` to enter)
- **Insert Mode**: Edit text (press `i` to enter)
- **Visual Mode**: Select text (press `v` to enter)
- **Command Mode**: Run Neovim commands (press `:` to enter)

#### Essential Commands
```vim
# File Operations
:w               # Save file
:q               # Quit
:wq              # Save and quit
:q!              # Quit without saving

# Navigation (Normal Mode)
h j k l          # Move left/down/up/right
gg               # Go to file beginning
G                # Go to file end
Ctrl+u/d         # Scroll half page up/down

# Editing (Normal Mode)
i                # Insert at cursor
a                # Insert after cursor
o                # New line below and insert
dd               # Delete line
yy               # Copy line
p                # Paste
```

#### Advanced Features
```vim
# Search and Replace
/pattern         # Search forward
?pattern         # Search backward
n/N              # Next/previous match
:%s/old/new/g    # Replace all occurrences

# Plugin Commands
n                # Toggle file tree (NerdTree)
:Mason           # Open Mason package manager
:PackerSync      # Sync plugins
```

## 🎨 Customization

### Terminal Appearance
- Use **Termux:Styling** to change colors and fonts
- Modify `~/.termux/termux.properties` for advanced settings

### Neovim Plugins
Edit `~/.config/nvim/lua/plugins.lua` to:
- Add new plugins
- Modify existing plugin configurations
- Customize key bindings

### Shell Configuration
Customize your shell by editing:
- `~/.bashrc` or `~/.zshrc` for shell settings
- `~/.tmux.conf` for tmux configuration

## 🔍 Troubleshooting

### Common Issues

#### Script Execution Errors
```bash
# If script fails to run:
dos2unix nv.sh
chmod +x nv.sh
bash nv.sh
```

#### Storage Access Issues
```bash
# Re-run storage setup:
termux-setup-storage
```

#### Plugin Installation Failures
```vim
# In Neovim, try:
:PackerClean
:PackerInstall
:PackerSync
```

#### Package Installation Issues
```bash
# Update package lists:
pkg update && pkg upgrade
```

### Getting Help

- **Termux Wiki**: [wiki.termux.com](https://wiki.termux.com)
- **Neovim Documentation**: `:help` in Neovim
- **Community**: r/termux on Reddit

## 🤝 Contributing

Found an issue or want to improve this guide? Contributions are welcome!

1. Fork the repository
2. Make your changes
3. Submit a pull request

## 📄 License

This guide is provided as-is for educational purposes. Individual software components have their own licenses.

---

**Happy coding on mobile! 📱💻**
