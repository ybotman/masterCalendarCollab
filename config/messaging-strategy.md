# Messaging Strategy

## 4-Tier Model

```
┌─────────────────────────────────────────────────────────────┐
│  JIRA                          (permanent, tracked work)    │
├─────────────────────────────────────────────────────────────┤
│  Collab (git)                  (cross-machine, days/weeks)  │
│  └── SHOFF2, MSG                                            │
├─────────────────────────────────────────────────────────────┤
│  Local                         (same machine, ephemeral)    │
│  └── SHOFF                                                  │
├─────────────────────────────────────────────────────────────┤
│  Copy/Paste                    (human-mediated, instant)    │
└─────────────────────────────────────────────────────────────┘
```

## Commands

| Command | Type | Tier | Destination |
|---------|------|------|-------------|
| **INBOX** | Startup | Local | Read `~/.claude/local/handoffs/{me}/` latest |
| **INBOX2** | Startup | Local + Git | git pull + check Collab handoffs + inbox, then INBOX |
| **SHOFF** | Self-handoff | Local | Write to `~/.claude/local/handoffs/{me}/` |
| **SHOFF2** | Self-handoff | Git | Write to `Collab/handoffs/{me}/` + git push |
| **MSG {to}** | Cross-persona | Git | Write to `Collab/inbox/{to}/` + git push |

## Directory Structure

### Local (not git, ephemeral)
```
~/.claude/local/
├── handoffs/{persona}/     # SHOFF writes here
└── inbox/{persona}/        # Reserved for future use
```

### Collab (git repo, persistent)
```
/Users/tobybalsley/MyDocs/Collab/
├── config/                 # This directory
│   ├── messaging-strategy.md
│   ├── commands.md
│   └── personas.json
├── handoffs/{persona}/     # SHOFF2 writes here
└── inbox/{persona}/        # MSG writes here
```

## When to Use Each

| Need | Solution |
|------|----------|
| Quick prompt to another persona (same machine) | Copy/paste |
| Self-continuity, same machine | SHOFF → INBOX |
| Self-continuity, cross-machine | SHOFF2 → INBOX2 |
| Cross-persona request (async) | MSG |
| Formal tracked work | JIRA ticket |

## Startup Behavior

### INBOX (fast, local only)
1. Read latest file from `~/.claude/local/handoffs/{me}/`
2. Report status to user

### INBOX2 (full sync)
1. `cd /Users/tobybalsley/MyDocs/Collab && git pull`
2. Read latest from `Collab/handoffs/{me}/`
3. Check `Collab/inbox/{me}/*` for messages
4. Then do INBOX (local)
5. Report status to user

---
*Created: 2026-02-22 by Gotan*
