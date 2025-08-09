#!/usr/bin/env zsh

# ---------------------------------------------------------------------------- #
#                            CONFIGURATION UTILITIES                           #
# ---------------------------------------------------------------------------- #

config_pacman(){
    local src="$work_dir/pacman"
    local dst="/etc/pacman.conf"

    logTitle "Configuring PACMAN"
    logAction2 Copying "$src/pacman.conf" "$dst"
    sudo cp "$src/pacman.conf" "$dst"
    echo
}

config_zsh(){    
    local src="$work_dir/zsh"
    local dst="$HOME"
    local file

    logTitle "Configuring ZSH"
    
    if [[ ! -d /var/cache/zsh ]]; then
        logAction1 Creating /var/cache/zsh
        doas mkdir -p /var/cache/zsh
    fi

    if [[ ! -d /etc/pacman.d/hooks ]]; then
        logAction1 Creating /etc/pacman.d/hooks 
        doas mkdir -p /etc/pacman.d/hooks 

        logAction2 Copying "$src/zsh.hook" "/etc/pacman.d/hooks/" 
        doas cp "$src/zsh.hook" /etc/pacman.d/hooks/
    fi

    for file in ${src}/.*; do
        local base_file=$(basename "$file")
        logAction2 Symlinking "$base_file" "$dst/$base_file"
        ln -sf "$file" "$dst/$base_file"
    done

    dst="${XDG_CONFIG_HOME:=$HOME/.config}/zsh"
    logAction2 Symlinking "$src/functions" "$dst/functions"
    if [[ -e "$dst/functions" ]]; then
        rm -f "$dst/functions"
    fi
    ln -sf "$src/functions" "$dst/functions"
    echo
}

config_wsl () {
    if grep -qEi "(Microsoft|WSL2)" /proc/version &>/dev/null; then
        # Fix WSL issue as described in https://github.com/microsoft/wslg/issues/1032
        
        local src="$work_dir/wsl"
        local dst="${XDG_CONFIG_HOME:=$HOME/.config}/systemd/user"
        if [[ ! -e "$dst/wsl-wayland-symlink.service" ]]; then
            logTitle "Configuring WSL"
            mkdir -p "$dst"
            logAction2 Symlinking "$src/wsl-wayland-symlink.service" "$dst/wsl-wayland-symlink.service"
            ln -sf "$src/wsl-wayland-symlink.service" "$dst/wsl-wayland-symlink.service"
            systemctl --user daemon-reload \
                && systemctl --user enable wsl-wayland-symlink.service \
                && systemctl --user start wsl-wayland-symlink.service
            echo
        fi
    fi
}

config_packages(){
    local -A packages
    packages[curl]='curl/.curlrc .curlrc no'
    packages[wget]='wget/.wgetrc .wgetrc no'
    packages[gnupg]='gnupg/gpg.conf .gnupg/gpg.conf no'
    packages[ohmyposh]='oh-my-posh/atomic-custom.omp.json .config/oh-my-posh/atomic-custom.omp.json no'
    packages[fastfetch]='fastfetch .config/fastfetch yes'
    packages[helix]='helix .config/helix yes'
    packages[gdb]='gdb .config/gdb yes'
    packages[btop]='btop .config/btop yes'
    packages[gh]="gh/config.yml .config/gh/config.yml no"
    packages[ssh]="ssh/config .ssh/config no"
    packages[rmw]='rmw/rmwrc .config/rmwrc no'

    for pkg in "${(@k)packages}"; do
        local tuple=(${(z)packages[$pkg]})
        local src=${tuple[1]}
        local dst=${tuple[2]}
        local remove_flag=${tuple[3]}

        logTitle "Configuring ${(U)pkg}"
        if [[ -e "$HOME/$dst" ]]; then
            if [[ $remove_flag == yes ]]; then
                logAction1 Removing "$HOME/$dst"
                rm -rf -- "$HOME/$dst"
            fi
        fi

        # Ensure the parent directory of the destination exists
        mkdir -p "$HOME/${dst:h}"

        # Create or overwrite the symlink
        logAction2 Symlinking "$work_dir/$src" "$HOME/$dst"
        ln -sf "$work_dir/$src" "$HOME/$dst"
        echo
    done
}

config_dircolors(){
    local src="https://github.com/nordtheme/dircolors/raw/develop/src/dir_colors"
    local dst="$HOME/.dircolors"

    logTitle "Configuring .dircolors"
    logAction2 Downloading $src $dst
    curl -L $src -o $dst
    echo
}

config_git(){
    local src="$work_dir/git"
    local dst="${XDG_CONFIG_HOME:-$HOME/.config}/git"

    logTitle "Configuring GIT"

    if [[ -z "${GIT_NAME-}" || -z "${GIT_EMAIL-}" || -z "${GIT_SIGNING_KEY-}" ]]; then
        logError "GIT_NAME, GIT_EMAIL, and GIT_SIGNING_KEY must be set as environment variables."
        exit 1
    fi

    logAction2 Copying "$src/config" "$dst/config"
    mkdir -p "$dst"
    cp "$src/config" "$dst/config"
    ln -sf "$src/.gitmessage.txt" "$HOME/.gitmessage.txt"

    logAction1 Configuring "git config"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global user.signingKey "$GIT_SIGNING_KEY"
    git config --global commit.template "$HOME/.gitmessage.txt"
    echo
}

config_yazi(){
    local src="$work_dir/yazi"
    local dst="${XDG_CONFIG_HOME:-$HOME/.config}/yazi"
    local file

    logTitle "Configuring YAZI"

    if ! ya pkg list | grep -qEi ayu-dark &>/dev/null; then
        logAction1 Installing "Ayu-Dark theme"
        ya pkg add kmlupreti/ayu-dark
    fi

    for file in $src/*.toml; do
        local base_file=$(basename "$file")
        logAction2 Symlinking "$file" "$dst/$base_file"
        ln -sf "$file" "$dst/$base_file"
    done
    echo
}

# ---------------------------------------------------------------------------- #
#                                     MAIN                                     #
# ---------------------------------------------------------------------------- #

config_pacman
config_zsh

if [[ "${DOTFILES_ZSH_INSTALLED-}" != "1" ]]; then
    gum style "Restart your shell to apply the updated zsh configuration, then rerun this script." \
        --border "rounded" --border-foreground "3" --padding "1 5"
    echo
    exit 0
fi

config_wsl
config_packages
config_dircolors
config_git
config_yazi
