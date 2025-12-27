#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║             EYEFEST WALLPAPER MASTER                 ║
# ║   KDE Plasma native • Background auto-change • 2025  ║
# ╚══════════════════════════════════════════════════════╝

WDIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WDIR"

# ───── Detect KDE Plasma ─────
USE_PLASMA=false
if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* || "$DESKTOP_SESSION" == *"plasma"* ]] && command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    USE_PLASMA=true
fi

# ───── Ensure feh is available (fallback) ─────
if ! $USE_PLASMA && ! command -v feh &>/dev/null; then
    echo -e "\033[1;33mInstalling feh (required for non-Plasma desktops)...\033[0m"
    if   command -v apt    >/dev/null; then sudo apt update && sudo apt install -y feh
    elif command -v dnf    >/dev/null; then sudo dnf install -y feh
    elif command -v pacman >/dev/null; then sudo pacman -Sy --noconfirm feh
    elif command -v zypper >/dev/null; then sudo zypper install -y feh
    else echo "Please install feh manually"; exit 1; fi
fi

# ───── Universal wallpaper setter ─────
set_wallpaper() {
    local img="$1"
    if $USE_PLASMA; then
        plasma-apply-wallpaperimage "$img" >/dev/null 2>&1
        echo -e "\033[1;32mPlasma → $(basename "$img")\033[0m"
    else
        feh --bg-fill "$img" >/dev/null 2>&1
        echo -e "\033[1;32mfeh → $(basename "$img")\033[0m"
    fi
}

# ───── Load images ─────
mapfile -d '' images < <(find "$WDIR" -type f -print0 2>/dev/null | grep -izE '\.(jpe?g|png|webp|gif|bmp|tiff?)$')
[[ ${#images[@]} -eq 0 ]] && { clear; echo "No wallpapers found in $WDIR — add some first!"; sleep 4; exit 1; }

# ───── Background auto-changer function ─────
auto_change() {
    local interval=$1
    local minutes=$((interval / 60))
    echo -e "\033[1;35mEyefest Auto-mode STARTED → every $minutes minutes (background)\033[0m"
    echo -e "\033[0;36mStop with: pkill -f 'eyefest-auto-change'\033[0m"

    while true; do
        img="${images[RANDOM % ${#images[@]}]}"
        set_wallpaper "$img" >/dev/null 2>&1
        sleep "$interval"
    done
}

# ───── Main loop ─────
while :; do
    clear
    cat << "EOF"

                        +-+-+-+-+-+-+-+
                        |E|Y|E|F|E|S|T|
                        +-+-+-+-+-+-+-+
                     E Y E F E S T  •  2025
EOF
    [[ $USE_PLASMA == true ]] && echo -e "   \033[1;35mUsing native KDE Plasma wallpaper engine\033[0m"
    echo -e "   \033[1;36m${#images[@]} wallpapers loaded\033[0m\n"
    echo "   [1] Browse & pick (feh thumbnails)"
    echo "   [2] Set random wallpaper now"
    echo "   [3] Auto-change in background"
    echo "   [4] Open wallpaper folder"
    echo "   [q] Quit Eyefest"
    echo -en "\n   → Choose: "
    read -n1 choice; echo

    case "$choice" in
        1)
            echo -e "\033[1;35mLaunching thumbnail browser… (press Enter on image)\033[0m"
            feh --thumbnails --auto-zoom --sort name "$WDIR"
            last=$(grep -o "'/.*'" ~/.fehbg 2>/dev/null | tr -d "'" | head -1)
            [[ -f "$last" ]] && set_wallpaper "$last"
            sleep 2
            ;;
        2)
            img="${images[RANDOM % ${#images[@]}]}"
            set_wallpaper "$img"
            sleep 2
            ;;
        3)
            clear
            echo "   Eyefest Auto-Change Interval:"
            echo "   [1] 10 min  [2] 15 min  [3] 30 min  [4] 1 hour  [5] 2 hours"
            echo -en "   → Pick (1-5): "; read -n1 i; echo
            case "$i" in
                1) secs=600;  min=10 ;;
                2) secs=900;  min=15 ;;
                3) secs=1800; min=30 ;;
                4) secs=3600; min=60 ;;
                5) secs=7200; min=120;;
                *) echo "Invalid choice"; sleep 2; continue ;;
            esac

            # Kill any previous auto-changer
            pkill -f "eyefest-auto-change" 2>/dev/null

            # Start new one in background
            nohup bash -c "while true; do sleep $secs; img=\"${images[RANDOM % ${#images[@]}]}\"; \
                $(if $USE_PLASMA; then echo plasma-apply-wallpaperimage \"\$img\"; else echo feh --bg-fill \"\$img\"; fi) \
                >/dev/null 2>&1; done" > /dev/null 2>&1 &

            echo -e "\n\033[1;32mAuto-change started in background! ($min min)\033[0m"
            echo -e "\033[0;36mTo stop: pkill -f eyefest-auto-change\033[0m"
            sleep 4
            ;;
        4)
            # Works perfectly on KDE Plasma and everywhere else
            xdg-open "$WDIR" 2>/dev/null || kde-open "$WDIR" 2>/dev/null || dolphin "$WDIR" 2>/dev/null || nautilus "$WDIR" 2>/dev/null || echo "Opened: $WDIR"
            sleep 1
            ;;
        q|Q)
            clear
            echo -e "\033[1;36mEyefest complete — your desktop has been well fed ✨\033[0m"
            exit 0
            ;;
    esac
done
