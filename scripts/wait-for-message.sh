#!/bin/bash
# wait-for-message.sh - Background task that exits when new message arrives
#
# This script is designed to run as a Claude Code background task.
# It polls for new messages and EXITS when one is found, triggering
# Claude's task-notification system to interrupt the agent.
#
# Usage (in Claude): Run this in background, then work on other tasks.
#   When a message arrives, you'll get a notification.
#
# Example:
#   Bash("/path/to/wait-for-message.sh sarah", run_in_background=true)

AGENT="${1:-}"
POLL_INTERVAL="${2:-30}"
AGENT_MESSAGES_DIR="/Users/tobybalsley/Documents/AppDev/MasterCalendar/agent-messages"

if [ -z "$AGENT" ]; then
    echo "Usage: $0 <agent-name> [poll-interval-seconds]"
    echo "Available agents:"
    ls -1 "$AGENT_MESSAGES_DIR/inbox/" | grep -v broadcast
    exit 1
fi

INBOX="$AGENT_MESSAGES_DIR/inbox/$AGENT"
BROADCAST="$AGENT_MESSAGES_DIR/inbox/broadcast"

# Track files we've already seen (by recording current state)
SEEN_FILE="/tmp/.${AGENT}_seen_messages"
ls "$INBOX"/*.json "$BROADCAST"/*.json 2>/dev/null | sort > "$SEEN_FILE" 2>/dev/null

echo "Watching for messages for: $AGENT"
echo "Checking every ${POLL_INTERVAL}s..."
echo "Will exit and notify when new message arrives."
echo "---"

while true; do
    # Pull latest
    git -C "$AGENT_MESSAGES_DIR" pull origin main --quiet 2>/dev/null

    # Get current message list
    CURRENT_FILE="/tmp/.${AGENT}_current_messages"
    ls "$INBOX"/*.json "$BROADCAST"/*.json 2>/dev/null | sort > "$CURRENT_FILE" 2>/dev/null

    # Find new messages (in current but not in seen)
    NEW_MESSAGES=$(comm -13 "$SEEN_FILE" "$CURRENT_FILE" 2>/dev/null)

    if [ -n "$NEW_MESSAGES" ]; then
        echo ""
        echo "========================================"
        echo "  NEW MESSAGE DETECTED!"
        echo "========================================"
        echo ""

        # Show each new message
        for msg in $NEW_MESSAGES; do
            echo "File: $(basename "$msg")"
            echo "---"
            cat "$msg" 2>/dev/null
            echo ""
            echo "---"
        done

        echo ""
        echo "ACTION REQUIRED: Read and respond to this message."
        echo "Then restart polling with:"
        echo "  Run in background: /Users/tobybalsley/Documents/AppDev/MasterCalendar/agent-messages/scripts/wait-for-message.sh $AGENT"
        echo ""

        # Update seen file before exiting
        cp "$CURRENT_FILE" "$SEEN_FILE"

        # Exit triggers Claude notification!
        exit 0
    fi

    sleep "$POLL_INTERVAL"
done
