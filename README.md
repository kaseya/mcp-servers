# Kaseya MCP Readme

**The official Kaseya Model Context Protocol (MCP) servers, tools, skills and other automation scripts library, for Kaseya community of MSP and IT operation builders.**

## Overview
This repo provides MCP servers for Kaseya products for Claude Code, Claude Desktop, Microsoft CoPilot Cowork and other MCP compatible clients. It also provides skills and other autmoation libraries Kaseya users can try and contribute to. 

Here is where patterns get proven, guardrails get built, and collective expertise becomes available to every member who needs it.

---
### What We Share

- **Skills** - reusable Claude Code skills for IT ops workflows
- **MCP servers** - integrations with tools like Datto RMM, Autotask, and IT Glue
- **Runbooks** - Step-by-step operational playbooks
- **Scripts** - PowerShell, Bash, and automation snippets
- **Reports & Dashboards** - operational visibility templates

---
### Who This Is For

- MSP technicians and engineers
- IT operations builders at internal IT departments
- Tool vendors building integrations

---

### Community Channels

| Channel | Link |
|---|---|
| Website | TBD |
| Discord | [Join Discord Community channel](https://discord.gg/kHjsAJH4G) |
| Community Calls | Bi-weekly — see Discord for schedule |

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Supported Clients](#supported-clients)
3. [Supported Products and Tools](#supported-products-and-tools)
4. [Example Tools & Skills](#example-tools--skills)
5. [Complex Skills](#complex-skills)
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
Before editing config files, generate credentials for each platform and **have all values on hand before proceeding** to the next steps:

| Product | Values Needed | How to Generate Secret Keys |
|---|---|---|
| **Datto RMM** | API Key, API Secret | [Generate API Key + Secret](GENERATING-API-KEYS.md#datto-rmm) |
| **IT Glue** | API Key | [Generate API Key](GENERATING-API-KEYS.md#it-glue) |
| **Autotask** | Username, secret, integration code (aka tracking identifier) | [Generate username, secret, and integration code](GENERATING-API-KEYS.md#autotask) |

Tip: **Do not share keys and use minimally scoped permissions for each use case and user.**

---

### Step 1: Connecting to MCP Servers
#### 1.1 Open the Developer Settings in Claude Desktop

Open **Claude Desktop** and click your profile icon in the bottom-left corner to open the account menu, then select **Settings**.

<img width="188" height="192" alt="README1" src="https://github.com/user-attachments/assets/866166f4-22aa-4242-9297-660de666f925" />


In the settings panel, select **developer** from the left sidebar. The MCP server list will appear empty - this is expected for a fresh install. Click **"Edit Config"**

<img width="624" height="289" alt="README13" src="https://github.com/user-attachments/assets/7dc835da-b702-466e-a190-9aef249affb7" />

This will open your file explorer pointing to the config file. **The file is named claude_desktop_config.json** — double-click it to open it in your default text editor.

<img width="624" height="47" alt="README14" src="https://github.com/user-attachments/assets/d84f3537-cda8-4b56-9e10-ee14dc45679b" />

**Can't fine the file?** Navigate to it manually:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

#### 1.2 Edit the Config File
Open the file in a text editor. If the file is empty or new, paste the full configuration block below as-is into the top of the file. If the file already has content, locate the "mcpServers" section and paste the block there.

**Replace each placeholder with the credentials you generated in the Prerequisites step.**
> [!IMPORTANT]
> **Values to replace: `<YOUR_API_KEY>`, `<YOUR_API_SECRET>`, `<YOUR_API_USERNAME>`, and `<YOUR_INTEGRATION_CODE>`**.
> If your config file already contains other settings (such as "preferences"), add only the 'mcpServers' block -- do not replace the entire file. Both sections can exist in the same file.

```json
{
  "mcpServers": {
    "datto-mcp": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://datto-rmm-mcp.data-dev-use1.kaseya-int.net/mcp",
        "--allow-http",
        "--header",
        "X-Datto-API-Key:<YOUR_API_KEY>",
        "--header",
        "X-Datto-API-Secret:<YOUR_API_SECRET>",
        "--header",
        "X-Datto-Platform:concord"
      ]
    },
    "itglue-mcp": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://itglue-mcp.data-dev-use1.kaseya-int.net/mcp",
        "--allow-http",
        "--header",
        "X-ITGlue-API-Key:<YOUR_API_KEY>"
      ]
    },
    "autotask-mcp": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://autotask-mcp.data-dev-use1.kaseya-int.net/mcp",
        "--allow-http",
        "--header",
        "X-Autotask-Username:<YOUR_API_USERNAME>",
        "--header",
        "X-Autotask-Secret:<YOUR_API_SECRET>",
        "--header",
        "X-Autotask-Integration-Code:<YOUR_INTEGRATION_CODE>"
      ]
    }
  }
}
```
**Save the file** once your credentials are in place. 
> [!TIP]
> Sometimes pasting new code in can disrupt the original code format. Run the file through Claude to check and make sure all brackets and syntax look correct.

#### 1.3 Fully Restart Claude Desktop
Config changes only take effect after a full restart. A normal window close is not sufficient.

**Windows:**
1. Open **Task Manager** (Ctrl + Shift + Esc)
2. Find Claude in the list of running processes
3. Right-click → **End Task**
4. Reopen Claude Desktop from the Start Menu or desktop shortcut

**MacOS:**
1. Right-click the Claude icon in the Dock → **Quit**, or press **Cmd + Q** with Claude focused
2. REopen Claude DEsktop

After restarting, return to **Settings → Developer** — you should now see all three MCP servers listed.

#### 1.4 Troubleshooting Your MCP Server Connection

| Symptom | Likely Cause | Fix |
|----------|----------|----------|
| Servers not appearing after restart | Node.js not installed (Windows) | Install a compatible runtime such as Node.js, restart your machine, then restart Claude |
| Connection errors on all three servers | JSON syntax error in config | Re-copy the config block from this document, repaste it into the file, and re-enter your credentials in the highlighted placeholders |
| One server connects, others don't | Wrong credential pasted for that server | Re-check that server's API key/secret against what was generated in the platform |
| Changes not reflected after saving | Claude not fully quit | Use Task Manager (Windows) or Cmd+Q (Mac) to force-quit, then reopen Claude |
| Notified MCP server(s) are disconnected when relaunching Claude and they were already successfully connected | Secret expired | Generate new secret keys for applicable MCP server and update config files accordingly |
| Servers not appearing after editing the configuration file | Configuration file syntax disrupted during editing | Paste the original code block at the start of the file, or run the file through Claude to check for syntax errors |

---

### Step 2: Install the Skills
> [!IMPORTANT]
> **There are multiple ways to download and install the skills in Claude once your MCP servers are connected.**
>
> 1. You can **download the plugin** (TBD)/connect to the marketplace
> 2. If you have access to **Claude Code** in your subscription, you can run commands to install
> 3. You can **manually upload** the skill.md files into Claude.

#### 2.1: Adding Marketplace/Plugin
Inside Claude Desktop, navigate to **Settings > Plugins > Add**, choose **Add marketplace**, and enter the following URL:

```
KaseyaDataPlatform/kaseya-claude-skills
```
<img width="624" height="440" alt="README5" src="https://github.com/user-attachments/assets/a255ce33-add1-4383-85d0-3775b9046930" />

Then select **"sync" .** 

Next, navigate to **Plugins**. Under the personal tab, you will see the 'kaseya-skills' plugin option. Click the plus sign to install. 

<img width="421" height="149" alt="README7" src="https://github.com/user-attachments/assets/8054ec7e-e24b-4f05-b46e-127ca3d457cc" />

To pick up future updates, open **Plugins**, and select the Kaseya skills plug in. When it opens, select the blue link under the source header.

<img width="432" height="248" alt="README10" src="https://github.com/user-attachments/assets/fd655805-9b44-4f6b-8ad9-1f85d806f8bb" />

Navigate over to the personal tab. 

<img width="452" height="227" alt="README11" src="https://github.com/user-attachments/assets/76c33ea1-5814-4cf9-9cd6-0cc880994d2c" />



Follow the link click the `...` next to `kaseya-skills-marketplace`, and choose **Check for updates**. To have updates sync automatically whenever a change is merged to `main`, toggle **Sync automatically** -- this requires granting the Claude GitHub App access to this repository (you'll be prompted for that the first time you enable it).

<img width="466" height="163" alt="README9" src="https://github.com/user-attachments/assets/9ab105d1-5a1d-41b9-b442-cf37ac2edb0e" />

#### 2.2: Commands to Run in Claude Code
Inside Claude Code, run the following commands in your terminal, replacing each highlighted placeholder with the credentials you generated in the Prerequisites step like we did for the Config file in section 1.2: 

```bash
# Datto RMM
claude mcp add datto-rmm-mcp "https://datto-rmm-mcp.data-dev-use1.kaseya-int.net/mcp" \
  --transport http \
  --scope project \
  --header "X-Datto-API-Key:<YOUR_API_KEY>" \
  --header "X-Datto-API-Secret:<YOUR_API_SECRET>" \
  --header "X-Datto-Platform:concord"

# IT Glue
claude mcp add itglue-mcp "https://itglue-mcp.data-dev-use1.kaseya-int.net/mcp" \
  --transport http \
  --scope project \
  --header "X-ITGlue-API-Key:<YOUR_API_KEY>"

# Autotask
claude mcp add autotask-mcp "https://autotask-mcp.data-dev-use1.kaseya-int.net/mcp" \
  --transport http \
  --scope project \
  --header "X-Autotask-Username:<YOUR_API_USERNAME>" \
  --header "X-Autotask-Secret:<YOUR_API_SECRET>" \
  --header "X-Autotask-Integration-Code:<YOUR_INTEGRATION_CODE>"
```

Once complete, run the following commands in Claude Code to add the skills repository as a plugin marketplace, install the plugin marketplace, and to pick up future updates to the repository:

```bash
/plugin marketplace add KaseyaDataPlatform/kaseya-claude-skills
/plugin install kaseya-skills@kaseya-skills-marketplace
/plugin marketplace update kaseya-skills-marketplace
```
---

### Step 3: Restart your client

MCP connections and skills are loaded at startup. Fully quit and reopen Claude Desktop before proceeding.

---

### Step 4: Using the Skills

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
| Microsoft Copilot (Cowork) | ✅ |
| Other MCP-compatible clients | ✅ |

---

## Supported Products and Tools

| Product | What the Skills Can Do |
|---|---|
| **Datto RMM** | Run components and scripts, triage alerts, check device health, audit hardware |
| **IT Glue** | Create and update configuration records, document devices, log triage notes |
| **Autotask** | Read and update tickets, post notes, assign technicians, update ticket status |

---

## Example Tools & Skills

Skills in the Kaseya community come in three levels of complexity, and they work together.

- **Tools** do one specific thing — read a ticket, check if a device is online, post a note, run a script. Simple, fast, and useful on their own.

- **Skills** do a few things together and apply some logic — they look at what they find and decide what to do next. For example, reading a ticket and categorizing the issue type, or checking after a cleanup whether the problem was actually fixed.

- **Complex Skills** are complete workflows. They string Micro Skills and Smart Actions together in the right order to handle an entire process from first look to final documentation — with you approving the key steps along the way.

Any Tool or Skill can also be run on its own, outside of a workflow, whenever you need it. 

Here is some guidance on approach as you explore tools and skills with MCP servers:
1. Simple query tools
2. Simple update tools (with guardrails)
3. Simple skills
4. Complex skills as workflows

## Common MSP Tools
### Autotask

| Tool | Description | How to Invoke |
|---|---|---|
| **Read ticket** | Retrieves the full context of an Autotask ticket including title, description, priority, linked device, and all prior notes including system snapshots. | `"Read ticket 100001"` |
| **Update ticket fields** | Updates standard fields on an Autotask ticket such as priority, category, or linked device. | `"Update ticket 10001 to be highest priority"` |
| **Post Customer-Facing Note** | Adds a customer-visible note to an Autotask ticket. | `"Post a customer facing note on ticket 1101: Issue resolved, device has been restarted"` |
| **Assign technicians** | Automatically assigns the appropriate technician to a ticket for execution. | `"Assign a technician to ticket 10001"` |
| **Update time entry fields** | Updates time entry fields on an Autotask ticket such as hours worked or work description. | `"Log 1.5 hours on ticket 10001 with note: Ran disk cleanup and restarted print spooler service"` |
| **Update Ticket Status** | Changes the status of an Autotask ticket to In Progress, Waiting Customer, or Resolved. | `"Update ticket 10001 to status In Progress"` |
| **Draft Customer-Facing Resolution messages** | Generates a plain-language resolution summary for the end customer with all internal data stripped out. | `"Draft a ticket resolution message for ticket 10001"` |
| **Find similar tickets on device** | Searches Autotask for prior tickets linked to the same device and returns matching ticket numbers, titles, and statuses. | `"Find all past tickets associated to device in ticket 10001"` |

### Datto RMM

| Tool | Description | How to Invoke |
|---|---|---|
| **Get Component Run Output** | Retrieves the output file generated by a Datto RMM component at time of alert creation. | `"Get the component run output for the last alert on device 12345"` |
| **Run Component on Device** | Triggers a pre-built Datto RMM script to run remotely on a target device. | `"Run the disk cleanup component on device 12345"` |
| **Get the RMM Job status** | Fetches the current execution status of a Datto RMM job via a live API call. | `"Get the status of the last job run on device 12345"` |
| **Getting Server role information** | Reads and presents server role data from Datto RMM component that updates UDF fields in alert. | `"Get the server role for device 12345"` |
| **Server role detection** | Runs a ComStore component to detect the server role of a device. | `"Run server role detection on device 12345"` |
| **Set of pre-built DRMM Scripts** | A set of pre-built, fully tested Datto RMM scripts. | `"Run a remediation script on device 12345"` |

### IT Glue

| Tool | Description | How to Invoke |
|---|---|---|
| **Update SOP/Process Documents** | Writes updates to an existing IT Glue SOP or process document. | `"Update the Patch Management SOP in IT Glue"` |
| **Get an SOP or Process Documents** | Retrieves a Standard Operating Procedure or process document from IT Glue. | `"Get the Backup Verification SOP from IT Glue"` |
| **Get Organizational Notes** | Pulls organizational notes from IT Glue for the client associated with a specified ticket. | `"Get the organizational notes from IT Glue for the client on ticket 10001"` |
| **Get configuration information** | Retrieves the IT Glue configuration information for a device including warranty status and primary contact. | `"Get the IT Glue configuration information for the device on ticket 10001"` |

### Skills

| Product | Skill Name | Description | How to Invoke |
|---|---|---|---|
| **Autotask** | Ticket triage for windows device issues | Reads a new Autotask ticket and classifies the primary issue into one of nine categories: disk, performance, connectivity, software, patching, services, hardware alert, user access, or general. | `"Triage ticket 10001"` |
| **Autotask** | Automatic documentation upon ticket resolution | Generates an internal audit note capturing every script and component run, job UIDs, API-confirmed terminal statuses, before/after values for every metric, stdout and stderr output, whether each related alert cleared, machine type, server role, repeat incident count, and whether publish-value resolution used dynamic lookup or fallback, and drafts a customer-facing email on resolution in plain language. Ticket status change: Resolved, Waiting Customer, In Progress, or unchanged. | `"close and document ticket 1001"` |
| **Autotask** | Dynamic Note Visibility | Queries the live Autotask picklist at the start of each session to dynamically resolve the correct publish values, ensuring internal notes never reach customers and customer notes always do. | `"Post an internal note on ticket 10001: Ran disk cleanup, freed 15GB"` |
| **DRMM** | List of pre-built embedded components | Matches the classified ticket issue to a pre-built Datto RMM script from the component library and initiates the component run on the device upon customer approval. | `"Run the matched remediation script on the device for ticket 10001"` |
| **DRMM** | Alert History Intelligence | Analyzes the last 15 days of open and resolved alerts on a device to detect repeat patterns and flag chronic offenders, returning a full occurrence timeline and related ticket references. | `"Show the alert history for the device on ticket 10001"` |
| **DRMM** | Secondary Issues Discovery outside of ticket scope | Scans alert history for weekly or interval-based recurrence patterns that suggest scheduled jobs or backups as a root cause outside the primary ticket scope. | `"Check for recurring issues outside the scope of ticket 10001"` |
| **DRMM** | Role-Aware remediation guidance | Generates a server vs workstation remediation plan based on the detected server role, with check-first steps for technicians to confirm before clean up is executed. | `"Generate a role-aware remediation plan for the device on ticket 10001"` |
| **DRMM, Autotask** | Issue Resolution Validation | Re-audits a device after remediation and presents before/after comparisons for key metrics such as drive space recovered, alerts cleared, and CPU settled. If goals aren't met, offers the technician options to continue or close with a documented outcome. | `"Provide issue resolution validation for ticket 10001"` |
| **DRMM, Autotask, ITGlue** | Data analysis for windows devices (Discovery card) | Aggregates device classification, server role, repeat incident history, primary contact, org notes, and maintenance windows into a single structured card for technicians to have on hand before any remediation or customer communication is initiated. | `"Create a discovery card on device for ticket 10001"` |
| **DRMM** | Device Health Briefing | Pulls online/offline device counts, all open unresolved alerts by priority, disk usage across online devices, and OS breakdown for one site or all sites. Flags devices above 80% disk, surfaces unresolved critical alerts, and calls out any device offline for more than 7 days — all in a single structured summary ready for review. | `"Give me a health briefing for device ABC"` |

---

## Complex Skills

Kaseya has developed nine skills for Claude Desktop that automate Datto RMM, IT Glue, and Autotask workflows -- no coding required. This guide walks through the skills and what you can expect when using the skills so your team can start saving time immediately. All 9 complex skills are included when you install the Kaseya plug in library.

| Skill | What It Automates |
|---|---|
| Autotask-Context | TBD |
| Autotask-Write | TBD |
| Morning-Pulse | TBD |
| Device-quick-look | TBD |
| Patch-Posture | TBD |
| search-ITGlue-documents | TBD |
| update-ITGlue-documents | TBD |
| create-ITGlue-documents | TBD |
| Document Summary | TBD |


### Autotask Context ([device-onboarding](skills/device-onboarding))

**Overview**

Before a technician can work a ticket or an account manager can jump on a customer call, they typically have to open four or five tabs — pulling up the ticket in Autotask, cross-referencing the device in Datto RMM, checking the contact details, reviewing open contracts, and scanning through note history. Done manually, that's five minutes of setup before any real work begins, and it's easy to miss something that was logged in a different place.

Kaseya has built a skill that assembles the complete picture in one step. The skill reads from Autotask and pulls together everything attached to the record you name — the ticket, the company, the contact, or the device — and delivers it as a single structured briefing, ready to read before you pick up the phone or start working.

  *Ready to get started? This document covers the Autotask-Context skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Gives technicians and account managers the full picture on a ticket, customer, contact, or device before they act — without opening multiple tabs
- Surfaces ticket history, notes, time entries, linked contracts, and the associated device in one pass
- Clearly states when information is missing or unavailable, so you know what was checked and what wasn't
- Works for any starting point — a ticket number, a company name, an email address, or a device name
- Presents information the way a colleague would hand it over: what you need to act on first, not in the order the data came back

**What to Expect**

**Step 1: Claude finds the record you named** *(no input required)*

Tell Claude what you want context on — a ticket number, a company name, a contact's email, or a device name — and it looks it up in Autotask. If there's more than one match, Claude lists the options and asks which one you mean before going any further. If nothing comes back, Claude tells you that clearly rather than returning an empty briefing.

**Step 2: Claude pulls everything attached to it** *(no input required)*

Once the anchor record is found, Claude fans out to everything connected to it. For a ticket, that means notes, history, time entries, the linked device, and the associated contract. For a company, it means contacts, open and recent tickets, contracts, and all documented devices. For a contact, it means their company and their ticket history. For a device, it means the owning company and every ticket ever linked to it. Claude works through these one at a time and collects up to 25 notes and history entries by default — you can ask for more if you need them.

**Step 3: You reveive the briefing** 

Claude delivers a structured summary built for the record type you asked about. Every section is included — even when there's nothing to report, Claude says so plainly rather than leaving a gap. Notes are sorted chronologically. Routine system-generated entries are collapsed to a single line so they don't bury the human-written ones. Long text is trimmed with a marker so you can ask for the full version of any entry. The result reads like a handover note, not a database dump.

**How to Invoke**
```
"Brief me on ticket T20260918.0001"
"What's the full context for this ticket?"
"Tell me about Acme Corp"
"Who is jane@acme.com and what are they waiting on?"
"What's the history on this laptop?"
/autotask-context
```

### Autotask Write ([device-onboarding](skills/device-onboarding))

**Overview**

Every update to an Autotask ticket — changing a status, reassigning a technician, logging time, adding a note, updating a priority — carries real downstream consequences. Status changes trigger SLA timers and workflow rules. Notes sent to the wrong audience reach customers who shouldn't see them. A duplicate time entry or a failed write that gets retried can create records that are harder to clean up than to prevent. Done manually under pressure, these updates are where mistakes happen.

Kaseya has built a skill that governs every write to Autotask through Claude. Before any change is made, Claude reads the current record, shows you exactly what will change, and waits for your confirmation. Nothing is written until you've seen the before and after. After the write, Claude reports back what Autotask actually saved — not just what was sent.

  *Ready to get started? This document covers the skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Shows you the current value and the new value side by side before any change is made — no surprises
- Confirms that a field actually needs updating before writing it; if it already holds the right value, Claude says so and makes no change
- Warns you when a status change will trigger SLA timers, workflow rules, or customer notifications — before it happens
- Never retries a failed write automatically, which prevents duplicate records and avoids locking your Autotask API user out through repeated failed authentication
- Reports what Autotask actually saved after each write, not just what was requested
- Covers every write type: ticket updates, notes, time entries, contact records, and any other entity

**What to Expect**

**Step 1: Claude reads the current record before touching it** *(no input required)*

When you ask Claude to make a change — update a ticket status, reassign it, log time, add a note — Claude fetches the current record first. This gives it the existing values it needs to show you a meaningful proposal. If the record already has the value you asked for, Claude tells you and makes no write.

**Step 2: You review the proposed change and confirm it** 

Claude presents the change as a simple before-and-after: the entity, the field, the current value, and the new value. For status changes, it also flags any downstream effects — SLA timers that will start or stop, workflow rules that may fire, or notifications that will go to the customer. You see all of this before anything is written. Claude then waits for your confirmation. A general "just do it" earlier in the conversation does not count — you confirm each change after seeing it.

**Step 3: Claude makes the write and reports back** 

Once you confirm, Claude makes the change and reports what Autotask returned — the actual saved values, not the values that were sent. If the write fails, Claude reports the failure and stops. It does not retry automatically. If the outcome is unclear (for example, a connection dropped mid-request), Claude reads the record back and tells you what it now holds so you can decide what to do next.

A note on picklist fields — fields like status, priority, and queue have numeric IDs behind the labels you see in Autotask. Claude looks those up from your live Autotask configuration before writing, so it uses the correct ID for your account rather than guessing from a label name.

**How to Invoke**
```
"Update ticket 12345 to In Progress"
"Reassign this ticket to Dana"
"Add an internal note to ticket T20260918.0001"
"Log 2 hours against this ticket"
"Set the priority on ticket 100045 to High"
"Create a ticket for Acme Corp"
/autotask-write
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
