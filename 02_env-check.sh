#!/usr/bin/env zsh

# Checks the system for missing programs required for installation and
# configuration. Optional extra tools should be defined in apposite
# 03_packages.sh files.

typeset -a programs=(paru doas gum) # paru is always the first check
typeset -a missing=()

# ---------------------------------------------------------------------------- #
#                               Utility functions                              #
# ---------------------------------------------------------------------------- #

is_installed() {
    hash "$1" 2>/dev/null
}

ask_yes_no() {
    local prompt=${1:-"Continue"}
    # -q does a non-echoing, single-char read; 0 if [yY], 1 otherwise
    if read -q "?$prompt [y/n]? "; then
        echo     # just to move to a new line after the prompt
        return 0 # yes
    else
        echo
        return 1 # no
    fi
}

install_paru() {
    logTitle "Installing paru"
    logAction1 "Downloading and compiling" "paru"
    git clone https://aur.archlinux.org/paru.git "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
    (
        cd "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
        makepkg -si --noconfirm
    )
    rm -rf "${XDG_LOCAL_SHARE:=$HOME/.local/share}/paru"
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
    if [ ${#missing[@]} -gt 0 ]; then
        if ask_yes_no "Do you want to install the missing programs?"; then
            if ${missing[0]} == "paru"; then
                install_paru
                missing=${missing[2, -1]}
            fi

            logAction1 "Updating system packages"
            paru --noconfirm

            logTitle "Installing missing programs"
            logAction1 "Installing" "${missing[@]}"
            paru -S ${missing[@]}
        else
            exit 1
        fi
        echo
    fi
}

check_missing_programs
install_missing_programs
