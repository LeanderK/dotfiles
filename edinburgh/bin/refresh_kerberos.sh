#!/bin/bash

# Require .zshrc.local for tkinit alias
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo "❌ Required file ~/.zshrc.local not found. Please create it and define 'tkinit'."
    exit 1
fi

# Source the file
source "$HOME/.zshrc.local"

# Check if tkinit is available
if ! command -v tkinit &>/dev/null; then
    echo "❌ 'tkinit' not found. Please define it in ~/.zshrc.local."
    exit 1
fi

# Function to get ticket expiry time in seconds
get_ticket_expiry_time() {
    current_year=$(date +%Y)

    klist_output=$(klist)
    krbtgt_line=$(echo "$klist_output" | awk '/krbtgt/')

    expiry_date=$(echo "$krbtgt_line" | awk '{print $3}' | sed 's|\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{2\}\)|20\3-\2-\1|')
    expiry_time=$(echo "$krbtgt_line" | awk '{print $2}')
    expiry_date_time="$expiry_date $expiry_time"

    date -d "$expiry_date_time" +%s 2>/dev/null
}

# Get expiry and current time
expiry=$(get_ticket_expiry_time)
now=$(date +%s)

# Validate expiry and now values
if ! [[ "$expiry" =~ ^[0-9]+$ ]]; then
    echo "❌ Expiry time is not a valid number: $expiry"
    exit 1
fi

if ! [[ "$now" =~ ^[0-9]+$ ]]; then
    echo "❌ Current time is not a valid number: $now"
    exit 1
fi

# Debugging: Log expiry and current time before calculation
echo "🕒 Debug: Expiry time before calculation (epoch): $expiry"
echo "🕒 Debug: Current time before calculation (epoch): $now"

# Calculate remaining time
remaining_time=$((expiry - now))

# Debugging: Log remaining time after calculation
echo "🕒 Debug: Remaining time after calculation (seconds): $remaining_time"

# Validate remaining time
if [ -z "$remaining_time" ]; then
    echo "❌ Failed to calculate remaining time."
    exit 1
fi

# Run tkinit asynchronously with a timeout
run_tkinit_async() {
    echo "🔄 Running tkinit asynchronously..."
    timeout 30s tkinit &> "$HOME/.kerberos_refresh.log" &
    echo "✅ tkinit is running in the background. Logs: $HOME/.kerberos_refresh.log"
}

# Refresh if expiring within 1.5 hours (5400 seconds)
if [ "$remaining_time" -lt 5400 ]; then
    echo "🔄 Refreshing Kerberos ticket (expiring soon)..."
    run_tkinit_async
else
    echo "✅ Kerberos ticket is valid and does not need refreshing."
fi
