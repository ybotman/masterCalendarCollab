# Command Reference

## INBOX
**Type:** Startup | **Tier:** Local

Check local handoffs for session continuity.

```bash
# Read latest handoff
LATEST=$(ls -t ~/.claude/local/handoffs/{me}/*.md 2>/dev/null | head -1)
[ -n "$LATEST" ] && cat "$LATEST"
```

**When:** Start of session, same machine

---

## INBOX2
**Type:** Startup | **Tier:** Local + Git

Full sync: pull from Collab, check git handoffs and messages, then local.

```bash
# 1. Pull latest
cd /Users/tobybalsley/MyDocs/Collab && git pull

# 2. Read Collab handoff
LATEST=$(ls -t /Users/tobybalsley/MyDocs/Collab/handoffs/{me}/*.md 2>/dev/null | head -1)
[ -n "$LATEST" ] && cat "$LATEST"

# 3. Check Collab inbox
ls -lt /Users/tobybalsley/MyDocs/Collab/inbox/{me}/*.json 2>/dev/null | head -5

# 4. Then do INBOX (local)
```

**When:** Start of session, switched machines or need full sync

---

## SHOFF
**Type:** Self-handoff | **Tier:** Local

Write handoff for future self (same machine).

```bash
cat > ~/.claude/local/handoffs/{me}/session_$(date +%Y-%m-%dT%H-%M).md <<'EOF'
# Session Handoff: {persona} @ {timestamp}

## Current Status
{ONE_LINE_STATUS}

## What I Did This Session
- {BULLET_POINTS}

## Next Session Should
1. Run INBOX
2. {NEXT_STEP}

## Key Context
{IMPORTANT_CONTEXT}
EOF
```

**When:** End of session, will resume on same machine

---

## SHOFF2
**Type:** Self-handoff | **Tier:** Git

Write handoff for future self (any machine), push to Collab.

```bash
cat > /Users/tobybalsley/MyDocs/Collab/handoffs/{me}/session_$(date +%Y-%m-%dT%H-%M).md <<'EOF'
# Session Handoff: {persona} @ {timestamp}

## Current Status
{ONE_LINE_STATUS}

## What I Did This Session
- {BULLET_POINTS}

## Next Session Should
1. Run INBOX2
2. {NEXT_STEP}

## Key Context
{IMPORTANT_CONTEXT}
EOF

cd /Users/tobybalsley/MyDocs/Collab
git add handoffs/
git commit -m "SHOFF2: {persona} @ $(date +%Y-%m-%d)"
git push origin main
```

**When:** End of session, may resume on different machine

---

## MSG {to}
**Type:** Cross-persona | **Tier:** Git

Send message to another persona via Collab inbox.

```bash
cat > /Users/tobybalsley/MyDocs/Collab/inbox/{to}/msg_$(date +%Y%m%d_%H%M%S)_{me}_001.json <<'EOF'
{
  "from": "{me}",
  "to": ["{to}"],
  "subject": "{SUBJECT}",
  "priority": "medium",
  "timestamp": "{ISO_TIMESTAMP}",
  "body": "{MESSAGE_BODY}"
}
EOF

cd /Users/tobybalsley/MyDocs/Collab
git add inbox/
git commit -m "MSG: {me} → {to}"
git push origin main
```

**Recipients:**
- Individual: `MSG fulton`, `MSG sarah`, etc.
- Broadcast: `MSG broadcast`

**When:** Need async communication with another persona

---
*Created: 2026-02-22 by Gotan*
