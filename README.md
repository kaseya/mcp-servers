# Kaseya MCP Readme

**The official Kaseya Model Context Protocol (MCP) servers, tools, skills and other automation scripts library, for Kaseya community of MSP and IT operation builders.**

## Overview
This repo provides MCP servers for Kaseya products for Claude Code, Claude Desktop, Microsoft CoPilot Cowork and other MCP compatible clients. It also provides skills and other autmoation libraries Kaseya users can try and contribute to. 

Here is where patterns get proven, guardrails get built, and collective expertise becomes available to every member who needs it.

---
### What We Share

- **MCP servers** - integrations with tools like Datto RMM, Autotask, and IT Glue
- **Skills** - reusable Claude Code skills for IT ops workflows


---
### Who This Is For

- MSP technicians and engineers
- IT operations builders at internal IT departments
- Tool vendors building integrations

---

### Community Channels

| Channel | Link |
|---|---|
| Discord | You will receive a discord link during kickoff |
| Office Hours | Daily - see Discord for schedule |
| Community Calls | Bi-weekly — see Discord for schedule |

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Supported Clients](#supported-clients)
3. [Supported Products and Tools](#supported-products-and-tools)
4. [Example Tools & Skills](#example-tools--skills)
5. [Skills](#skills)
6. [Community and Support](#community-and-support)
7. [Security](SECURITY.md)
8. [Code of Conduct](CODE_OF_CONDUCT.md)
9. [Contributing](CONTRIBUTING.md)
10. [Disclaimer](#disclaimer)

---

## Getting Started
1. Browse the repo for skills, MCPs, and runbooks relevant to your stack.
2. Learn how to contribute to this community — see [Contributing](CONTRIBUTING.md).
3. Follow the steps below to set up your MCP servers and install skills into Claude.

### Connecting to MCP Servers: Prerequisites
#### Prerequisite 1: Node.js

MCP Server connections powering the skills require a runtime environment outside of Claude. Without one, the connection will fail with no error message. Follow the below steps to download Node.js to your system:
  1. Navigate to [Nodejs.org](https://nodejs.org/en/download) *(or other compatible service)*
  2. Download and install compatible Node.js package for your device.
  3. After installing, restart your Claude before proceeding. Claude Desktop reads configuration files upon start up, so a restart forces Claude to reload its environment from scratch, at which point it can see Node.js and use it to run the MCP bridge programs. No more silent failures.

#### Prerequisite 2: API credentials
Before connecting to MCP Servers, you will need generate credentials for each platform. **Have all values on hand before proceeding** to the next steps:

| Product | Values Needed | How to Generate Secret Keys |
|---|---|---|
| **Datto RMM** | API Key, API Secret | [Generate API Key + Secret](GENERATING-API-KEYS.md#datto-rmm) |
| **IT Glue** | API Key | [Generate API Key](GENERATING-API-KEYS.md#it-glue) |
| **Autotask** | Username, secret, integration code (aka tracking identifier) | [Generate username, secret, and integration code](GENERATING-API-KEYS.md#autotask) |

> [!TIP]
> **Do not share keys and use minimally scoped permissions for each use case and user.**

---

### Step 1: Connecting to MCP Servers -- Using Claude Desktop
#### 1.1 Download the mcpb file for each product whose MCP server you are wanting to connect to, located in this repo. 

There will be one file per product MCP server connection you are setting up (3 total if you are wanting to connect Datto RMM, AUtotask, and IT Glue).
You can download these files here. 

#### 1.2 Open the Developer Settings in Claude Desktop

Open **Claude Desktop** and click your profile icon in the bottom-left corner to open the account menu, then select **Settings**.

<img width="188" height="192" alt="README1" src="https://github.com/user-attachments/assets/6fd4852c-43fa-4471-bc53-6e4b97fe7f70" />

In the settings panel, select **Extensions** from the left sidebar. 

<img width="624" height="417" alt="README16" src="https://github.com/user-attachments/assets/31b067d0-5cfc-4b09-af18-573309bc843a" />

Drag your mcpb files downloaded and drag them into the extensions screen. Follow steps to install the file. 

<img width="624" height="602" alt="ReadMe17" src="https://github.com/user-attachments/assets/30073d39-d12f-4484-8569-3b1543d8786e" />

Once installed, you will see a pop up asking for your. These are the values we generated in the pre-requisite steps. See Generating_API_Keys for more information on how to get these values. Ensure you are using your correct product keys for this steps of implementation. 

<img width="341" height="404" alt="README18" src="https://github.com/user-attachments/assets/941635eb-6e07-4cb8-a28c-3ef2ee48f928" />

Save and close. 

<img width="624" height="462" alt="README19" src="https://github.com/user-attachments/assets/32a6fa02-2fb0-4a12-abd1-86dc321aa909" />

You should then see the package successfully installed into your Claude environment. 


### Step 2: Using the Skills

Once configured, just talk to Claude naturally or use slash commands in the chat window to run the skills.

#### Example Natural language requests:

```
morning briefing for Acme Corp
onboard DESKTOP-ABC123 at Acme Corp
```

#### For Slash commands, enter the name of the skill you want to invoke:

```
/datto-device-health-briefing
/device-onboarding
```

---

## Supported Clients

| Client | Supported |
|---|---|
| Claude Desktop | ✅ |
| Claude Code | ✅ |

---

## Supported Products and Tools

| Product | What the Skills Can Do |
|---|---|
| **Datto RMM** | Run components and scripts, triage alerts, check device health, audit hardware |
| **IT Glue** | Create and update configuration records, document devices, log triage notes |
| **Autotask** | Read and update tickets, post notes, provide ticket briefings |

---

## Example Tools & Skills

Skills in the Kaseya community come in three levels of complexity, and they work together.

- **Tools** do one specific thing — read a ticket, check if a device is online, post a note, run a script. Simple, fast, and useful on their own.

- **Skills** are complete workflows. They string tools together in the right order to handle an entire process from first look to final documentation — with you approving the key steps along the way.

Any Tool or Skill can also be run on its own, outside of a workflow, whenever you need it. 

Here is some guidance on approach as you explore tools and skills with MCP servers:
1. Simple query tools (read)
2. Simple update tools (write, with guardrails)
3. Simple skills as workflows

## Common MSP Tools
### Autotask

| Tool | Operation | Description |
|---|---|---|
| **Search Entries** | Read | Finds the Autotask entity name that matches a plain-language description.|
| **Describe Entity** | Read | Returns the live field schema: field names, data types, flags, picklist values, and supported operators.|
| **Query Entity** | Read | Queries an entity with filters, one “anyOf” group, fields, and limit. Returns rows in id order, with a nextPage hint.|
| **Count Entities** | Read | Counts rows matching the filters, without fetching them.|
| **Get Entity** | Read | Gets one row by numeric id. Returns found: false if no row has that id.|
| **Search Tickets** | Read | Searches tickets by company, status, title, assignment, and date. No query DSL needed. Defaults to open tickets.|
| **Get Ticket** | Read | Gets one ticket by id, with full detail in ticket vocabulary. |
| **Create Entity** | Write | Creates a row, reads it back, and returns it enriched. Do not resend the create to check whether it worked.|
| **Update Entity** | Write | Updates one row by id, reads it back, and returns it enriched.|
| **Delete Entity** | Write | Permanently deletes one row. Only working rows and link rows accept a delete — business records never do.|
| **Add Ticket Note** | Write | Adds a note to an existing ticket. Returns the note, read back and enriched.|

### Datto RMM

| Tool | Operation | Description |
|---|---|---|
| **A** | TBD | TBD |
| **B** | TBD | TBD |
| **C** | TBD | TBD |
| **D** | TBD | TBD |
| **E** | TBD | TBD |
| **F** | TBD | TBD |

### IT Glue

| Tool | Operation | Description |
|---|---|---|
| **index_organizations** | Read | TBD |
| **get_organization** | Read | TBD |
| **search_configurations** | Read | TBD |
| **get_configuration** | Read | TBD |
| **search_locations** | Read | TBD |
| **get_location** | Read | TBD |
| **search_documents** | Read | TBD |
| **get_document** | Read | TBD |
| **search_flexible_assets** | Read | TBD |
| **search_passwords** | Read | TBD |
| **list_document_folders** | Read | TBD |
| **create_document** | Write | TBD |
| **update_document_secret** | Write | TBD |
| **create_document_image** | Write | TBD |
| **create_attachment** | Write | TBD |
---

## Skills

Kaseya has developed nine skills for Claude Desktop that automate Datto RMM, IT Glue, and Autotask workflows -- no coding required. This guide walks through the skills and what you can expect when using the skills so your team can start saving time immediately. **All 9 complex skills are included when you install the Kaseya plug in library.**

| Skill | What It Automates |
|---|---|
| autotask-briefing | Assembles a complete briefing on one Autotask record and everything attached to it. Use this skill to understand, summarise, or get context on a ticket, company, contact, or device. |
| autotask-guarded-changes| Controls every change to Autotask data. Reads the record first, proposes the change for the user to confirm, then sends each write once and reports what Autotask holds after. |
| morning-pulse | TBD |
| device-quick-look | TBD |
| Patch-Posture | TBD |
| search-ITGlue-documents | TBD |
| update-ITGlue-documents | TBD |
| create-ITGlue-documents | TBD |
| Document Summary | TBD |


### Autotask Context ([device-onboarding](skills/device-onboarding))

**Overview**

Before a technician works a ticket or an account manager jumps on a customer call, they typically have to open multiple tabs to get a full view of what is happening — pulling up the ticket, checking the contact, reviewing contracts, scanning note history. That's five minutes of setup before any real work begins, and it's easy to miss something logged in a different place.

This skill assembles the complete picture in one step, pulling everything attached to the record you name — ticket, company, contact, or device — and delivering it as a single structured briefing. When you only need one part of a ticket, such as its checklist or the other people and devices on it, it answers that question on its own without building the full briefing.

  *Before using this skill, make sure your MCP servers are connected and the skills are installed. See the [Getting Started](#getting-started) section of this README for setup instructions.*

**Benefits**
- Covers all four record types: tickets, companies, contacts, and devices
- Automatically searches across related notes, history, time entries, contracts, checklists, and linked contacts and devices
- Answers focused questions — "what's left on the checklist?", "who else is on this ticket?" — quickly, without pulling the whole record
- States clearly when a section has no data, so nothing looks like it was skipped
- Collapses automated workflow notes into a single count, so the human-written notes stand out
- Presents information the way a colleague would hand over work — what to act on first, not the order the data arrived

**What to Expect**
1. Claude finds the record you named and resolves it to a single match — if more than one comes back, it lists the options and asks you to confirm before going further. If nothing matches, it says so and stops
2. Claude decides how much to gather: a question about a ticket's checklist or its linked contacts and devices gets a focused answer; anything else gets the full briefing
3. Claude fans out to everything attached: notes, history, time entries, contracts, the linked device, checklist items, and any additional contacts and devices on the ticket — collecting up to 25 notes and history entries by default, with more available on request
4. A structured briefing is delivered for the record type you asked about, sorted chronologically, with every section included — even when there's nothing to report, Claude says so plainly


**How to Invoke**
```
"Brief me on ticket 12345"
"Give me everything on T20260918.0001"
"catch me up on this ticket"
"What do I need to know before working this ticket"
"What's left on the checklist for 12345"
"Which checklist items are still open"
"Who else is on this ticket"
"Which devices are linked to this ticket"
"Tell me about Acme Corp"
"Who is jane@acme.com and what are they waiting on?"
"What's the history on this laptop"
/autotask-briefing
```

### Autotask Guarded Changes ([device-onboarding](skills/device-onboarding))

**Overview**

Every update to an Autotask ticket can be time consuming, or simply a step that may get missed due to human error.

This skill governs every change to Autotask through Claude — creating, updating, or deleting records — by reading the current record first, showing you exactly what will change, and waiting for your confirmation before anything is written. It covers tickets, notes, time entries, contacts, checklist items and checklist libraries, and the additional contacts and devices linked to a ticket.

    *Before using this skill, make sure your MCP servers are connected and the skills are installed. See the [Getting Started](#getting-started) section of this README for setup instructions.*


**Benefits**
- Shows you the current value and the new value side by side before any change is made — no surprises
- Confirms that a field actually needs updating before writing it; if it already holds the right value, Claude says so and makes no change
- Checks Autotask's limits and ownership rules up front — such as the maximum number of checklist items or linked contacts on a ticket — so you hear about a problem before the write, not after a refusal
- Handles batches, like "mark items 2, 4, and 5 done", with a single confirmation, then sends each change one at a time and stops at the first failure
- Never retries a failed write, eliminating the risk of duplicate records, duplicated checklist items, or a locked-out API user
- Reports what Autotask actually saved after each write, not just what was sent

**What to Expect**
1. Claude fetches the current record so the proposal shows exactly what will change — for a checklist or a ticket's linked contacts and devices, it reads the full list. If the field already holds the right value, it says so and stops
2. Claude checks the change against Autotask's limits and ownership rules, and looks up the correct values for any dropdown field
3. A one-line-per-field summary is presented — entity, ID, field, old value, new value — or, for a delete, the record that will be removed. Downstream effects such as SLA timers, workflow rules, and notifications are called out for any status change. Claude waits for your confirmation before proceeding
4. Each write is made once. Claude reports what Autotask returned, not what was sent; for a batch, it tells you which changes landed, which failed, and which were never sent. For checklists and linked records, it re-reads the list, since one change can shift others
5. If a write fails, Claude reports it, reads the record back to show what it now holds, and stops — no retries, no workarounds. If Autotask rejects the credentials, Claude stops immediately to avoid locking out the API user
6. If your deployment is configured as read-only, Claude tells you so rather than looking for another way to make the change

**How to Invoke**
```
"Update ticket 12345"
"set this ticket to In Progress"
"Reassign this ticket to Dana"
"change the priority"
"Add a note to the ticket"
"Log 2 hours against this ticket"
"Create a ticket for Acme Corp"
"Mark checklist item 3 done"
"Apply the onboarding checklist"
"Add Jane to this ticket"
"Link this laptop to the ticket"
"Unlink that laptop from the ticket"
/autotask-guarded-changes
```

### Device Quick Look ([device-onboarding](skills/device-onboarding))

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

### Morning Pulse ([device-onboarding](skills/device-onboarding))

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

### Patch Posture ([device-onboarding](skills/device-onboarding))

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
---
## Community and Support

| Channel | Link |
|---|---|
| Website | [the-proving-grounds.io](https://the-proving-grounds.io) |
| Discord | [Join Discord Community channel](https://discord.gg/kHjsAJH4G) |
| Community Calls | Bi-weekly — see Discord for schedule |

---

## Disclaimer

This repository is a community resource. Skills and scripts are provided as-is. Always confirm what a skill will do before authorising execution — especially for steps that delete data, modify records, or affect production devices.

API credentials grant access to your live Kaseya environment. Keep them secure, rotate them regularly, and revoke any key you believe has been compromised.
---
