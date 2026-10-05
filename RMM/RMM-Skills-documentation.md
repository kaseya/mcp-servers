# **RMM Skills**
## **Device Quick Look** 

**Overview**

When an alert fires on a device, a technician needs to know what went wrong and where to start. Getting that answer today usually means piecing it together from several places. Under pressure, steps get skipped.

Device Quick Look pulls everything about one device in a single pass — alert history, hardware audit, patch status, installed software, antivirus, and UDF field data — then leads with exactly what to look at first. A device with nothing wrong gets a short answer. A device with a problem gets a clear finding, backed by evidence, with the next step named.

**Read-only** — Device Quick Look never remediates, moves, or modifies a device. This is a read-only skill. 

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](README.md#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Leads with prioritized findings - backed by evidence, not a raw spec sheet
- Finds the device from a hostname, partial name, MAC address, site name, device UID, or portal URL
- Catches falling disk space by trending across alert history and the hardware audit, not just the current reading — highlighting a volume that looks borderline today may already be projected to fill within two weeks
- Groups duplicate and recurring alerts so a device that fired the same alert 40 times shows as one line, not 40 rows
- Surfaces component results stored in UDF fields — the backup check, encryption status, disk health, and other data that scripts write back to the device after each run — and redacts secrets like product and recovery keys in any output
- Labels everything on an offline device as last-known, so stale data is never presented as current state

**What to Expect**

1. **Claude finds the device** - Give Claude a hostname, partial name, MAC address, site name, device UID, or a portal URL and it resolves the device automatically. If multiple devices match, it lists the options and asks which to proceed with.
2. **Claude reads and ranks the findings** - Claude pulls the full device record, audit, open alerts, seven days of alert history, installed software, and UDF data, then groups and ranks everything across 3 tiers: stopped or about to stop, degraded, and context worth noting. The top finding becomes the single "look at first" item.
3. **You receive the briefing** - A one-line verdict, the top finding with evidence and a concrete next step, then a full health summary covering patches, antivirus, security agents, IDF data, grouped alert history, and network details. 


**How to Invoke**
```
"Quick look at SERVER-01"
"What's going on with DESKTOP-ABC123?"
"Why did this device alert?"
"Is LAPTOP-XYZ healthy?"
"Deep dive on the device at Acme Corp named FILESERVER-02"
/device-quick-look
```
---

## **Morning Pulse** 

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
"Morning briefing"
"What broke overnight?"
"Where should the team start today?"
"Which customers are worst affected right now?"
/morning-pulse
```
---

## **Patch Posture** 

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
"Patch posture for Acme Corp"
"Are all devices at Contoso patched?"
"Which sites have missing or failed patches?"
"Show me patch compliance for Site A and Site B"
/patch-posture
```
