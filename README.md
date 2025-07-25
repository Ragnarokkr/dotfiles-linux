# Dotfiles (Linux)

Welcome to my personal dotfiles repository, tailored for Arch Linux (and WSL). While this configuration reflects my own preferences and workflows, you’re welcome to explore, adapt, or fork it if you find any parts useful.

## Features

This setup script installs and configures a wide range of command-line tools and utilities:

- **Shell**  
  Zsh with Oh My Posh prompt and Nord-inspired dircolors  
- **System**  
  Pacman, Paru (AUR helper), btop, fastfetch  
- **Development**  
  Git, GDB, Helix (text editor), GitHub CLI (`gh`), D, Go, Node.js, Deno  
- **Networking**  
  cURL, Wget, OpenSSH  
- **Security**  
  GnuPG  
- **Utilities**  
  rmw (safe-delete), gum (UI components in shell), fastfetch, btop, and more  
- **WSL**  
  Fixes for Wayland display issues on Windows Subsystem for Linux  

For a complete list of packages, see the [packages](https://github.com/Ragnarokkr/dotfiles-linux/blob/master/03_packages.sh) file.

## Prerequisites

- An **Arch-based** Linux distribution.  
- `git` and `curl` installed:

  ```shell
  sudo pacman -S git curl
  ```

## Installation

Follow these steps carefully to ensure a smooth setup.

### 1. Configure Environment Variables

Before running the installer, export the following variables in your shell session so Git and Gemini CLI can be properly configured:

```shell
export GIT_NAME="Your Name"
export GIT_EMAIL="your.email@example.com"
export GIT_SIGNING_KEY="YourGpgKeyId"
export GEMINI_API_KEY="YourGeminiApiKey"
```

> To persist these settings across sessions, add those exports to a file that’s sourced by your shell at startup (for example, `~/.zprofile`, or `~/.zshenv`). For example, you could create a file named `~/.private.env`:
>
> ```shell
> cat << 'EOF' >> ~/.private.env
> export GIT_NAME="Your Name"
> export GIT_EMAIL="your.email@example.com"
> export GIT_SIGNING_KEY="YourGpgKeyId"
> export GEMINI_API_KEY="YourGeminiApiKey"
> EOF
> ```
>
> Then source it from your main shell startup file:
>
> ```shell
> echo 'source ~/.private.env' >> ~/.zprofile
> ```
>
> ⚠️ **Security warning:** Do not commit or otherwise version-control `~/.private.env` (or whatever file you choose). It contains sensitive credentials that should remain private.

### 2. Run the Installer

Execute the following command to download and run the installer script:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Ragnarokkr/dotfiles-linux/refs/heads/master/install.sh)"
```

The script will guide you through the remaining setup steps. Once complete, restart your terminal to load the new configuration. Enjoy your new environment!
