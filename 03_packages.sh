#!/usr/bin/env zsh

typeset -a packages=(
    base-devel brotli btop
    deno dlang dog
    fastfetch fzf ffmpeg fnm-bin
    gdb gnupg go
    helix htmlq hyperfine
    inetutils intel-ucode iproute2
    jq
    man-db man-pages
    net-tools
    oh-my-posh-bin openssh
    ripgrep reflector rmw
    shfmt
    vivid
    wget wl-clipboard
    yazi
    zopfli zoxide zstd
)

typeset -a npm_packages=(
    @google/gemini-cli
)

logTitle "Installing system packages"
paru -S --needed ${packages[@]}
echo

logTitle "Installing system npm packages"
npm install -g ${npm_packages[@]}
if [[ -z "${GEMINI_API_KEY-}" ]]; then
    logWarn "GEMINI_API_KEY must be set as environment variable."
fi
echo

unset packages npm_packages
