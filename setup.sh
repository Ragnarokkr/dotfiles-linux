#!/usr/bin/env zsh

set -euo pipefail

work_dir=$(pwd)

source "$work_dir/01_common.sh"
source "$work_dir/02_env-check.sh"
source "$work_dir/03_packages.sh"
source "$work_dir/04_dotfiles-setup.sh"

unset work_dir

gum style "CONFIGURATION DONE! Restart your shell and enjoy the new environment." \
    --border "rounded" --border-foreground "2" --padding "1 5"
