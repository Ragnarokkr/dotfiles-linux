#!/usr/bin/env zsh

# Checks the system for missing programs required for installation and
# configuration. Optional extra tools should be defined in apposite
# 03_packages.sh files.

typeset -a programs=(base-devel git devtools doas gum)
typeset -a missing=()

# ---------------------------------------------------------------------------- #
#                               Utility functions                              #
# ---------------------------------------------------------------------------- #

is_installed() {
    pacman -Qi "$1" &>/dev/null
}

ask_yes_no() {
    local prompt=${1:-"Continue"}
    if read -q "?$prompt [y/n]? "; then
        echo
        return 0
    else
        echo
        return 1
    fi
}

install_paru() {
    logTitle "Installing and configuring paru"
    logAction1 "Downloading and compiling" "paru"
    git clone https://aur.archlinux.org/paru.git "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
    (
        cd "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
        makepkg -si --noconfirm
    )
    rm -rf "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
    echo
}

config_paru() {
    if ! is_installed paru; then
        install_paru
    fi

    logAction1 "Configuring" "paru"
    local chroot_dir="/var/lib/archbuild/extra-x86_64/root"

    if [[ -e "${XDG_CONFIG_HOME:=$HOME/.config}/paru/paru.conf" ]]; then
        rm -f "${XDG_CONFIG_HOME:=$HOME/.config}/paru/paru.conf"
    fi
    ln -s "$work_dir/paru/paru.conf" "${XDG_CONFIG_HOME:=$HOME/.config}/paru/paru.conf"

    if [ ! -e "$chroot_dir" ]; then
        logAction1 "Configuring containerized environment for" "paru"
        doas ln -sf "$work_dir/makepkg/makepkg.conf" /etc/makepkg.conf
        doas mkdir -p "$(dirname $chroot_dir)"
        doas mkarchroot $chroot_dir base base-devel
        doas arch-nspawn $chroot_dir pacman -Syu
        doas mkdir -p /etc/makepkg.conf.d
        doas ln -sf "$work_dir/makepkg/arch-nspawn.conf" /etc/makepkg.conf.d/arch-nspawn.conf
    fi
    echo
}

check_missing_programs() {
    logTitle "Checking for missing programs"
    for program in "${programs[@]}"; do
        logAction1 -n Checking "$program ... "
        if is_installed ${program}; then
            echo "${COLORS[fg_green]}installed${COLORS[reset]}"
        else
            echo "${COLORS[fg_red]}missing${COLORS[reset]}"
            missing+=($program)
        fi
    done
    echo
}

install_missing_programs() {
    if [[ ${#missing[@]} -gt 0 ]]; then
        if ask_yes_no "Do you want to install the missing programs?"; then
            logAction1 "Updating" "system packages"
            paru -Syu --noconfirm --needed

            logTitle "Installing missing programs"
            logAction1 "Installing" "${missing[@]}"
            paru -S --needed ${missing[@]}
        else
            return 1
        fi
        echo
    fi
}

check_missing_programs
config_paru
if [[ $(install_missing_programs) -gt 0 ]]; then
    return 1
fi
