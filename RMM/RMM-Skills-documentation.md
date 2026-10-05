# Datto RMM Skills for Claude — user guide (alpha)

Kaseya Automation Content Team · 5 Oct 2026 · 9 skills, alpha stage

Nine skills that let Claude answer everyday Datto RMM questions — from "what broke overnight?"
to "who still runs an old Chrome?" — by reading your Datto RMM account through the Datto RMM
connector. **All nine are read-only:** they never change a device, an alert or a setting.

> **Alpha:** output and parameters may change between versions. Check results before acting on
> them, and send us anything odd.

---

## Before you start

1. **Datto RMM connector** — the "Datto RMM" extension enabled in Claude Desktop, with your
   platform, API key and secret in its settings.
2. **Install the Datto RMM Skills plugin** — it adds all nine skills in one step. If you
   uploaded earlier test copies of the skills yourself, **remove them first**.

## How to run a skill in Claude Desktop

- **Type "/" and start typing "drmm"** in the message box — all nine skills appear in the list.
  Pick one, then add settings after it: `/drmm-patch-posture sites "Northwind Legal"`.
  Put quotes around names with spaces.
- **`/drmm-skill-name readme` opens the full readme** for that skill, e.g. `/drmm-patch-posture readme`:
  every parameter, what it reads, its output and known limits. Nothing is read from your account
  in readme mode.
- **Or just ask.** "What broke overnight?" or "Is NWL-APP01 healthy?" — Claude picks the right
  skill on its own.
- **Add `html`** to any run to get the same report as a styled page.
- Each run opens with a short start-up note (version, expected wait). Larger accounts take a few
  minutes; permission prompts during a run are for read-only tools.

---

## The skills

### drmm-morning-pulse — the daily operations briefing
**Answers:** what should the team spend its first hours on today?
Reads devices, open alerts, overnight resolved alerts and the overnight activity log; separates
new overnight drops from long-dead gear, spots servers about to fail, and gives a plan ranked by
customer impact.
- `/drmm-morning-pulse` — the whole account
- `/drmm-morning-pulse hours 4 technicians 2` — a 4-hour plan for 2 technicians
- `/drmm-morning-pulse for "Northwind Legal" html` — one customer, as a page

### drmm-device-quick-look — one device, right now
**Answers:** what is wrong with this device, and what should I look at first?
Finds the device by hostname, part of a name, MAC or ID; reads its record, hardware, alerts,
patches, software and recent activity; trends disk space and groups repeating alerts.
- `/drmm-device-quick-look NWL-APP01`
- `/drmm-device-quick-look 0A:34:12:5A:16:2F` — by MAC address
- "Why does NWL-APP01 keep alerting?"

### drmm-patch-posture — patch exposure
**Answers:** where are we exposed on patching, and which devices do we fix first?
Reads patch status across servers and workstations, names failing and pending updates, and
flags conditions that will break the next patch cycle (disk full, servicing errors).
- `/drmm-patch-posture` — the whole account
- `/drmm-patch-posture sites "Northwind Legal", "Hillford Freight"`
- `/drmm-patch-posture servers only`

### drmm-stale-and-ghost-devices — inventory clean-up
**Answers:** which device records no longer stand for a real machine, and what do we do with each?
Finds long-offline devices, ghosts (re-imaged or renamed machines left behind, duplicate
enrolments), suspended agents and sites holding only dead records — with an estimate of the
seats involved.
- `/drmm-stale-and-ghost-devices`
- `/drmm-stale-and-ghost-devices stale_days 60 remove_days 180`
- `/drmm-stale-and-ghost-devices seat_price 3 currency EUR` — adds a monthly amount

### drmm-security-coverage-gaps — antivirus and EDR coverage
**Answers:** which endpoints are not protected right now, and which do we fix first?
Vendor-neutral: checks antivirus presence, running state and updates, finds EDR/MDR agents
through device filters, and flags conflicting products. Per-site figures you can hand to a
customer or an insurance questionnaire.
- `/drmm-security-coverage-gaps`
- `/drmm-security-coverage-gaps sites "Northwind Legal"`
- `/drmm-security-coverage-gaps edr_required false`

### drmm-device-timeline — what happened before it broke
**Answers:** what happened to this device, in order, before the problem — and was it us?
Builds one timeline from the activity log (jobs, patches, remote sessions, changes) and alerts,
marks what happened just before the problem, and states timing, never blame. Suggests which
Windows event-log entries a technician should check.
- `/drmm-device-timeline NWL-APP01`
- `/drmm-device-timeline NWL-APP01 anchor "1 Oct 12:08"` — measure from a known moment
- "What changed on NWL-APP01 before it rebooted?"

### drmm-alert-noise-review — alert fatigue
**Answers:** which alerts cost attention without telling us anything, and what do we change?
Groups recent alerts by type and device, scores the noise (self-resolving, flapping, same time
every day, tickets nobody needed, alerts on dead gear) and recommends a specific tuning step —
while protecting alerts that are noisy but real.
- `/drmm-alert-noise-review`
- `/drmm-alert-noise-review days 14`
- `/drmm-alert-noise-review sites "Northwind Legal" min_events 10`

### drmm-software-finder — who has it, which version, is it current?
**Answers:** who has this software installed, which versions, and is any of it a problem?
Groups devices by version and site, rates versions current, behind or end of life against the
vendor's latest release, and can look for shadow IT (remote-control tools, personal VPNs, P2P,
other RMMs) or a whole category.
- `/drmm-software-finder "Google Chrome"`
- `/drmm-software-finder "Google Chrome" version < 122`
- `/drmm-software-finder category browsers` · `/drmm-software-finder shadow-it`
- "Are our browsers up to date at Northwind Legal?"

### drmm-os-lifecycle — unsupported operating systems
**Answers:** which devices run an OS that is out of support, or soon will be — and what first?
Checks every device's OS and build against end-of-life dates looked up live (Windows, Windows
Server, macOS, common Linux, ESXi); marks paid extended updates where possible; servers first.
- `/drmm-os-lifecycle` — the whole account, 12 months ahead
- `/drmm-os-lifecycle horizon_months 6`
- `/drmm-os-lifecycle sites "Northwind Legal" html`

---

## Which skill for which question

| You want to know… | Use |
|---|---|
| Where to start today | `/drmm-morning-pulse` |
| What is wrong with one device | `/drmm-device-quick-look` |
| What changed before a device broke | `/drmm-device-timeline` |
| Patch gaps and failures | `/drmm-patch-posture` |
| Unprotected endpoints | `/drmm-security-coverage-gaps` |
| Old or unsupported operating systems | `/drmm-os-lifecycle` |
| Who has an app, and is it current | `/drmm-software-finder` |
| Dead and duplicate device records | `/drmm-stale-and-ghost-devices` |
| Which alerts to tune | `/drmm-alert-noise-review` |

## Good to know

- **Read-only.** None of the nine skills runs jobs, resolves alerts or edits devices.
- **Offline devices** are reported apart, as "last known".
- **Large accounts:** skills read in pages and say exactly how much they covered; narrow to
  sites for faster runs.
- **Limits** — each skill's known gaps are listed in its readme (`/drmm-<skill> readme`).
- **Feedback** — use the feedback form in the release folder.
