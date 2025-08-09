#!/usr/bin/env sh

typeset -gA COLORS
COLORS=()

generate_ansi_colors () {
    local -a color_names=(black red green yellow blue magenta cyan white)
    local -i FG_BASE=30 BG_BASE=40 FG_BRIGHT_BASE=90 BG_BRIGHT_BASE=100
    local -i COLOR_COUNT=${#color_names[@]}

    for ((i = 0; i < COLOR_COUNT; i++)); do
        local name="${color_names[$((i+1))]}"
        local -i fg_code=$((FG_BASE + i))
        local -i bg_code=$((BG_BASE + i))
        local -i fg_bright_code=$((FG_BRIGHT_BASE + i))
        local -i bg_bright_code=$((BG_BRIGHT_BASE + i))

        printf -v "COLORS[fg_$name]" "\e[%dm" "$fg_code"
        printf -v "COLORS[bg_$name]" "\e[%dm" "$bg_code"
        printf -v "COLORS[fg_bright_$name]" "\e[%dm" "$fg_bright_code"
        printf -v "COLORS[bg_bright_$name]" "\e[%dm" "$bg_bright_code"
    done

    printf -v "COLORS[reset]" "\e[0m"
    printf -v "COLORS[bold]" "\e[1m"
    printf -v "COLORS[dim]" "\e[2m"
    printf -v "COLORS[underline]" "\e[4m"
    printf -v "COLORS[blink]" "\e[5m"
    printf -v "COLORS[reverse]" "\e[7m"
    printf -v "COLORS[hidden]" "\e[8m"
}

# ---------------------------------------------------------------------------- #
#                               Utility functions                              #
# ---------------------------------------------------------------------------- #

logTitle () {
    local date=$(date --rfc-3339=seconds)
    local message=" $1 "
    printf "%s [${COLORS[fg_bright_blue]}INFO${COLORS[reset]}] ${COLORS[fg_black]}${COLORS[bg_white]}%s${COLORS[reset]}\n" "$date" "$message"
}

logAction1 () {
    local suffix="\n"
    if [ "$1" = "-n" ]; then
        suffix=""
        shift
    fi
    local date=$(date --rfc-3339=seconds)
    local action="$1"
    local src="$2"
    printf "%s [${COLORS[fg_bright_blue]}INFO${COLORS[reset]}] %s ${COLORS[fg_yellow]}%s${COLORS[reset]}${suffix}" "$date" "$action" "$src"
}

logAction2 () {
    local date=$(date --rfc-3339=seconds)
    local action="$1"
    local src="$2"
    local dest="$3"
    printf "%s [${COLORS[fg_bright_blue]}INFO${COLORS[reset]}] %s ${COLORS[fg_yellow]}%s${COLORS[reset]} -> ${COLORS[fg_green]}%s${COLORS[reset]}\n" "$date" "$action" "$src" "$dest"
}

logWarn () {
    local date=$(date --rfc-3339=seconds)
    local message="$1"
    printf "%s [${COLORS[fg_yellow]}WARN${COLORS[reset]}] %s\n" "$date" "$message"
}

logError () {
    local date=$(date --rfc-3339=seconds)
    local message="$1"
    printf "%s [${COLORS[fg_red]}ERROR${COLORS[reset]}] %s\n" "$date" "$message" >&2
}


generate_ansi_colors