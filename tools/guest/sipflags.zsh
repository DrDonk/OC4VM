#!/usr/bin/env zsh
# {{VERSION}}-{{COMMIT}}
# SPDX-FileCopyrightText: © 2023-2026 David Parsons
# SPDX-License-Identifier: MIT

# sipflags.sh - combine csr-active-config flags, print hex/base64, optionally write to an OpenCore/OCLP config.plist.
# Works in bash (incl. macOS 3.2) and zsh. Flag names/bits per XNU bsd/sys/csr.h.
#
# Usage: sipflags.sh [-l] [-p config.plist] [-k key] <token> [<token> ...]
#        sipflags.sh status [-p config.plist] [-k key]
#   token:  a flag name, a preset, "no-<flag>" to clear a flag, or a number (0x7f / 127)
#           Tokens are applied left to right; commas are allowed (kext,fs,debug).
#   -l      list flags and presets
#   -p FILE write the value (4-byte little-endian <data>) to FILE at
#           NVRAM > Add > 7C436110-AB2A-4BBB-A880-FE41995C9F82 > <key>
#           (a FILE.bak backup is made first; missing dicts are created)
#   -k KEY  key name to write/read (default: csr-active-config)
#   status  show the live NVRAM value and (with -p) the config.plist value, decoded and compared
# Examples:
#   sipflags.sh disable                       # 0x7f
#   sipflags.sh disable no-internal           # 0x6f
#   sipflags.sh -p /Volumes/EFI/EFI/OC/config.plist disable no-internal
#   sipflags.sh status -p /Volumes/EFI/EFI/OC/config.plist

# Enable debug mode if DEBUG environment variable is set to any non-empty value
[[ -n "$DEBUG" ]] && set -x

GUID="7C436110-AB2A-4BBB-A880-FE41995C9F82"
KEY="csr-active-config"
PLIST=""

flag_value() {
  case "$1" in
    kext)                 echo $((0x001)) ;;  # CSR_ALLOW_UNTRUSTED_KEXTS
    fs)                   echo $((0x002)) ;;  # CSR_ALLOW_UNRESTRICTED_FS
    debug)                echo $((0x004)) ;;  # CSR_ALLOW_TASK_FOR_PID
    kdebug)               echo $((0x008)) ;;  # CSR_ALLOW_KERNEL_DEBUGGER
    internal)             echo $((0x010)) ;;  # CSR_ALLOW_APPLE_INTERNAL
    dtrace)               echo $((0x020)) ;;  # CSR_ALLOW_UNRESTRICTED_DTRACE
    nvram)                echo $((0x040)) ;;  # CSR_ALLOW_UNRESTRICTED_NVRAM
    devconfig)            echo $((0x080)) ;;  # CSR_ALLOW_DEVICE_CONFIGURATION
    basesystem)           echo $((0x100)) ;;  # CSR_ALLOW_ANY_RECOVERY_OS
    unapproved-kexts)     echo $((0x200)) ;;  # CSR_ALLOW_UNAPPROVED_KEXTS (spctl kext-consent disable)
    exec-policy)          echo $((0x400)) ;;  # CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE
    unauth-root)          echo $((0x800)) ;;  # CSR_ALLOW_UNAUTHENTICATED_ROOT (authenticated-root disable)
    research-guests)      echo $((0x1000)) ;; # CSR_ALLOW_RESEARCH_GUESTS
    *) return 1 ;;
  esac
}

list_all() {
  cat <<'TXT'
Flags (a set bit relaxes the protection):
  kext              0x001  untrusted kexts
  fs                0x002  unrestricted filesystem
  debug             0x004  task_for_pid / debugging
  kdebug            0x008  kernel debugger
  internal          0x010  Apple Internal
  dtrace            0x020  unrestricted DTrace
  nvram             0x040  unrestricted NVRAM
  devconfig         0x080  device configuration
  basesystem        0x100  any recovery OS
  unapproved-kexts  0x200  unapproved kexts
  exec-policy       0x400  executable policy override
  unauth-root       0x800  unauthenticated root
  research-guests   0x1000 research guests
Presets (start values, equal to csrutil from empty NVRAM):
  disable           0x7f   kext fs debug kdebug internal dtrace nvram
  enable            0x10   internal (plain 'csrutil enable' leaves Apple Internal set)
Use no-<flag> to clear, e.g. "disable no-internal" = 0x6f.
TXT
}

die() { echo "error: $*" >&2; exit 1; }

FLAG_NAMES="kext fs debug kdebug internal dtrace nvram devconfig basesystem unapproved-kexts exec-policy unauth-root research-guests"

classify() {   # $1 = numeric value; same masking/thresholds as 'csrutil status'
  case $(( $1 & ~0xe00 )) in
    0) echo "enabled" ;; 16) echo "enabled (Apple Internal)" ;;
    111) echo "disabled" ;; 127) echo "disabled (Apple Internal)" ;;
    *) echo "custom configuration" ;;
  esac
}

describe_flags() {   # $1 = numeric value -> list of relaxed protections
  local out="" n v
  for n in $FLAG_NAMES; do
    v=$(flag_value "$n")
    [ $(( $1 & v )) -ne 0 ] && out="$out $n"
  done
  echo "${out# }"
}

hexle_to_value() {   # "7f000000" -> 127
  local h="$1"
  echo $(( 0x${h:6:2}${h:4:2}${h:2:2}${h:0:2} ))
}

b64dec() { printf %s "$1" | base64 -D 2>/dev/null || printf %s "$1" | base64 -d; }

show_source() {   # $1=label $2=hexle (empty = not set)
  local label="$1" h="$2" v
  if [ -z "$h" ]; then printf '%-22s: not set\n' "$label"; return; fi
  if [ ${#h} -lt 8 ]; then printf '%-22s: unexpected data (%s)\n' "$label" "$h"; return; fi
  h="${h:0:8}"
  v=$(hexle_to_value "$h")
  printf '%-22s: 0x%08X  bytes %s  base64 %s\n' "$label" "$v" "$h" \
    "$(b64dec_from_hex "$h")"
  printf '%-22s  %s; relaxed: %s\n' "" "$(classify $v)" "$(describe_flags $v)"
}

b64dec_from_hex() {  # hex bytes -> base64
  local h="$1" i out=""
  for i in 0 2 4 6; do out="$out\\$(printf '%03o' $((0x${h:$i:2})))"; done
  printf "$out" | base64
}

do_status() {
  local nv="" pl="" raw b64 PL_DEL=""
  echo "== Live NVRAM: $KEY =="
  if command -v nvram >/dev/null 2>&1; then
    raw=$(nvram -x "$KEY" 2>/dev/null | tr -d '\n\t ')
    b64=$(printf %s "$raw" | sed -n 's:.*<data>\(.*\)</data>.*:\1:p')
    [ -n "$b64" ] && nv=$(b64dec "$b64" | od -An -tx1 | tr -d ' \n')
    show_source "NVRAM" "$nv"
  else
    echo "nvram command not available on this system"
  fi
  if command -v csrutil >/dev/null 2>&1; then
    printf '%-22s: %s\n' "csrutil status" "$(csrutil status 2>/dev/null | head -1)"
  fi
  if [ -n "$PLIST" ]; then
    echo
    echo "== $PLIST =="
    [ -f "$PLIST" ] || die "plist not found: $PLIST"
    if [ -x /usr/libexec/PlistBuddy ]; then
      pl=$(/usr/libexec/PlistBuddy -c "Print :NVRAM:Add:$GUID:$KEY" "$PLIST" 2>/dev/null | od -An -tx1 | tr -d ' \n')
      /usr/libexec/PlistBuddy -c "Print :NVRAM:Delete:$GUID" "$PLIST" 2>/dev/null | grep -q "^ *$KEY\$" && PL_DEL=yes || PL_DEL=no
    else
      die "need /usr/libexec/PlistBuddy to read the plist"
    fi
    show_source "config.plist (Add)" "$pl"
    printf '%-22s: %s\n' "In NVRAM > Delete" "$PL_DEL"
    echo
    if [ -n "$nv" ] && [ -n "$pl" ]; then
      if [ "${nv:0:8}" = "${pl:0:8}" ]; then echo "Result: NVRAM matches config.plist"
      else echo "Result: NVRAM DIFFERS from config.plist (reboot needed, or OpenCore did not apply it)"; fi
    fi
    if [ "$PL_DEL" = "no" ]; then
      echo "Note: $KEY is not in NVRAM > Delete for this GUID, so OpenCore will not overwrite an existing NVRAM value."
    fi
  fi
}

write_plist() {   # $1=file  $2=hex of the 4 LE bytes
  local file="$1" hexle="$2" p
  [ -f "$file" ] || die "plist not found: $file"
  [ -w "$file" ] || die "plist not writable: $file (try sudo)"
  cp -p "$file" "$file.bak" || die "could not create backup $file.bak"
  if [ -x /usr/libexec/PlistBuddy ]; then
    local tmp; tmp=$(mktemp -t sipflags) || die "mktemp failed"
    printf "\\$(printf '%03o' $b0)\\$(printf '%03o' $b1)\\$(printf '%03o' $b2)\\$(printf '%03o' $b3)" > "$tmp"
    pb() { /usr/libexec/PlistBuddy -c "$1" "$file"; }
    for p in ":NVRAM" ":NVRAM:Add" ":NVRAM:Add:$GUID"; do
      pb "Print $p" >/dev/null 2>&1 || pb "Add $p dict" >/dev/null || { rm -f "$tmp"; die "could not create $p"; }
    done
    pb "Delete :NVRAM:Add:$GUID:$KEY" >/dev/null 2>&1
    pb "Import :NVRAM:Add:$GUID:$KEY $tmp" >/dev/null || { rm -f "$tmp"; die "PlistBuddy Import failed"; }
    rm -f "$tmp"
    printf 'Wrote %s (PlistBuddy), now: ' "$KEY"
    pb "Print :NVRAM:Add:$GUID:$KEY" | od -An -tx1 | tr -d '\n'; echo
  else
    die "need /usr/libexec/PlistBuddy to write the plist"
  fi
  echo "Backup: $file.bak"
}

echo "OC4VM sipflags"
echo "--------------"
[ $# -eq 0 ] && { list_all; exit 0; }

value=0
MODE=""
while [ $# -gt 0 ]; do
  arg="$1"; shift
  case "$arg" in
    -l|--list|-h|--help) list_all; exit 0 ;;
    -p) [ $# -ge 1 ] || die "-p needs a file"; PLIST="$1"; shift; continue ;;
    -k) [ $# -ge 1 ] || die "-k needs a key name"; KEY="$1"; shift; continue ;;
    status|-s) MODE=status; continue ;;
  esac
  for tok in $(echo "$arg" | tr 'A-Z,' 'a-z '); do
    case "$tok" in
      disable) value=$((value | 0x7f)) ;;
      enable)  value=$((value | 0x10)) ;;
      no-*)    v=$(flag_value "${tok#no-}") || die "unknown flag '${tok#no-}'"
               value=$((value & ~v)) ;;
      0x[0-9a-f]*|[0-9]*)
               value=$((value | tok)) ;;
      *)       v=$(flag_value "$tok") || die "unknown token '$tok' (try -l)"
               value=$((value | v)) ;;
    esac
  done
done

[ "$MODE" = status ] && { do_status; exit 0; }

[ $((value & ~0x1fff)) -ne 0 ] && echo "warning: bits outside CSR_VALID_FLAGS (0x1fff) are set" >&2

# 4-byte little-endian, as stored in the csr-active-config NVRAM property
b0=$((value & 255)); b1=$(((value >> 8) & 255)); b2=$(((value >> 16) & 255)); b3=$(((value >> 24) & 255))
hexle=$(printf '%02x%02x%02x%02x' $b0 $b1 $b2 $b3)
b64=$(printf "\\$(printf '%03o' $b0)\\$(printf '%03o' $b1)\\$(printf '%03o' $b2)\\$(printf '%03o' $b3)" | base64)

# What 'csrutil status' would call it: 0x200/0x400/0x800 are masked out first
masked=$((value & ~0xe00))
case $masked in
  0)   state="enabled" ;;
  16)  state="enabled (Apple Internal)" ;;
  111) state="disabled" ;;
  127) state="disabled (Apple Internal)" ;;
  *)   state="custom configuration" ;;
esac

printf 'Value (hex)        : 0x%08X\n' "$value"
printf 'Value (decimal)    : %d\n' "$value"
printf 'Bytes (LE, hex)    : %s\n' "$hexle"
printf 'Base64 (LE bytes)  : %s\n' "$b64"
printf 'csrutil status     : %s\n' "$state"
printf 'nvram (Recovery)   : nvram %s=%%%s%%%s%%%s%%%s\n' "$KEY" \
  "$(printf %02x $b0)" "$(printf %02x $b1)" "$(printf %02x $b2)" "$(printf %02x $b3)"

[ -n "$PLIST" ] && write_plist "$PLIST" "$hexle"
exit 0
