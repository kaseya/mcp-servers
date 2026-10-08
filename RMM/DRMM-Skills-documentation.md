# **DRMM Skills**

Nine ready-made workflows for Claude that read your Datto RMM account and turn it into a short, ranked list of what to do next: which device to look at, which customer needs help first, which records to clean up. 

## Good to know

- **Read-only.** None of the nine skills runs jobs, resolves alerts or edits devices.
- **Offline devices** are reported apart, as "last known".
- **Large accounts:** skills read in pages and say exactly how much they covered; narrow to
  sites for faster runs.
- **Limits** — each skill's known gaps are listed in its readme (`/drmm-<skill> readme`).
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

## Which skill for which question

| You want to know… | Use |
|---|---|
| What is wrong with one device | [drmm-device-quick-look](#device-quick-look) |
| Where to start today | [drmm-morning-pulse](#morning-pulse) |
| Patch gaps and failures | [drmm-patch-posture](#patch-posture) |
| Unprotected endpoints | [drmm-security-coverage-gaps](#security-coverage-gaps) |
| Old or unsupported operating systems | [drmm-os-lifecycle](#os-lifecycle) |
| Who has an app, and is it current | [drmm-software-finder](#software-finder) |
| Dead and duplicate device records | [drmm-stale-and-ghost-devices](#stale-and-ghost-devices) |
| Which alerts to tune | [drmm-alert-noise-review](#alert-noise-review) |
| What changed before a device broke | [drmm-device-timeline](#device-timeline) |

*Not sure where to start?* Try **Morning Pulse** for a whole-account view, or **Device Quick Look** when you have one device in mind. 

---
  
## Device Quick Look

**Overview**

When an alert fires on a server or workstation, the first question is "what is actually wrong, and where do I start?" Answering it usually means opening the device record, alerts, patches and software on separate screens. 

Device Quick Look checks all of that for one device in a single pass and leads with the one thing to look at first, backed by evidence. A healthy device gets a short all-clear, not a spec sheet.

**Read-only** — Device Quick Look never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Opens with a verdict (red, amber, green or offline) and a single "look at first" item, with the reason
- Finds the device from a hostname, part of a name, MAC address, device ID or portal link
- Catches a filling disk early by trending alert history and the hardware audit, so a drive projected to fill within two weeks stands out before it alerts
- Groups repeated alerts, so one that fired 40 times shows as one line
- Labels everything on an offline device as last known, and says "not available" instead of guessing when data is missing

**What to Expect**

1. **Claude finds the device** - Give Claude a hostname, partial name, MAC address, site name, device UID, or a portal URL and it resolves the device automatically. If multiple devices match, it lists the options and asks which to proceed with.
2. **Claude reads and ranks the findings** - Claude pulls the full device record, audit, open alerts, seven days of alert history, installed software, and UDF data, then groups and ranks everything across 3 tiers: stopped or about to stop, degraded, and context worth noting. The top finding becomes the single "look at first" item.
3. **You receive the briefing** - A one-line verdict, the top finding with evidence and a concrete next step, then a full health summary covering patches, antivirus, security agents, IDF data, grouped alert history, and network details. 


**How to Invoke**
```
/drmm-device-quick-look NWL-APP01
/drmm-device-quick-look 0A:34:12:5A:16:2F -- by MAC address
"Why does NWL-APP01 keep alerting?"
```
---

## Morning Pulse

**Overview**
Every morning, an MSP operations team has to figure out the same thing before they can do anything else: what broke overnight, which customers are affected, and where to start. Without a structured view of the whole account, that answer comes from scanning alert queues manually — a process that buries the things that matter under old noise, counts long-dead equipment as urgent, and misses failures that auto-resolved before anyone opened the console.

Morning Pulse reads the entire account and delivers a ranked work plan in under two minutes. It separates what is genuinely new from what has been broken for weeks, identifies the customers who need help first, and surfaces failures that fired and cleared overnight — so your team starts on the right thing, not just the loudest thing.

**Read-only** — Morning Pulse never creates, remediates, or resolves alerts. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Delivers a ranked work plan ordered by customer impact, not alert count or priority label
- Separates new overnight drops from equipment that has been offline for weeks, so long-dead gear never inflates the morning's urgency
- Catches failures that fired and auto-resolved overnight — which typically don't appear in an open alert queue
- Flags servers showing early warning signs — low disk, failing backups, file system corruption — before they become customer outages
- Detects when multiple devices across different sites drop simultaneously, which often points to a shared dependency like a hypervisor
- States plainly when the plan is empty and nothing new broke - a valid and useful answer on a well-run account

**What to Expect**
1. **Claude reads the full account** - Claude pulls every site, device, open alert, and overnight resolved alert in one pass. If the account is too large to run all at once, Claude says so and asks you to narrow the scope.
2. **Claude separates new from noise** - New overnight infrastructure drops (servers, firewalls, switches) are ranked and planned. Devices offline for days or weeks are counted separately. Offline laptops and workstations are never counted as incidents
3. **You receive the briefing** - a one-line verdict, a ranked work plan with site, and time estimate for each item, an overnight patch and job execution summary, and data-quality flags for monitoring gaps and miscategorised devices.

**How to Invoke**
```
/drmm-morning-pulse -- the whole account
/drmm-morning-pulse hours 4 technicians 2 -- a 4-hour plan for 2 technicians
/drmm-morning-pulse for "Northwind Legal" html -- one customer, as a page
```
---

## Patch Posture

**Overview**
Knowing whether your customers are patched is not the same as knowing where you are exposed. A device can show as fully patched on OS updates while its browsers and runtimes are out of date. A device can be fully patched today and still fail its next patch cycle because the Windows component store is corrupted. And on a busy account, the devices that need attention most are not always the ones that appear first in a list.

Patch Posture reads patch status across one or more sites and produces a ranked exposure report. It combines OS patch status with third-party application compliance, finds the conditions that will break the next patch cycle before they do, and puts the devices that need fixing at the top — servers before workstations, failures before warnings, cycle-breaking conditions before ordinary gaps.

**Read-only** — Patch Posture never installs, defers, approves, or retries a patch, and never reboots a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Shows OS patch status and third-party application compliance side by side — a device can be fully patched on Windows and still have out-of-date browsers and runtimes, and the report makes that visible
- Surfaces devices whose next patch cycle will fail before it happens — component store corruption and disk-full patch error codes are both caught and ranked near the top
- Ranks devices by what needs fixing first: servers with active failures, then servers whose next cycle is at risk, then workstations with gaps, then devices with no patch policy at all
- Keeps offline devices in a separate section so they never inflate or deflate a site's figures
- Gives a clear site-level summary — how many devices are fully patched, how many have approved patches pending, how many are waiting on a reboot — so you can see a customer's posture at a glance

**What to Expect**
1. **You name the sites to cover** - Patch Posture works site by site. If you ask for the full account, Claude lists all sites with device counts and asks which to include.
2. **Claude reads and ranks every device** - Claude pulls the full patch record, third-party software compliance, reboot state, and recent patch failure alerts for every server, desktop, and laptop at the chosen sites, then ranks by worst condition: active failures first, cycle-breaking conditions next, then pending patches and out-of-date applications.
3. **You receive the report** - A one-line verdict (RED / AMBER / GREEN), a ranked fix-first list of up to ten devices with the specific reason and evidence for each, a site-by-site patched and pending summary, and an offline device section.

**How to Invoke**
```
/drmm-patch-posture — the whole account
/drmm-patch-posture sites "Northwind Legal", "Hillford Freight"`
/drmm-patch-posture servers only
```
---

## Security Coverage Gaps

**Overview**

When a customer, auditor or cyber-insurer asks whether every endpoint is protected, the answer is usually scattered across antivirus consoles, device lists and spreadsheets — and it rarely looks the same for two customers. Gaps hide where nobody checks: a server whose antivirus stopped months ago, or a laptop with no EDR agent.

Security Coverage Gaps checks every server, desktop and laptop on two separate layers — antivirus (installed, running and up to date) and EDR/MDR (a detection agent is present) — and puts the endpoints that need fixing first, servers before workstations. It is vendor-neutral: it judges capability, not brand, so a Datto, Microsoft, CrowdStrike, Sophos or any other product scores the same for the same state.

**Read-only** — Security Coverage Gaps never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Keeps antivirus and EDR separate, so you can see which layer is missing instead of one blended score that hides it
- Finds endpoints with no protection, antivirus that is stopped or out of date, no EDR, or conflicting security products
- Recognises around 40 security vendors, treats them all the same, and never recommends replacing a product
- Produces per-site coverage figures you can reuse in a customer review or insurance questionnaire once you have checked them
- Can also count devices that run none of your own standard products
- Keeps offline devices apart as last-known, so they never drag a site's percentages down

**What to Expect**
1. **Claude reads your endpoints** - Claude reads the antivirus product and status that Datto RMM records on every server, desktop and laptop, and uses the device filters already in your account to find EDR or MDR agents. Where data is missing, it spot-checks software lists.
2. **Claude ranks the gaps** - Servers with no running antivirus always come first. "No EDR found" means no evidence in your filters and software lists, not proof that none is installed.
3. **You receive the report** - A one-line verdict (RED / AMBER / GREEN), a fix-first list, a protection-by-site table, and extras such as conflicts, out-of-date antivirus and the products seen. Firewall, BitLocker and MFA are not checked.

**How to Invoke**
```
/drmm-security-coverage-gaps
/drmm-security-coverage-gaps sites "Northwind Legal"
/drmm-security-coverage-gaps edr_required false
```
---
  
## OS Lifecycle 

**Overview**

Datto RMM records each device's operating system and version, but not whether the vendor still provides security updates for it. Finding out means checking release calendars for every operating system in the fleet, and old servers are easy to forget until an audit or an incident.

OS Lifecycle checks every device against end-of-life dates looked up live at run time, then ranks what to upgrade, replace or retire, servers first. It covers Windows, Windows Server, macOS, common Linux releases and ESXi.

**Read-only** — OS lifecycle never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Separates devices that are already out of support from those ending within the next 12 months (adjustable)
- Marks devices that may still receive paid Extended Security Updates (ESU) and says "ESU status not visible" instead of calling them unprotected, because Datto RMM can't see whether a customer bought ESU
- Uses end-of-life dates looked up live, never dates from memory — and never sends your device, site or customer data in the lookup
- Gives a per-site table of current devices, devices out of support and devices ending soon
- Keeps long-offline devices apart as last-known, so they never raise the verdict

**What to Expect**
1. **Claude reads your device list** - Claude reads each device's operating system and build, then looks up end-of-life dates for each OS family it finds. Web search needs to be on; without it, Claude falls back to a dated snapshot and says so in the report.
2. **Claude classifies every device** - Each device is marked supported, ending soon or out of support. An OS it can't place is listed as "not on the lifecycle list", never guessed.
3. **You receive the report** - A one-line verdict (RED / AMBER / GREEN), an action list (upgrade, replace, retire or confirm ESU) with where to start, tables of out-of-support and ending-soon releases, and a by-site summary. It does not check whether a device can run the next Windows version, and phones and tablets are out of scope.

**How to Invoke**
```
/drmm-os-lifecycle` — the whole account, 12 months ahead
/drmm-os-lifecycle horizon_months 6
/drmm-os-lifecycle sites "Northwind Legal" html
```
---

## Software Finder

**Overview**

"Who has Chrome, and which version?" or "Has anyone installed TeamViewer?" sounds simple, but Datto RMM has no single account-wide software search, so the answer usually means opening devices one by one — and old versions and unapproved tools go unnoticed.

Software Finder answers who has an application installed, which versions are out there and whether any of it is a problem. It can find one product, sweep a whole category (browsers, AI tools, remote-access tools), look for shadow IT, or check whether apps are up to date.

**Read-only** — Software Finder never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
-  Leads with the count and version spread, then names the devices that matter — oldest versions, servers, anything unexpected. A full device list is available on request
- Category mode covers browsers, AI tools, remote-access tools, other RMMs, personal VPNs, file-sharing and more
- Shadow-IT mode flags unsanctioned tools, and you can add your own watch list of banned software. Datto's own agent and Splashtop Streamer are never flagged
- Currency mode rates versions as current, behind or out of support against the vendor's latest release, looked up live
- Honest about coverage: a sample is labelled as a sample, and "not found" is only said after the whole scope was read

**What to Expect**
1.  **Claude picks the fastest route** - It uses a matching device filter in your account when there is one (quick, with a true total). Otherwise it reads software lists device by device within a limit, and asks which sites to cover first on large accounts.
2. **Claude matches and groups** - Names and versions are grouped by version and site. Apps installed for a single user (often Zoom, Teams, browsers, remote-access and AI tools) don't appear in Datto RMM's software audit, so they can't be found.
3. **You receive the report** - A one-line verdict (ACTION / REVIEW / INFO), a what-to-do list, a version table, the devices that matter, and a by-site breakdown. Currency mode and end-of-life checks need web search to be on.

**How to Invoke**
```
/drmm-software-finder "Google Chrome"
/drmm-software-finder "Google Chrome" version < 122
/drmm-software-finder category browser
/drmm-software-finder shadow-it
"Are our browsers up to date at Northwind Legal?"
```
---

## Stale and Ghost Devices

**Overview**

Over time every RMM account collects records for machines that no longer exist — retired laptops, PCs that were re-imaged and enrolled again under a new record, suspended agents. They clutter the console, hide real problems and can inflate the agent seats you pay for. The risk in cleaning up is deleting a server that is only switched off for the weekend.

Stale and Ghost Devices puts every old record in one of three buckets — remove, investigate or leave — with the evidence for each, and estimates the agent seats involved.

**Read-only** — Stale and Ghost Devices never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Gives an action list, not a dump of offline devices
- Finds ghosts: a re-imaged or renamed machine matched to its live twin by hardware identity
- Sets a higher bar for servers — they go to "investigate" first, and are only marked for removal after 180 days offline and a check that nothing on them is still reporting
- Shows sites that hold only dead records as one line each, not hundreds of rows
- Estimates the agent seats at stake, and a monthly amount if you give a seat price and currency
- Includes an early-warning count of devices offline for over a week but not yet stale

**What to Expect**
1.  **Claude counts the account** - It uses your account's built-in filters (offline over a week, offline over 30 days, suspended) to count account-wide quickly, then looks closer at candidates by hostname, MAC address and last-seen date.
2. **Claude sorts every record** - Each record lands in remove, investigate or leave. By default a workstation offline over 90 days with no live twin can be marked for removal, and so can a duplicate or re-imaged record.
3. **You receive the report** - A one-line verdict (RED / AMBER / GREEN), a what-to-do list, tables of records to remove and investigate, ghosts, dead sites and the seats at stake. Claude never removes anything: deleting a record is done by a person in the Datto RMM portal, and it is worth confirming the device is not still listed in your PSA or documentation first.

**How to Invoke**
```
/drmm-stale-and-ghost-devices
/drmm-stale-and-ghost-devices stale_days 60 remove_days 180
/drmm-stale-and-ghost-devices seat_price 3 currency EUR —- adds a monthly amount
```
---

## Alert Noise Review

**Overview**

When some alerts fire constantly, technicians learn to ignore them — until a real one gets lost among them. Working out which monitors to tune normally means a lot of manual counting, and the risk is silencing something that matters.

Alert Noise Review reads recent alerts (the last 7 days by default), groups them into patterns, measures how each one behaves and recommends a specific tuning change: raise a threshold, add a duration, move a schedule, stop ticket creation, or take a policy off retired gear.

**Read-only** — Alert Noise Review never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
-  Gives a ranked "tune first" list, each item naming the change to make and roughly how many alerts a week it would remove
- Shows a transparent noise score for every pattern, with the two biggest reasons behind it
- Protects alerts that are noisy but real: a disk that keeps filling is an unfixed problem, so it gets its own section and is never recommended for silencing
- Shows ticket burden — tickets opened by alerts that cleared themselves, with an estimate of the hours spent
- Spots alerts firing on retired gear and alerts that are muted

**What to Expect**
1. **Claude reads recent alerts** - Open and resolved alerts for the account or the sites you choose. A 14 or 30-day window gives better time-of-day evidence but takes longer. On a very busy account only part of the window may be covered, and the report says how much it read.
2. **Claude groups and scores them** - Alerts are grouped into patterns and measured on volume, how often and how fast they clear, flapping, firing at the same time every day, tickets nobody needed, and alerts on dead devices.
3. **You receive the report** - A one-line verdict (NOISY / SOME NOISE / CLEAN), the tune-first list, a noisy-but-real section, what else was found, and a by-site table. Claude can't change monitoring policies itself: each recommendation names the monitor and setting for someone to change in Datto RMM.

**How to Invoke**
```
/drmm-alert-noise-review
/drmm-alert-noise-review days 14
/drmm-alert-noise-review sites "Northwind Legal" min_events 10
```
---

## Device Timeline 

**Overview**

After something breaks, the first question is "what changed, and was it us?" The answer is spread across the Datto RMM activity log and the alert history, and piecing it together under pressure is slow.

Device Timeline builds one time-ordered view for a single device — jobs and components run, patch actions, remote sessions, policy and device changes — mixed with the alerts raised and resolved, then marks what happened just before the problem.

**Read-only** — Device Timeline never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Answers "was it us?" with named evidence — or says "cannot tell"
- States timing, never blame: "a patch job finished 14 minutes before the first shutdown alert", not "the patch caused the crash"
- Treats "nothing preceded it" as a valid answer — it points away from RMM activity and toward the customer, hardware or an outside change
- Suggests which Windows event-log entries a technician should check for reboots, crashes and local installs
- Never reports a partly unreadable activity log as "nothing happened"

**What to Expect**
1. **Claude finds the device** - It reads the device's activity log and alerts for the window (the last 72 hours by default). You can name the moment the problem started and it measures from there.
2. **Claude merges and marks** - Everything is put in time order, and events in the 24 hours before that moment are marked. Windows' own event log is not read; Claude only suggests what to check.
3. **You receive the report** - A one-line answer, a table of what came before the problem, the full timeline (newest first) and counts by category. The activity log isn't available on every account; if it can't be read, the report says so and relies on alerts alone.

**How to Invoke**
```
/drmm-device-timeline NWL-APP01
/drmm-device-timeline NWL-APP01 anchor "1 Oct 12:08" -- measure from a known moment
"What changed on NWL-APP01 before it rebooted?"
```
---
