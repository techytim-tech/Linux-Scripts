#!/bin/bash
# Ubuntu Server: check release-upgrade availability, prepare the system, or run
# a non-interactive distribution upgrade (use with care; back up first).
#
# Usage:
#   ubuntu-server-upgrade-readiness.sh              # check only
#   ubuntu-server-upgrade-readiness.sh --prepare   # install tooling, config, full-upgrade
#   ubuntu-server-upgrade-readiness.sh --fix       # same as --prepare (alias)
#   ubuntu-server-upgrade-readiness.sh --upgrade   # tooling + check, then YES, full-upgrade, release upgrade
#   ubuntu-server-upgrade-readiness.sh --upgrade --yes   # skip typing YES (automation only)
#   ubuntu-server-upgrade-readiness.sh --prefer-next-lts  # LTS: set Prompt=lts, re-check offer (e.g. path to 26.04)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

usage() {
    cat <<'EOF'
Usage: ubuntu-server-upgrade-readiness.sh [options]
  (no options)     Show release, risk scan, checker, recommendation. Use --prefer-next-lts on LTS to lock Prompt=lts and re-check.
  --prepare, -p    Get system ready: tooling, release-upgrades Prompt, apt full-upgrade.
  --fix, -f        Same as --prepare.
  --upgrade, -u    Tooling + check, then (unless --yes) type YES, apt full-upgrade, then release upgrade.
                   Expect a long maintenance window (often 1–3+ hours total) and almost always a reboot after success.
  --yes, -y        Only with --upgrade: skip the interactive "YES" confirmation (still shows timing/reboot notes).
  --prefer-next-lts, --next-lts
                   For LTS systems: set Prompt=lts, install checker tooling, run do-release-upgrade -c, and print
                   an FAQ (LTS-to-next-LTS in one step, e.g. 24.04 -> 26.04 when offered). Does not run the upgrade.

See: https://documentation.ubuntu.com/server/how-to/software/upgrade-your-release/
EOF
}

print_ok()    { echo -e "${GREEN}✓${RESET} $*"; }
print_warn()  { echo -e "${YELLOW}⚠${RESET} $*"; }
print_err()   { echo -e "${RED}✗${RESET} $*"; }
print_info()  { echo -e "${CYAN}ℹ${RESET} $*"; }

# Typical guidance only — disk, CPU, mirror speed, and LTS vs interim change real times a lot.
print_upgrade_expectations() {
    echo
    print_warn "How long it usually takes (rough guide only):"
    echo "  • Prepare step (apt full-upgrade on your current release): often about 15–60 minutes; slow disks or huge package sets take longer."
    echo "  • Full release upgrade (do-release-upgrade): often about 45 minutes to several hours on a server; moving between LTS releases is commonly toward the long end."
    echo "  • The process can look quiet for long stretches; that is normal while packages are unpacked and configured."
    echo
    print_warn "Reboots and downtime (important):"
    echo "  • Plan on at least one full reboot after a successful release upgrade so the new kernel and core libraries are actually in use."
    echo "  • Until you reboot, the system can be in an awkward in-between state; reboot as soon as the upgrade completes unless the tool tells you to wait."
    echo "  • Expect service interruptions: databases, web stacks, containers, and SSH may restart or be unavailable during the upgrade."
    echo
    print_warn "If you are on SSH or a remote session:"
    echo "  • Use tmux or screen, or your provider’s serial / web console / IPMI, so a dropped network link does not leave a half-finished upgrade unattended."
    echo
    print_info "Logs to watch if something fails: /var/log/dist-upgrade/ and /var/log/apt/ — take backups and snapshots before you start."
    echo
}

# --- Version recommendation (heuristic; verify against do-release-upgrade output) ---

get_release_prompt_mode() {
    local f="/etc/update-manager/release-upgrades"
    [[ -f "$f" ]] || { echo "unset"; return; }
    local p
    p="$(grep -E '^[[:space:]]*Prompt=' "$f" 2>/dev/null | head -1 | sed -n 's/.*Prompt=\([a-z]*\).*/\1/p')"
    [[ -n "$p" ]] && echo "$p" || echo "unset"
}

current_series_is_lts() {
    [[ "${VERSION:-}" == *LTS* ]]
}

extract_offered_release_label() {
    local t="${CHECK_OUT:-}"
    [[ -n "$t" ]] || return 1
    echo "$t" | tr '\n' ' ' | sed -nE "s/.*[Nn]ew release '([^']+)'.*/\1/p" | head -1
}

print_software_issue_scan() {
    echo -e "${BOLD}Software / package risk scan${RESET}"
    echo "────────────────────────────────────────"

    if audit="$($SUDO dpkg --audit 2>/dev/null)" && [[ -n "$audit" ]]; then
        print_warn "dpkg reports broken or incomplete packages (fix before upgrading):"
        echo "$audit" | sed 's/^/  /'
        echo
    else
        print_ok "dpkg --audit: no broken packages reported."
    fi

    if holds="$($SUDO apt-mark showhold 2>/dev/null)" && [[ -n "$holds" ]]; then
        print_warn "Held packages (often block release upgrades until unheld or resolved):"
        echo "$holds" | sed 's/^/  /'
        echo
    else
        print_ok "No packages are on apt hold."
    fi

    local tp=""
    local f
    shopt -s nullglob
    for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
        [[ -f "$f" ]] || continue
        while IFS= read -r line; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*deb(-src)?[[:space:]] ]] || continue
            if [[ "$line" =~ (security|archive|ports|clouds)\.ubuntu\.com ]] \
                || [[ "$line" =~ //[a-z]{2}\.archive\.ubuntu\.com ]] \
                || [[ "$line" =~ esm\.ubuntu\.com ]]; then
                continue
            fi
            tp+="${line}"$'\n'
        done < "$f" 2>/dev/null || true
    done
    shopt -u nullglob

    if [[ -n "${tp// }" ]]; then
        print_warn "Non-default apt sources (confirm each vendor supports your next Ubuntu codename):"
        echo "$tp" | sed 's/^/  /' | head -25
        if [[ $(printf '%s' "$tp" | wc -l) -gt 25 ]]; then
            print_info "(… truncated; inspect /etc/apt/sources.list and sources.list.d/.)"
        fi
        echo
    else
        print_ok "No obvious third-party deb lines detected (still review PPAs and signed-by entries manually)."
    fi

    if command -v snap >/dev/null 2>&1; then
        local sc
        sc="$(snap list 2>/dev/null | awk 'NR>1 {c++} END {print c+0}')"
        if [[ "${sc:-0}" -gt 0 ]]; then
            print_info "Snaps installed: $sc — after a release upgrade, run \"snap refresh\" and check publishers for compatibility with the new base."
        fi
    fi
    echo
}

print_version_upgrade_recommendation() {
    local offered=""
    offered="$(extract_offered_release_label 2>/dev/null || true)"
    local prompt
    prompt="$(get_release_prompt_mode)"
    local on_lts=false
    if current_series_is_lts; then
        on_lts=true
    fi

    echo -e "${BOLD}Which release to move to (recommendation)${RESET}"
    echo "────────────────────────────────────────"
    if [[ -n "$offered" ]]; then
        print_info "The official checker is offering: ${offered}"
        print_info "That is the practical target for do-release-upgrade on this machine (unless you change prompts or sources)."
        if [[ "$offered" == *[Ll][Tt][Ss]* ]]; then
            print_info "Offered release name includes LTS — expect the longer Ubuntu LTS support commitment (plus optional Ubuntu Pro/ESM later)."
        fi
    else
        print_info "Run do-release-upgrade -c after fixing holds/repos to see the exact offered release name."
    fi
    print_info "Your /etc/update-manager/release-upgrades Prompt is: ${prompt} (lts = only LTS-to-LTS jumps when on LTS; normal = next any supported release)."
    echo

    if [[ "$on_lts" == true && "$prompt" == "lts" ]]; then
        print_ok "Recommended path for most servers: take the next LTS when offered (matches Prompt=lts)."
        echo "  Pros: longest standard support window; fewer OS migrations; predictable security updates; well-tested upgrade path."
        echo "  Cons: large package jump in one step; some third-party repos lag until they publish the new series; very old stacks may need config migration (PHP, PostgreSQL major versions, etc.)."
    elif [[ "$on_lts" == true && "$prompt" != "lts" ]]; then
        print_warn "You are on an LTS but Prompt is not \"lts\" — Ubuntu may offer a non-LTS next."
        echo "  Pros of taking the next interim: newer features and kernels sooner."
        echo "  Cons: shorter support per stop; more upgrade cycles; higher operational churn on servers."
        print_info "For conservative servers, set Prompt=lts in /etc/update-manager/release-upgrades (this script’s --prepare does that when VERSION shows LTS)."
    else
        print_ok "Recommended path: take the next offered release (typical for non-LTS with Prompt=normal)."
        echo "  Pros: smaller delta than an LTS-to-LTS leap; you stay on the regular cadence."
        echo "  Cons: you must plan another upgrade within months; less “long runway” than LTS."
    fi
    echo
    print_warn "Third-party software & packages (typical pain points):"
    echo "  • PPAs and vendor repos (Docker, NodeSource, PostgreSQL apt, etc.) may disable or 404 until you edit them for the new codename."
    echo "  • Packages built only for the old release (no upstream build) may be removed or left obsolete — check alternatives before upgrading."
    echo "  • Configuration file merges (conffiles) can still prompt or fail in non-interactive modes; review /var/log/dist-upgrade/."
    echo "  • Kernel modules / DKMS (NVIDIA, ZFS, wireguard out-of-tree, etc.) need modules rebuilt for the new kernel."
    echo "  • Containers/VM images are separate, but host toolchains (docker.io, qemu) version-shift with the OS."
    echo
    if current_series_is_lts; then
        print_info "LTS-to-next-LTS behaviour and Prompt=lts: run $0 --prefer-next-lts (sets Prompt=lts and re-checks the offer)."
    fi
}

print_lts_path_faq() {
    echo -e "${BOLD}LTS upgrades: choosing the next LTS (e.g. 24.04 -> 26.04)${RESET}"
    echo "────────────────────────────────────────"
    echo "  • Ubuntu does not give a menu to pick an arbitrary future version (you cannot skip straight from 24.04 to 30.04 in one tool run)."
    echo "  • With Prompt=lts in /etc/update-manager/release-upgrades while you are on an LTS, the upgrader is meant to offer the *next* LTS when it is the supported jump — for example 24.04 LTS to 26.04 LTS in *one* do-release-upgrade when Canonical enables that path (Ubuntu uses versions like 26.04, not 26.0.4)."
    echo "  • You do not need to install each interim release (24.10, 25.x) in between for that LTS-to-LTS offer; that is the point of Prompt=lts."
    echo "  • The exact name shown is always whatever \"do-release-upgrade -c\" prints; distro-info CSV hints are informational only."
    echo "  • If no upgrade is offered: you may already be current, the next LTS may not be open for your arch yet, or pins/holds/third-party repos may block detection — fix those and re-run the checker."
    echo
}

next_lts_version_hint_from_csv() {
    local cur="${VERSION_ID:-}"
    local csv="/usr/share/distro-info/ubuntu.csv"
    [[ -f "$csv" && -n "$cur" ]] || return 1
    local best="" line ver
    while IFS= read -r line; do
        [[ "$line" == version,* ]] && continue
        [[ "$line" != *LTS* ]] && continue
        ver="${line%%,*}"
        ver="${ver//\"/}"
        [[ "$ver" =~ ^[0-9]+\.[0-9]+$ ]] || continue
        dpkg --compare-versions "$ver" gt "$cur" 2>/dev/null || continue
        if [[ -z "$best" ]] || dpkg --compare-versions "$ver" lt "$best" 2>/dev/null; then
            best="$ver"
        fi
    done < <(tail -n +2 "$csv")
    if [[ -n "$best" ]]; then
        echo "$best"
        return 0
    fi
    return 1
}

apply_prefer_next_lts_path() {
    print_lts_path_faq
    if ! current_series_is_lts; then
        print_err "This install is not an LTS (os-release VERSION has no \"LTS\"). Use the normal upgrade path; --prefer-next-lts is only for LTS."
        exit 1
    fi
    print_info "Updating apt and installing release-upgrade tooling (no full-release upgrade yet)…"
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get update -y
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ubuntu-release-upgrader-core update-manager-core distro-info-data
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get -f install -y
    $SUDO dpkg --configure -a
    configure_release_prompt
    print_ok "Prompt is set for LTS behaviour (see /etc/update-manager/release-upgrades)."
    if nl="$(next_lts_version_hint_from_csv 2>/dev/null)"; then
        print_info "Distro-info CSV includes a newer LTS line with version ${nl} (hint only; trust do-release-upgrade -c for the real offer)."
    fi
    if ! command -v do-release-upgrade >/dev/null 2>&1; then
        print_err "do-release-upgrade still missing after install."
        exit 1
    fi
    print_info "Running do-release-upgrade -c …"
    run_release_check
    echo "$CHECK_OUT"
    echo
    if release_advertised; then
        print_ok "A distribution upgrade is being offered."
        print_version_upgrade_recommendation
        print_info "When you are ready to perform it: $0 --upgrade   (or --upgrade --yes only if you accept unattended risk)"
    else
        print_info "No new release is being offered right now. When Ubuntu opens the LTS-to-LTS path for this system, re-run this script or: sudo do-release-upgrade -c"
    fi
    exit 0
}

PREPARE_MODE=false
UPGRADE_MODE=false
YES_ASSUME=false

PREFER_NEXT_LTS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prepare|-p|--fix|-f) PREPARE_MODE=true ;;
        --upgrade|-u)          UPGRADE_MODE=true ;;
        --yes|-y)              YES_ASSUME=true ;;
        --prefer-next-lts|--next-lts) PREFER_NEXT_LTS=true ;;
        -h|--help)             usage; exit 0 ;;
        *)                     print_err "Unknown option: $1"; usage; exit 2 ;;
    esac
    shift
done

if [[ "$YES_ASSUME" == true && "$UPGRADE_MODE" != true ]]; then
    print_warn "Ignoring --yes (only applies with --upgrade)."
fi

if [[ "$PREFER_NEXT_LTS" == true && "$UPGRADE_MODE" == true ]]; then
    print_err "Use --prefer-next-lts alone to set Prompt=lts and check the offer; then run --upgrade in a second step."
    exit 2
fi

if [[ "$PREFER_NEXT_LTS" == true && "$PREPARE_MODE" == true ]]; then
    print_warn "Ignoring --prepare for this run (--prefer-next-lts does not run apt full-upgrade). Run --prepare afterward if you still need same-release updates."
    PREPARE_MODE=false
fi

if [[ ! -f /etc/os-release ]]; then
    print_err "/etc/os-release not found."
    exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    print_err "This script targets Ubuntu (ID=${ID:-unknown})."
    exit 1
fi

SUDO=""
if [[ "${EUID:-1}" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        print_err "Root or sudo is required."
        exit 1
    fi
fi

echo -e "${BOLD}Ubuntu Server upgrade readiness${RESET}"
echo "────────────────────────────────────────"
print_info "Installed: ${PRETTY_NAME:-$NAME $VERSION_ID}"
print_info "Codename: ${VERSION_CODENAME:-unknown}  Version ID: ${VERSION_ID:-unknown}"
echo

next_from_csv() {
    local cur="${VERSION_ID:-}"
    local csv="/usr/share/distro-info/ubuntu.csv"
    [[ -f "$csv" ]] || return 1
    [[ -n "$cur" ]] || return 1
    local best_ver="" best_code=""
    local ver codename
    while IFS= read -r line; do
        [[ "$line" == version,* ]] && continue
        ver="${line%%,*}"
        ver="${ver//\"/}"
        codename="${line#*,}"
        codename="${codename%%,*}"
        codename="${codename//\"/}"
        [[ "$ver" =~ ^[0-9]+\.[0-9]+$ ]] || continue
        dpkg --compare-versions "$ver" gt "$cur" 2>/dev/null || continue
        if [[ -z "$best_ver" ]] || dpkg --compare-versions "$ver" lt "$best_ver" 2>/dev/null; then
            best_ver="$ver"
            best_code="$codename"
        fi
    done < <(tail -n +2 "$csv")
    if [[ -n "$best_ver" ]]; then
        echo "$best_ver ($best_code)"
        return 0
    fi
    return 1
}

if hint="$(next_from_csv 2>/dev/null)"; then
    print_info "Next newer series in distro-info data: Ubuntu $hint"
else
    print_warn "Could not derive next release from /usr/share/distro-info/ubuntu.csv (install distro-info-data via --prepare)."
fi
echo

print_software_issue_scan

configure_release_prompt() {
    local rel_cfg="/etc/update-manager/release-upgrades"
    local prompt_val="normal"
    case "${VERSION:-}" in
        *LTS*) prompt_val="lts" ;;
    esac
    if [[ ! -f "$rel_cfg" ]]; then
        print_info "Creating $rel_cfg with Prompt=$prompt_val"
        echo "[DEFAULT]" | $SUDO tee "$rel_cfg" >/dev/null
        echo "Prompt=$prompt_val" | $SUDO tee -a "$rel_cfg" >/dev/null
    else
        if grep -qE '^[[:space:]]*Prompt=' "$rel_cfg" 2>/dev/null; then
            $SUDO sed -i "s/^[[:space:]]*Prompt=.*/Prompt=$prompt_val/" "$rel_cfg"
            print_ok "Set Prompt=$prompt_val in $rel_cfg"
        else
            echo "Prompt=$prompt_val" | $SUDO tee -a "$rel_cfg" >/dev/null
            print_ok "Appended Prompt=$prompt_val to $rel_cfg"
        fi
    fi
}

install_upgrade_prerequisites() {
    print_info "Updating package lists and installing release-upgrade tooling…"
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get update -y
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ubuntu-release-upgrader-core update-manager-core distro-info-data
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get -f install -y
    $SUDO dpkg --configure -a
    configure_release_prompt
}

run_same_release_full_upgrade() {
    print_info "Running apt full-upgrade on the current release (recommended before release upgrade)…"
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
}

run_prepare() {
    print_info "Preparing system: tooling, prompts, and same-release full-upgrade…"
    print_info "This step alone often takes about 15–60 minutes; schedule downtime if this is production. A reboot may be needed afterward if the kernel or systemd was upgraded."
    install_upgrade_prerequisites
    run_same_release_full_upgrade
    print_ok "Prepare steps finished."
    echo
}

run_release_check() {
    set +e
    CHECK_OUT="$($SUDO do-release-upgrade -c 2>&1)"
    CHECK_RC=$?
    set -e
}

release_advertised() {
    echo "$CHECK_OUT" | grep -qiE 'new release|new version'
}

if [[ "$PREFER_NEXT_LTS" == true ]]; then
    apply_prefer_next_lts_path
fi

if [[ "$UPGRADE_MODE" == true ]]; then
    install_upgrade_prerequisites

    if ! command -v do-release-upgrade >/dev/null 2>&1; then
        print_err "do-release-upgrade missing after installing prerequisites."
        exit 1
    fi

    print_info "Checking whether Ubuntu offers a new distribution release…"
    run_release_check
    echo "$CHECK_OUT"
    echo
    if ! release_advertised; then
        print_err "No new distribution release is being offered; not starting upgrade."
        exit 1
    fi

    print_version_upgrade_recommendation

    print_upgrade_expectations
    print_warn "You are about to change thousands of packages on this release, then jump to the next. Use a stable console and backups."
    if [[ "$YES_ASSUME" != true ]]; then
        if [[ ! -t 0 ]]; then
            print_err "Refusing upgrade on non-interactive stdin without --yes."
            exit 1
        fi
        read -r -p "Type YES to run apt full-upgrade and start the release upgrade: " confirm
        if [[ "$confirm" != "YES" ]]; then
            print_err "Aborted (you did not type YES)."
            exit 1
        fi
    else
        print_info "Proceeding with --yes (skipping interactive confirmation)."
    fi

    run_same_release_full_upgrade
    echo

    print_info "Starting non-interactive release upgrade (see timing note above; do not interrupt)…"
    export DEBIAN_FRONTEND=noninteractive
    set +e
    $SUDO DEBIAN_FRONTEND=noninteractive do-release-upgrade \
        -f DistUpgradeViewNonInteractive \
        -m server
    up_rc=$?
    set -e
    if [[ "$up_rc" -eq 0 ]]; then
        print_ok "do-release-upgrade finished with exit 0."
        print_warn "Next step: reboot this machine when you are ready (almost always required after a release upgrade)."
        print_info "After reboot, verify critical services, firewall rules, and any third-party apt sources for the new release."
    else
        print_warn "do-release-upgrade exited with status $up_rc. Review logs and /var/log/dist-upgrade/."
        print_warn "Do not reboot blindly if the upgrade failed partway; inspect dpkg/apt state and logs first."
    fi
    exit "$up_rc"
fi

if [[ "$PREPARE_MODE" == true ]]; then
    run_prepare
fi

if ! command -v do-release-upgrade >/dev/null 2>&1; then
    print_err "do-release-upgrade not found. Run with --prepare or --fix to install tooling."
    exit 1
fi

print_info "Checking whether Ubuntu advertises a new distribution release…"
run_release_check
echo "$CHECK_OUT"
echo

if release_advertised; then
    print_ok "A newer Ubuntu release appears to be available for this system."
    print_version_upgrade_recommendation
    print_upgrade_expectations
    print_info "Prepare only (same release): $0 --prepare"
    print_info "Full release upgrade: $0 --upgrade   (add --yes to skip the confirmation prompt)"
    exit 0
fi

if [[ "$CHECK_RC" -ne 0 ]]; then
    print_warn "Checker exited with status $CHECK_RC (often means no upgrade offered or another condition)."
fi

if echo "$CHECK_OUT" | grep -qi 'no new release'; then
    print_info "Ubuntu reports no new release right now (you may already be current, or prompts/network/policy may apply)."
fi

print_info "See: https://documentation.ubuntu.com/server/how-to/software/upgrade-your-release/"
exit 0
