#!/bin/bash
# List Ubuntu releases (from distro-info) and suggest or apply an archive mirror
# host derived from the system timezone (IANA) → country code → CC.archive.ubuntu.com.
#
# Usage:
#   ubuntu-releases-mirror.sh                  # releases + suggested mirror
#   ubuntu-releases-mirror.sh --releases-only
#   ubuntu-releases-mirror.sh --mirror-only
#   ubuntu-releases-mirror.sh --apply          # backup + rewrite archive.ubuntu.com URLs
#   ubuntu-releases-mirror.sh --mirror-only --pick   # menu: pick region (ignore time zone map)
#   ubuntu-releases-mirror.sh --apply --pick         # pick region then rewrite apt sources

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

usage() {
    cat <<'EOF'
ubuntu-releases-mirror.sh [option]
  (none)           Show Ubuntu releases and suggested archive mirror from timezone.
  --releases-only  Show releases only (needs distro-info-data).
  --mirror-only    Suggest mirror only.
  --pick           Skip time zone map; pick region from the menu (with default or --mirror-only).
  --apply          Replace archive.ubuntu.com with chosen mirror (combine with --pick if you want).
  -h, --help       This help.

Mirror choice uses your IANA timezone (timedatectl / /etc/timezone) mapped to a
country code, then https://cc.archive.ubuntu.com/ubuntu . Unknown zones prompt
for a region. security.ubuntu.com is not modified.
EOF
}

print_ok()    { echo -e "${GREEN}✓${RESET} $*"; }
print_warn()  { echo -e "${YELLOW}⚠${RESET} $*"; }
print_err()   { echo -e "${RED}✗${RESET} $*"; }
print_info()  { echo -e "${CYAN}ℹ${RESET} $*"; }

MODE=all
PICK_MIRROR=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --releases-only) MODE=releases ;;
        --mirror-only)   MODE=mirror ;;
        --apply)         MODE=apply ;;
        --pick)          PICK_MIRROR=true ;;
        -h|--help)       usage; exit 0 ;;
        *)               print_err "Unknown option: $1"; usage; exit 2 ;;
    esac
    shift
done

if [[ "$PICK_MIRROR" == true && "$MODE" == "releases" ]]; then
    print_warn "--pick is ignored with --releases-only."
fi

if [[ ! -f /etc/os-release ]]; then
    print_err "/etc/os-release not found."
    exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    print_err "This script is intended for Ubuntu (ID=${ID:-unknown})."
    exit 1
fi

SUDO=""
if [[ "${EUID:-1}" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        SUDO=""
    fi
fi

require_sudo_for_apply() {
    if [[ -z "$SUDO" ]]; then
        print_err "Root or sudo is required for --apply."
        exit 1
    fi
}

get_timezone() {
    local tz=""
    if command -v timedatectl >/dev/null 2>&1; then
        tz="$(timedatectl show -p Timezone --value 2>/dev/null || true)"
    fi
    if [[ -z "$tz" || "$tz" == "n/a" ]] && [[ -f /etc/timezone ]]; then
        IFS= read -r tz < /etc/timezone
    fi
    tz="${tz//$'\r'/}"
    tz="${tz// /}"
    printf '%s' "$tz"
}

# IANA zone → ISO 3166-1 alpha-2 (subset). More-specific regions before broad US/EU defaults.
zone_to_country() {
    local tz="$1"
    case "$tz" in
        Africa/Johannesburg) echo za ;;
        Africa/Cairo)        echo eg ;;
        Africa/Lagos)        echo ng ;;
        Africa/Nairobi)      echo ke ;;
        America/Toronto|America/Montreal|America/Vancouver|America/St_Johns|America/Halifax|America/Moncton|America/Blanc-Sablon|America/Glace_Bay|America/Goose_Bay|America/Regina|America/Swift_Current|America/Whitehorse|America/Dawson|America/Creston|America/Fort_Nelson|America/Atikokan|America/Rainy_River|America/Coral_Harbour|America/Iqaluit|America/Nipigon|America/Thunder_Bay|America/Yellowknife|America/Edmonton|America/Cambridge_Bay|America/Inuvik|America/Rankin_Inlet|America/Resolute) echo ca ;;
        America/Mexico_City|America/Cancun|America/Merida|America/Monterrey|America/Mazatlan|America/Chihuahua|America/Ojinaga|America/Hermosillo|America/Tijuana|America/Bahia_Banderas) echo mx ;;
        America/Sao_Paulo|America/Fortaleza|America/Recife|America/Maceio|America/Araguaina|America/Belem|America/Bahia|America/Campo_Grande|America/Cuiaba|America/Santarem|America/Manaus|America/Eirunepe|America/Rio_Branco|America/Porto_Velho|America/Boa_Vista|America/Noronha) echo br ;;
        America/Buenos_Aires|America/Cordoba|America/Jujuy|America/Mendoza|America/Catamarca|America/Argentina/La_Rioja|America/Argentina/Rio_Gallegos|America/Argentina/Salta|America/Argentina/San_Juan|America/Argentina/San_Luis|America/Argentina/Tucuman|America/Argentina/Ushuaia) echo ar ;;
        America/Santiago|America/Punta_Arenas) echo cl ;;
        America/Bogota) echo co ;;
        America/Lima) echo pe ;;
        America/Caracas) echo ve ;;
        America/Guatemala|America/Belize|America/El_Salvador|America/Managua|America/Costa_Rica|America/Panama|America/Tegucigalpa) echo gt ;;
        America/Anchorage|America/Juneau|America/Nome|America/Sitka|America/Yakutat|US/Alaska) echo us ;;
        America/Phoenix|America/Boise|America/Denver|America/Shiprock|US/Mountain) echo us ;;
        America/Chicago|America/Menominee|America/Winnipeg|America/Rainy_River|America/Rankin_Inlet|America/Resolute|US/Central) echo us ;;
        America/Indiana/Knox|America/Indiana/Tell_City|America/Indiana/Petersburg|America/Indiana/Vincennes|America/Indiana/Marengo|America/Indiana/Vevay|America/Indiana/Winamac|America/Indiana/Indianapolis) echo us ;;
        America/North_Dakota/Center|America/North_Dakota/New_Salem|America/North_Dakota/Beulah) echo us ;;
        America/New_York|America/Detroit|America/Kentucky/Louisville|America/Kentucky/Monticello|America/Louisville|America/Nassau|America/Pangnirtung|America/Nuuk|US/Eastern) echo us ;;
        America/Los_Angeles|America/Tijuana) echo us ;;
        Pacific/Honolulu|US/Hawaii) echo us ;;
        Asia/Tokyo|Asia/Osaka) echo jp ;;
        Asia/Seoul) echo kr ;;
        Asia/Shanghai|Asia/Chongqing|Asia/Harbin|Asia/Urumqi) echo cn ;;
        Asia/Hong_Kong) echo hk ;;
        Asia/Taipei) echo tw ;;
        Asia/Singapore) echo sg ;;
        Asia/Kuala_Lumpur|Asia/Kuching) echo my ;;
        Asia/Bangkok|Asia/Ho_Chi_Minh|Asia/Phnom_Penh|Asia/Vientiane) echo th ;;
        Asia/Jakarta|Asia/Pontianak|Asia/Makassar|Asia/Jayapura) echo id ;;
        Asia/Manila) echo ph ;;
        Asia/Kolkata|Asia/Calcutta) echo in ;;
        Asia/Colombo) echo lk ;;
        Asia/Karachi) echo pk ;;
        Asia/Dhaka) echo bd ;;
        Asia/Dubai|Asia/Muscat) echo ae ;;
        Asia/Riyadh|Asia/Kuwait|Asia/Bahrain|Asia/Qatar|Asia/Aden) echo sa ;;
        Asia/Jerusalem|Asia/Tel_Aviv) echo il ;;
        Asia/Tehran) echo ir ;;
        Asia/Baghdad) echo iq ;;
        Asia/Tbilisi) echo ge ;;
        Asia/Yerevan) echo am ;;
        Asia/Baku) echo az ;;
        Asia/Almaty|Asia/Qyzylorda|Asia/Aqtobe|Asia/Aqtau|Asia/Oral) echo kz ;;
        Asia/Tashkent|Asia/Samarkand) echo uz ;;
        Asia/Novosibirsk|Asia/Yekaterinburg|Asia/Omsk|Asia/Krasnoyarsk|Asia/Irkutsk|Asia/Yakutsk|Asia/Vladivostok|Asia/Magadan|Asia/Kamchatka|Asia/Sakhalin|Asia/Chita|Asia/Ulan_Ude|Asia/Anadyr|Europe/Moscow|Europe/Kaliningrad|Europe/Samara|Europe/Simferopol|Europe/Volgograd|Europe/Astrakhan|Europe/Ulyanovsk|Europe/Kirov) echo ru ;;
        Australia/Sydney|Australia/Melbourne|Australia/Brisbane|Australia/Adelaide|Australia/Perth|Australia/Darwin|Australia/Hobart|Australia/Lord_Howe|Australia/Eucla|Australia/Lindeman|Australia/Broken_Hill|Australia/Currie|Australia/ACT|Australia/Canberra|Australia/NSW|Australia/North|Australia/Queensland|Australia/South|Australia/Tasmania|Australia/Victoria|Australia/West|Australia/Yancowinna) echo au ;;
        Pacific/Auckland|Pacific/Chatham) echo nz ;;
        Europe/London|Europe/Belfast|GB|GB-Eire|Europe/Guernsey|Europe/Jersey|Europe/Isle_of_Man) echo gb ;;
        Europe/Dublin) echo ie ;;
        Europe/Paris|Europe/Monaco) echo fr ;;
        Europe/Berlin|Europe/Busingen) echo de ;;
        Europe/Amsterdam) echo nl ;;
        Europe/Brussels) echo be ;;
        Europe/Luxembourg) echo lu ;;
        Europe/Zurich) echo ch ;;
        Europe/Vienna) echo at ;;
        Europe/Rome|Europe/Vatican|Europe/San_Marino) echo it ;;
        Europe/Madrid|Africa/Ceuta|Atlantic/Canary) echo es ;;
        Europe/Lisbon|Atlantic/Azores|Atlantic/Madeira) echo pt ;;
        Europe/Stockholm) echo se ;;
        Europe/Oslo|Arctic/Longyearbyen) echo no ;;
        Europe/Copenhagen) echo dk ;;
        Europe/Helsinki|Europe/Mariehamn) echo fi ;;
        Europe/Warsaw) echo pl ;;
        Europe/Prague|Europe/Bratislava) echo cz ;;
        Europe/Budapest) echo hu ;;
        Europe/Bucharest) echo ro ;;
        Europe/Sofia) echo bg ;;
        Europe/Athens) echo gr ;;
        Europe/Zagreb) echo hr ;;
        Europe/Belgrade) echo rs ;;
        Europe/Ljubljana) echo si ;;
        Europe/Sarajevo|Europe/Skopje|Europe/Podgorica) echo ba ;;
        Europe/Tirane) echo al ;;
        Europe/Vilnius) echo lt ;;
        Europe/Riga) echo lv ;;
        Europe/Tallinn) echo ee ;;
        Europe/Kiev|Europe/Uzhgorod|Europe/Zaporozhye) echo ua ;;
        Europe/Chisinau) echo md ;;
        Europe/Istanbul) echo tr ;;
        Europe/Minsk) echo by ;;
        Europe/Reykjavik|Atlantic/Reykjavik) echo is ;;
        Europe/Malta) echo mt ;;
        Europe/Nicosia) echo cy ;;
        Africa/Casablanca) echo ma ;;
        Africa/Algiers) echo dz ;;
        Africa/Tunis) echo tn ;;
        UTC|Etc/UTC|Etc/GMT|GMT) echo gb ;;
        *) echo "" ;;
    esac
}

list_releases() {
    local csv="/usr/share/distro-info/ubuntu.csv"
    if [[ ! -f "$csv" ]]; then
        print_warn "Install distro-info-data: sudo apt install distro-info-data"
        return 1
    fi
    echo -e "${BOLD}Ubuntu releases (distro-info)${RESET}"
    printf "%-12s %s\n" "VERSION" "CODENAME"
    printf "%-12s %s\n" "────────────" "────────"
    local tab=$'\t'
    awk -F',' -v tab="$tab" 'NR > 1 && $1 ~ /^"?[0-9]/ {
        gsub(/"/, "", $1); gsub(/"/, "", $2);
        print $1 tab $2
    }' "$csv" | sort -t"$tab" -k1,1V
}

pick_region_interactive() {
    echo
    print_info "Pick the closest regional archive mirror:"
    echo "  1) United States (us)     2) United Kingdom (gb)    3) Germany (de)"
    echo "  4) France (fr)            5) Canada (ca)           6) Australia (au)"
    echo "  7) Japan (jp)             8) Netherlands (nl)      9) Spain (es)"
    echo " 10) Italy (it)            11) Main archive.ubuntu.com (global)"
    read -r -p "Choice [1-11, default 11]: " n
    case "${n:-11}" in
        1)  CC_OUT=us ;;
        2)  CC_OUT=gb ;;
        3)  CC_OUT=de ;;
        4)  CC_OUT=fr ;;
        5)  CC_OUT=ca ;;
        6)  CC_OUT=au ;;
        7)  CC_OUT=jp ;;
        8)  CC_OUT=nl ;;
        9)  CC_OUT=es ;;
        10) CC_OUT=it ;;
        *)  CC_OUT="" ;;
    esac
}

resolve_country_and_mirror() {
    local tz cc
    CC_OUT=""
    MIRROR_HOST=""
    MIRROR_URL=""
    tz="$(get_timezone)"
    print_info "System timezone: ${tz:-not set}"
    if [[ "$PICK_MIRROR" == true ]]; then
        cc=""
    elif [[ -n "$tz" ]]; then
        cc="$(zone_to_country "$tz")"
    else
        cc=""
    fi
    if [[ -n "$cc" ]]; then
        CC_OUT="$cc"
        print_ok "Time zone mapped to mirror country code: $CC_OUT"
    else
        print_warn "No built-in map for this zone (or time zone unset)."
        pick_region_interactive
    fi
    if [[ -z "${CC_OUT:-}" ]]; then
        MIRROR_HOST="archive.ubuntu.com"
        MIRROR_URL="https://archive.ubuntu.com/ubuntu"
        print_info "Using main archive (no country-specific mirror)."
    else
        MIRROR_HOST="${CC_OUT}.archive.ubuntu.com"
        MIRROR_URL="https://${MIRROR_HOST}/ubuntu"
    fi
    echo
    print_info "Suggested archive base: $MIRROR_URL"
    print_info "Current release codename (for sources): ${VERSION_CODENAME:-run: lsb_release -cs}"
    if command -v getent >/dev/null 2>&1; then
        if getent hosts "$MIRROR_HOST" >/dev/null 2>&1; then
            print_ok "Host resolves: $MIRROR_HOST"
        else
            print_warn "DNS did not resolve $MIRROR_HOST — pick another region or use main archive (option 11)."
        fi
    fi
}

apply_mirror_to_sources() {
    require_sudo_for_apply
    resolve_country_and_mirror
    local ts
    ts="$(date +%Y%m%d%H%M%S)"
    local new_host="$MIRROR_HOST"

    if [[ ! -t 0 ]]; then
        print_err "Refusing --apply without a TTY (confirm manually or edit sources by hand)."
        exit 1
    fi
    read -r -p "Rewrite archive.ubuntu.com / *.archive.ubuntu.com URLs to https://${new_host}/ubuntu ? [y/N]: " ans
    if [[ "${ans,,}" != "y" && "${ans,,}" != "yes" ]]; then
        print_info "Aborted."
        exit 0
    fi

    local apt_files=()
    shopt -s nullglob
    apt_files=(/etc/apt/sources.list /etc/apt/sources.list.d/*.list)
    shopt -u nullglob
    local f
    for f in "${apt_files[@]}"; do
        [[ -f "$f" ]] || continue
        grep -qE 'archive\.ubuntu\.com/ubuntu' "$f" 2>/dev/null || continue
        $SUDO cp -a "$f" "${f}.bak.${ts}"
        print_ok "Backed up: ${f}.bak.${ts}"
        $SUDO sed -i \
            "s|https\\?://[[:alnum:].-]*archive\\.ubuntu\\.com/ubuntu|https://${new_host}/ubuntu|g" \
            "$f"
    done
    print_ok "Done. Run: sudo apt update"
    print_warn "Skipped lines using ports.ubuntu.com or security.ubuntu.com."
}

# --- main ---
case "$MODE" in
    releases)
        list_releases || true
        ;;
    mirror)
        echo -e "${BOLD}Mirror from time zone${RESET}"
        echo "────────────────────────────────────────"
        resolve_country_and_mirror
        ;;
    apply)
        echo -e "${BOLD}Apply archive mirror${RESET}"
        echo "────────────────────────────────────────"
        list_releases || true
        echo
        apply_mirror_to_sources
        ;;
    *)
        list_releases || true
        echo
        echo -e "${BOLD}Mirror from time zone${RESET}"
        echo "────────────────────────────────────────"
        resolve_country_and_mirror
        ;;
esac