#!/bin/bash
set -euo pipefail

# 1. Integrity Check
# Replace /etc/os-release with whatever critical file you signed
PUBKEY="/usr/share/auth/pubkey.pem"
SIG="/usr/share/auth/system.sig"
TARGET="/etc/os-release"

if [[ -f "$PUBKEY" && -f "$SIG" ]]; then
    if ! openssl dgst -sha256 -verify "$PUBKEY" -signature "$SIG" "$TARGET" > /dev/null 2>&1; then
        echo "CRITICAL: Image integrity verification failed! Halting System..."
        systemctl poweroff --force
        exit 1
    fi
fi

# 2. Randomized Shortcut Challenge
KEYS=("Ctrl" "Alt" "Shift" "Tab" "Esc" "Enter")
# Randomize 3 keys
PICKED=($(printf "%s\n" "${KEYS[@]}" | shuf -n 3))
echo "--- BSK SECURE BOOT AUTHENTICATION ---"
echo "SEQUENCE REQUIRED: ${PICKED[0]} then ${PICKED[1]} then ${PICKED[2]}"

# Simple listener using 'read' for demonstration (TTY compatible)
# For raw keycodes, you'd use 'showkey' or 'evtest' logic here
for KEY in "${PICKED[@]}"; do
    read -rsn1 -p "Waiting for $KEY..." input
    # In a production script, you'd validate the 'input' scancode here
done

echo -e "Verified. Starting Session..."
systemctl start cosmic-greeter.service # Or your specific display manager service
