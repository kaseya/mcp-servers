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

Kaseya has developed five skills for Claude Desktop and Claude Code that automate Datto RMM, IT Glue, and Autotask workflows -- no coding required. This guide walks through the steps needed to connect those skills to Claude so your team can start saving time immediately. All 5 complex skills are included, and the tools & skills that make them up, when you install the Kaseya plug in library.

| Skill | What It Automates |
|---|---|
| device-onboarding | • Compares Datto RMM devices against IT Glue and identifies what's missing or outdated<br>• Pulls hardware specs automatically and creates or updates IT Glue records after your approval |
| Device-offboarding | • Matches devices across Datto RMM and IT Glue and confirms what will be removed<br>• Deletes IT Glue records and moves devices to a decommission site after your approval |
| datto-device-health-briefing | • Pulls online/offline counts, open alerts by priority, disk usage, and OS breakdown per site<br>• Ranks what needs attention so you know where to start |
| datto-disk-space-triage | • Identifies what's consuming disk space and proposes a targeted cleanup plan for your approval<br>• Runs cleanup, shows space recovered, and resolves the alert automatically if the threshold is cleared |
| datto-component-recommender | • Reads an Autotask ticket, classifies the issue, and selects the right scripts or components to fix it<br>• Presents a remediation plan for your approval, runs it, and documents the outcome on the ticket |

### Device Health Briefing ([datto-device-health-briefing](skills/datto-device-health-briefing))

Generate a health summary for one site or all sites -- online/offline counts, disk pressure, open alerts, and OS spread. Use as a morning briefing or pre-visit check.

**Read-only — never makes changes to any device or record.**

**How to Invoke**
```
"Health briefing for Acme Corp"
"morning briefing for Acme Corp"
/datto-device-health-briefing
```

### Device Onboarding ([device-onboarding](skills/device-onboarding))

**Overview**

When a customer device needs to be onboarded, today someone has to manually cross-reference IT Glue, look up the hardware specs, fill in the configuration record, and make sure nothing was missed or duplicated. Across a busy MSP with dozens fo clients, that process is time-consuming -- and inconsistent documentation creates problems down the line when technicians need accurate records to work from. 

Kaseya has built a skill to automate this workflow end to end. The skill runs inside Claude and connects to your existing Kaseya products — no new integrations, no implementation project, and no changes to the tools your team already uses.

The skill works for a single device or an entire client site in one pass. Claude compares every device in Datto RMM against what's already documented in IT Glue, pulls hardware specs automatically, and creates or updates IT Glue records after your approval. It sorts devices into clear categories — new, already documented, needs an update, or needs a closer look — so your technician knows exactly what's missing before any action is taken. Anything flagged as ambiguous is always surfaced for review and never acted on automatically. Nothing is written to IT Glue without technician approval, and existing records are never overwritten — only blank or stale fields are filled in.

  *Ready to get started? This document covers the Disk Space Resolution skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Automatically identifies which devices are new, already documented, or need a record update — no manual comparison required
- Pulls full hardware specs directly from Datto RMM and writes them into IT Glue
- Flags devices with low disk space during onboarding so nothing gets missed
- Prevents duplicate records — if a device is already in IT Glue, the skill updates it rather than creating a second entry
- Nothing is written to IT Glue without your approval — you see a preview of every field before it's saved
- Works for a single device or an entire site in one pass

**What to Expect**

**Step 1: Claude reviews the site and sorts every device** *(no input required)*

When you name a site, Claude pulls every device from Datto RMM and compares it against IT Glue in one pass. Each device gets sorted into a clear category: new and needs a record created, already documented and up to date, has a record but some fields are missing or stale, needs a closer look before any action is taken, or a device type that's always skipped (ESXi hosts, Datto Continuity appliances, access points, and switches).

Claude presents the results as a simple summary — how many devices fall into each category, what's new, and what needs attention — before asking how you'd like to proceed.

**Step 2: You choose what to onboard**

You can approve the full list of new and outdated devices, pick specific ones, or work through them one at a time. Anything that Claude flagged as needing a closer look is shown separately with the specific reason — those are never acted on automatically.

**Step 3: Claude pulls the hardware and prepare the records** *(no input required)*

For each device you approve, Claude pulls the live hardware audit from Datto RMM — CPU, RAM, storage, network interfaces, serial number, BIOS date, and manufacturer — and formats it into a clean hardware block ready to go into IT Glue. Any drive with less than 15% free space is flagged automatically so you can act on it while you're already looking at the device.

**Step 4: You review and confirm before anything is written**

Claude shows you exactly what it's about to create or update — the device name, organisation, configuration type, OS, and every field it plans to write — and asks you to confirm. Only after you approve does it write anything to IT Glue. For bulk onboarding, it works through each device in sequence and reports the outcome after each one.

**Step 5: Claude offers to document credentials and give you a final summary**

Once devices are documented, Claude asks whether you want to store credentials for any of them in IT Glue — linked directly to the new configuration records. It then presents a complete summary: what was created, what was updated, anything still pending, and any devices that were skipped or hit an error.

**How to Invoke**
```
"Onboard DESKTOP-ABC123 at Acme Corp"
"Onboard all devices for Contoso"
/device-onboarding
```

### Device Offboarding ([device-offboarding](skills/device-offboarding))

Offboard a device or all devices for a site -- retires the IT Glue configuration and optionally moves the device to a decommission site in Datto RMM.

**How to Invoke**
```
"Offboard DESKTOP-ABC123"
"Offboard all devices for Contoso"
/device-offboarding
```

### Disk Space Triage ([datto-disk-space-triage](skills/datto-disk-space-triage))

**Overview**

Resolving a disk space alert requires technicians to manually jump between Autotask, Datto RMM, and IT Glue — investigating what's consuming space, deciding what's safe to clean, running the cleanup, confirming the alert cleared, and then documenting everything. Done correctly, it's a multi-tool process that has to happen consistently across every ticket, every time.

Kaseya has built a skill to automate this workflow end to end. The skill runs inside Claude and connects to your existing Kaseya products — no new integrations, no implementation project, and no changes to the tools your team already uses.

The skill reads tickets in Autotask, investigates the associated device, presents a plain-language breakdown of what's consuming disk space, and carries out the approved cleanup — then validates the result and handles all documentation automatically.

  *Ready to get started? This document covers the Disk Space Resolution skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Eliminates repetitive manual work across multiple tools
- Ensures every disk space ticket is handled consistently, every time
- Surfaces secondary issues that might otherwise be missed
- Keeps documentation complete without relying on the technician to remember
- Tailors its approach based on whether the device is running Windows or Linux
- Automatically resolves the Datto RMM alert once disk usage drops below the threshold — no manual step required
- Nothing is deleted without explicit technician approval — every removal requires a separate confirmation, independent of the overall plan

**What to Expect**

**Step 1: The skill gathers everything it needs** _(no input required)_

Before taking any action, the skill collects everything relevant to the ticket and device across all connected platforms at once. It reads the ticket details and history from Autotask, identifies the linked device in Datto RMM, pulls its current disk usage and online status, and checks IT Glue for the device record.

If the device hasn't been reachable recently, Claude will flag this and ask how you'd like to proceed before doing anything else — it will not run jobs on a device it can't confirm is online without your go-ahead.

Once complete, Claude presents a structured summary of the device's current state, open alerts, disk status, and any relevant notes from IT Glue — giving your technician the full picture before any action is taken.

**Step 2: You review the findings and approve a cleanup plan**

Using everything gathered, Claude runs a disk investigation on the device — this typically takes 5–10 minutes — and then presents a plain-language breakdown of what's consuming disk space. This includes items like Windows Update cache, temp files, large unexpected files, or application logs, along with which items are safe to clean and which need a closer look.

Claude proposes a targeted cleanup plan based on what it found and asks your technician to confirm which items to remove before anything runs. You can approve the full plan, select specific items, or skip any step.

Optionally, Claude can also post a message to your end user letting them know work is underway before cleanup begins.

**Step 3: Claude runs the cleanup (no input required)**

Once approved, Claude carries out each step in sequence and keeps your technician updated throughout. Each cleanup job typically takes 5–10 minutes.

Any item that deletes or removes data requires a separate explicit confirmation immediately before it runs — approving the overall plan does not count as confirmation for individual deletion steps. If a step fails, Claude surfaces the issue and asks whether to continue, skip that step, or stop entirely.

**Step 4: You see before-and-after results**

After cleanup completes, Claude re-checks the device and presents a clear before-and-after comparison — how much space was recovered, what was cleaned, and whether the disk is now in a healthy state.

If disk usage has dropped below the alert threshold, Claude automatically resolves the Datto RMM alert — no manual step needed. If the disk is still critically low after cleanup, Claude flags this and presents options, such as escalating to a senior technician or investigating further, rather than closing the ticket automatically.

**Step 5: Claude documents everything and closes out**

Claude posts a complete internal note to the Autotask ticket covering every step that ran, what was cleaned, and the final device state. It then offers to send your end user a plain-language resolution message — with all technical detail stripped out — and to update the ticket status, or leave it unchanged.

The device record in IT Glue is updated automatically with a log of the triage, so there's a full audit trail without anyone having to write it up manually.

**How To Invoke**
```
"Triage the disk alert on DESKTOP-ABC123"
"Disk space triage for ticket T20260529.0009"
/datto-disk-space-triage
```

### Datto Component Recommender ([datto-component-recommender](skills/datto-component-recommender))

**Overview**

Resolving a Windows device ticket typically means pulling up Datto RMM, cross-referencing IT Glue, reviewing open alerts, and drawing on experience to decide which scripts or components are the right fit. It's a thorough process — and a time-consuming one, especially when technicians are handling a high volume of tickets.

Kaseya has built a skill to automate this workflow end to end. The skill runs inside Claude and connects to your existing Kaseya products — no new integrations, no implementation project, and no changes to the tools your team already uses.

The skill works across eight Windows issue types — disk space, performance, connectivity, software, patching, services, hardware alerts, and user access — and runs through five steps to go from ticket to resolved. Claude handles the research and builds the remediation plan; your technician reviews the findings and approves before anything runs.

  **Note**: This skill supports Windows devices only. If a non-Windows OS is detected, the skill will stop and notify the technician before taking any action.
  
   *Ready to get started? This document covers the Datto Component Recommender skill only. For MCP server connection and skill installation instructions, see the [Getting Started](#getting-started) in this README file in this GitHub repository*.

**Benefits**
- Automatically pulls device context from Autotask, Datto RMM, and IT Glue before any action is taken
- Selects the right scripts and components based on the issue — no manual lookup required
- Surfaces secondary issues not in the original ticket so nothing gets missed
- Nothing runs without technician approval — deletions require a separate confirmation on top of the overall plan
- Every ticket closes with a complete internal audit note and an optional plain-language customer message

**What to Expect**

**Step 1: Claude gathers everything it needs** _(no input required)_

Claude reads the ticket from Autotask, identifies the linked device in Datto RMM, and pulls live status, disk usage, open alerts, CPU, and RAM. It also checks IT Glue for the device record and any org-level notes. Once complete, a Discovery Card is presented — a structured snapshot of the device's current state — before anything else happens. If the device appears offline, Claude will ask how you'd like to proceed before continuing.

**Step 2: You review the findings and approve a plan**

Claude classifies the issue, flags any secondary problems found during discovery, and builds a step-by-step remediation plan using the built-in script library or your existing Datto RMM components. The full plan is shown to the technician before anything runs — every deletion step is called out explicitly. Approve it as-is, adjust it, or skip steps. Optionally, Claude can notify the end user that work is starting.

**Step 3: Claude runs the remediation** *(no input required)*

Claude executes each step in sequence and keeps the technician updated. Jobs typically take 1–5 minutes. Any step that deletes data requires a separate confirmation at the time it runs — overall plan approval does not cover it. If a step fails, Claude asks whether to continue, skip, or stop.

**Step 4: You see before-and-after results**

Claude re-audits the device and presents a before-and-after comparison — disk space recovered, alerts cleared, CPU settled, and anything still open. If the issue isn't fully resolved, Claude surfaces options rather than closing the ticket automatically.

**Step 5: Claude documents everything and closes out**

A complete internal audit note is posted to the Autotask ticket. Claude then offers to send the end user a plain-language resolution message and to update the ticket status — or leave it unchanged.

**Built in Script Library**
- connectivity-diagnostics.ps1
- disk-cleanup-temp.ps1
- disk-clear-wu-cache.ps1
- disk-folder-sizes.ps1
- disk-largest-files.ps1
- hardware-smart-check/ps1
- patching-pending-reboot.ps1
- patching-wu-reset.ps1
- perf-pagefile-check.ps1
- perf-top-processes.ps1
- services-list-stopped.ps1
- software-event-log-errors.ps1
- user-account-status.ps1
- user-list-local-admins.ps1

**How to Invoke**
```
"What should I run for ticket T20260529.0009?"
"Recommend components for ticket 100045"
/datto-component-recommender
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
