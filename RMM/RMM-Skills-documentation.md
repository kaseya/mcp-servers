# RMM SKills
### Device Quick Look 

**Overview**

When an alert fires on a device, a technician needs to know one thing immediately: what is wrong with it and where to start. Getting that answer today usually means opening the device in the RMM console, checking the alert details, cross-referencing the audit, scanning the history, and piecing it together from several places. Under pressure, steps get skipped.

Kaseya has built a skill that pulls everything about one device in a single pass and leads with exactly what the technician needs to look at first. Alert history, hardware audit, patch status, installed software, antivirus, component results, and anything stored in UDF fields — all read, grouped, and ranked into a structured view. A device with nothing wrong gets a short answer. A device with a problem gets a clear finding, backed by evidence, with the next step named.

Read-only — Device Quick Look never remediates, moves, or modifies a device, and never resolves or mutes an alert.

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Leads with one "look at first" item backed by evidence — not a spec sheet
- Finds the device from a hostname, partial name, MAC address, site name, device UID, or portal URL
- Catches falling disk space by trending across alert history and the hardware audit, not just the current reading — a volume that looks borderline today may already be projected to fill within two weeks
- Groups duplicate and recurring alerts so a device that fired the same alert 40 times shows as one line, not 40 rows
- Surfaces component results stored in UDF fields — the backup check, encryption status, disk health, and other data that scripts write back to the device after each run — and redacts secrets like product keys and BitLocker recovery keys before they appear in any output
- Labels everything on an offline device as last-known, so stale data is never presented as current state

**What to Expect**

**Step 1: Claude finds the device** *(no input required)*

Give Claude a hostname, part of a name, a MAC address, a device UID, or a portal URL and it resolves the device automatically. If more than one device matches — the same hostname at two different sites, for example — Claude lists the options and asks which one to look at. It takes one device per run; if you name several, it asks which to start with.

**Step 2: Claude reads everything about it** *(no input required)*

Once the device is found, Claude pulls the full device record, hardware audit, open alerts, seven days of resolved alert history, installed software list, and any component results stored in UDF fields. On an offline device, every section is clearly labelled as last-known data with the date it was recorded.

**Step 3: Claude groups and ranks the findings** 

Raw alert rows are never listed. Claude groups alerts by signature — the same event raised multiple times becomes one entry showing the count and the date range. It then ranks every finding across three tiers: things that mean the device has stopped or is about to (critical disk, backup failure, file system corruption), things that mean it is degraded (reboot pending, antivirus not running, patch failures, recurring shutdowns), and context worth noting (a second RMM agent installed, stale open alerts, housekeeping items). The highest-ranked finding becomes the "look at first" item. A device with nothing wrong gets a short GREEN answer — it never reads as if there is a problem when there isn't one.

**Step 4: You receive the briefing** 

The output names the verdict in one line, then the look-at-first item with its evidence and a concrete starting point, followed by the health summary, patch and antivirus status, security and backup agents detected in the software list, component data from UDF fields, grouped alert history, network details, and a coverage footer. Where a finding belongs to a deeper follow-up — patch posture for a site, disk triage for a cleanup — the output names the skill to go to next.

**How to Invoke**
```
"Quick look at SERVER-01"
"What's going on with DESKTOP-ABC123?"
"Why did this device alert?"
"Is LAPTOP-XYZ healthy?"
"Deep dive on the device at Acme Corp named FILESERVER-02"
/device-quick-look
```

### Morning Pulse 

**Overview**
Every morning, an MSP operations team has to figure out the same thing before they can do anything else: what broke overnight, which customers are affected, and where to start. Without a structured view of the whole account, that answer comes from scanning alert queues manually — a process that buries the things that matter under old noise, counts long-dead equipment as urgent, and misses failures that auto-resolved before anyone opened the console.

Kaseya has built a skill that reads the entire account and delivers a ranked work plan in under two minutes. It separates what is genuinely new from what has been broken for weeks, identifies the customers who need help first, and surfaces failures that fired and cleared overnight — so your team starts on the right thing, not just the loudest thing.

Read-only — Morning Pulse never creates tickets, remediates devices, or resolves alerts.

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Delivers a ranked work plan for the first hours of the day, ordered by customer impact — not alert count or priority label
- Separates new overnight drops from equipment that has been offline for weeks, so long-dead gear never inflates the morning's urgency
- Catches failures that fired and auto-resolved overnight — the kind that never appear in an open alert queue but can be the most critical finding of the day
- Flags servers that are about to fail — low disk, failing backups, file system corruption — before they become customer outages
- Detects when multiple devices at different sites went offline at the same time, which often points to a shared dependency like a hypervisor
- States plainly when the plan is empty and nothing new broke, which is a valid and useful answer on a well-run account

**What to Expect**

**Step 1: Claude reads the full account** *(no input required)*

Claude pulls every site, every device, all open alerts, and overnight resolved alerts in one pass. It uses your account's timezone throughout. If the total device count would make the run impractical, Claude tells you how large the account is and asks you to narrow the scope before starting. On a typical account this takes roughly ten calls.

**Step 2: Claude separates what is news from what is not** 

Not everything offline is a problem that needs action today. Claude distinguishes new overnight drops from devices that have been offline for days or weeks. Only new infrastructure drops — servers, firewalls, switches — affect the morning's verdict and plan. Offline laptops and workstations are never counted as incidents. Long-term offline gear is counted and handed off separately, so it does not crowd out what actually broke last night.

**Step 3: Claude builds the ranked work plan** 

Claude ranks every finding by customer impact. Sites that are completely down come first. Servers showing early warning signs — disk nearly full, backups not running, file system corruption, AD replication failing — come next, because these are the problems that become outages if they're not caught today. Site outages, isolated new drops, and other degraded conditions follow. Each plan item includes the site, the specific thing to look at, why it ranks where it does, whether a ticket exists, and a rough time estimate so you can see how much the morning holds.

**Step 4: You receive the briefing** 

The output is a plain-language briefing: a one-line verdict, the ranked work plan for your team's available hours, a count of what didn't make the plan and why, the overnight execution summary showing patch and job failures, and a section of data-quality flags for things like monitoring gaps and mis-categorised devices. If nothing qualifies for the plan, it says so in one line — it never promotes old problems to fill space.

**How to Invoke**
```
"Morning briefing"
"What broke overnight?"
"Where should the team start today?"
"Which customers are worst affected right now?"
/morning-pulse
```

### Patch Posture 

**Overview**
Knowing whether your customers are patched is not the same as knowing where you are exposed. A device can show as fully patched on OS updates while its browsers and runtimes are out of date. A device can be fully patched today and still fail its next patch cycle because the Windows component store is corrupted. And on a busy account, the devices that need attention most are not always the ones that appear first in a list.

Kaseya has built a skill that reads patch status across one or more sites and produces a ranked exposure report. It combines OS patch status with third-party application compliance, finds the conditions that will break the next patch cycle before they do, and puts the devices that need fixing at the top — servers before workstations, failures before warnings, cycle-breaking conditions before ordinary gaps.

Read-only — Patch Posture never installs, defers, approves, or retries a patch, and never reboots a device.

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Shows OS patch status and third-party application compliance side by side — a device can be fully patched on Windows and still have out-of-date browsers and runtimes, and the report makes that visible
- Surfaces devices whose next patch cycle will fail before it happens — component store corruption and disk-full patch error codes are both caught and ranked near the top
- Ranks devices by what needs fixing first: servers with active failures, then servers whose next cycle is at risk, then workstations with gaps, then devices with no patch policy at all
- Keeps offline devices in a separate section so they never inflate or deflate a site's figures
- Gives a clear site-level summary — how many devices are fully patched, how many have approved patches pending, how many are waiting on a reboot — so you can see a customer's posture at a glance

**What to Expect**

**Step 1: You name the sites to cover**

Patch status requires one API call per device, so Patch Posture works site by site rather than sweeping the whole account at once. If you ask for the full account without naming sites, Claude explains why it needs you to choose, lists all sites with their device counts, and asks which to include. If the chosen sites together contain more devices than the run budget, Claude tells you the total and asks you to narrow the list before starting.

**Step 2: Claude reads every device at those sites** *(no input required)*

For each site, Claude reads every server, desktop, and laptop — skipping ESXi hosts, Datto appliances, access points, and switches, which are out of scope. For each device, it reads the full patch record, third-party software compliance status, reboot state, and open and recent alerts. It checks for patch failure alerts in the last seven days and looks for the specific error codes and event log entries that indicate the next patch cycle is at risk.

**Step 3: Claude ranks the exposure** 

Devices are ranked by the worst condition on each one. A server with an active patch failure sits at the top. Below it, servers whose component store is corrupted or whose last failure was a disk-full error — meaning the next patch attempt will fail for the same reason. Below that, devices with approved patches pending, pending reboots, or out-of-date third-party applications. Devices with no patch policy at all are called out separately. Offline devices are never ranked and never counted in the site totals; they get their own section showing what was last known about them.

**Step 4: You receive the report** 

The output opens with a one-line verdict — RED if any server has an active failure or a cycle-breaking condition, AMBER for other gaps, GREEN if nothing needs attention. The ranked "fix first" list follows, with up to ten entries each showing the specific reason, the evidence, and a pointer to Device Quick Look for a deeper look at that device. A site-by-site summary gives the patched and compliant counts for each location. The report closes with offline devices, data-quality flags, and a coverage footer that states clearly that this is a point-in-time reading with no patch history.

**How to Invoke**
```
"Patch posture for Acme Corp"
"Are all devices at Contoso patched?"
"Which sites have missing or failed patches?"
"Show me patch compliance for Site A and Site B"
/patch-posture
```
