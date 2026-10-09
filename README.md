# Kaseya MCP servers and skills

**Find the official Kaseya Model Context Protocol (MCP) servers, tools, and skills for managed service provider (MSP) and information technology (IT) operations builders.**

## Overview
This repo provides MCP servers that connect Claude Desktop to Kaseya products. It also provides skills and other automation libraries you can try and contribute to. 

MCP is an open standard that lets AI tools call external tools. Kaseya MCP servers connect the AI tools you already use to Datto RMM, Autotask PSA, and IT Glue, and Kaseya-built skills help automate common MSP workflows, so you don't have to build and maintain everything yourself.

This community proves patterns, builds guardrails, and makes collective expertise available to every member who needs it.

> [!NOTE]
> This release is in alpha. MCP server availability and skill scope may change as testing continues.

---
### What we share

This repo includes:

- **MCP servers** - first-party connectors that give AI tools access to Kaseya product data and actions for Datto RMM, Autotask PSA, and IT Glue
- **Skills** - pre-built, reusable skills for Claude that automate common MSP workflows
- **Setup instructions** - steps to connect MCP servers and install skills in Claude

---
### Who this is for

This repo is for:

- MSP technicians, engineers, automation engineers, and technical leads
- IT operations builders at internal IT departments
- Tool vendors building integrations

---

### Community channels and support

| Channel | Link |
|---|---|
| Discord | You will receive a discord link a few days prior to kickoff |
| Office Hours | Daily - see Discord for schedule |
| Community Calls | Bi-weekly — see Discord for schedule |

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Supported Clients](#supported-clients)
3. [Supported Products and Tools](#supported-products-and-tools)
4. [Example Tools & Skills](#example-tools--skills)
5. [RMM Resources](RMM/)
6. [Autotask Resources](AUTOTASK/)
7. [ITGlue Resources](ITGLUE/)
8. [Disclaimer](Governance/DISCLAIMERS.md#disclaimers-and-claim-waivers)
9. [Security](Governance/SECURITY.md)
10. [Code of Conduct](Governance/CODE_OF_CONDUCT.md)
11. [Governance Policy](Governance/GOVERNANCE.md)

---

## Getting Started
1. **Browse the repo** for tools, skills, and MCP Servers relevant to your stack.
2. **Try Something** - break it, learn from it, and share what you found.
3. Follow the steps below to set up your MCP servers and install skills into Claude.

### Setup: Connecting to MCP Servers & Skills

#### Step 1: API credentials
Before connecting to MCP Servers, you will need generate credentials for each platform. **Have all values on hand before proceeding** to the next steps:

| Product | Values Needed | How to Generate Secret Keys |
|---|---|---|
| **Datto RMM** | API Key, API Secret | [Generate API Key + Secret](GENERATING-API-KEYS.md#datto-rmm) |
| **IT Glue** | API Key | [Generate API Key](GENERATING-API-KEYS.md#it-glue) |
| **Autotask** | Username, secret, integration code (aka tracking identifier) | [Generate username, secret, and determine your Autotask MCP endpoint](GENERATING-API-KEYS.md#autotask) |

> [!IMPORTANT]
> Your use of any MCP server is governed by the Kaseya API License, which is accessible [here.](https://www.kaseya.com/legal/kaseya-api-license/)
> **Do not share keys and use minimally scoped permissions for each use case and user. Be aware** that once connected, the AI services will be able to:
> 1. Read and access the Content in your Kaseya product platform; and
> 2. Create and update the Content in your Kaseya product platform.
>    
> **Such Content will be accessible to the AI service exactly as stored in the Kaseya Product platform. Content may include sensitive information such as usernames, passwords or other confidential data.**
>
> AI services are Third Party Technology under the Kaseya Master Agreement, which is accessible [here.](https://www.kaseya.com/legal/kaseya-master-agreement/)

---

#### Step 2: Connecting to MCP Servers and Installing Skills (Claude Desktop and Claude Code)

**Option 1: MCPB Bundle in Claude Desktop**
1. Download MCPB Bundle for each server you wish to connect to, and associated product skills zip file.

    | Product | Files | Link |
    |---|---|---|
    | Autotask | autotask-mcp.mcpb, autotask-skills-20261006 | [Autotask Folder](AUTOTASK) |
    | Datto RMM | drmm-mcp.mcpb, | [Datto RMM Folder](RMM) |
    | ITGlue | itg-mcp.mcpb, | ITG Folder -- need mcpb file, no skills for alpha) |

2. Open Claude settings and navigate to **extensions** in the left sidebar. Drag the mcpb file into Claude Desktop/Code.
       If you experience any issues with dragging and dropping your files, you can also select **advanced settings** and **install extension**. This will prompt a browser window for you to select the file.
3. Enter your Product credentials when prompted (generated in the pre-requisite step) and save.
4. Enable the extension. Repeat for each product you wish to connect.
5. Download the Skills-plugin-zip file from each product folder in this repo whose MCP servers you connected to. Navigate to **plugins** in left sidebar in Claude and select the plus button in the top right corner, selecting **upload file**. Once zip file is added, select upload. 

**Option 2: MCPB Bundle in Claude Code (CLI)**

**RMM**

```bash
   claude mcp add --transport http datto-rmm https://mcp.<platform>.rmm.datto.com/mcp --header "x-drmm-api-key: <API Key>" --header "x-drmm-api-secret: <API Secret>"
```

**Autotask**
1. Store your Autotask API credentials by running the `autotask-auth.ps1` script's `configure` verb from PowerShell:
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\autotask-auth.ps1 configure
   ```
   `configure` does the following:
   - Prompts for the Autotask MCP endpoint, which is the server's full URL, for example `https://mcp3.autotask.net/mcp`. The URL must start with `https://` and end with `/mcp`, or `configure` rejects it. Use the same URL in steps 2 and 3, in place of `<mcp-host>`.
   - Prompts for the Autotask API username, secret, and integration code. The secret and integration code are hidden as you type.
   - Stores the credentials encrypted for your Windows user only (DPAPI), in `%LOCALAPPDATA%\Kaseya\AutotaskMcp`.
2. Add the base HTTP entry:
   ```powershell
   claude mcp add --transport http --scope user autotask https://<mcp-host>/mcp
   ```
3. Open `%USERPROFILE%\.claude.json`, find the `"autotask"` entry in the top-level `"mcpServers"` object, and add `headersHelper`. Copy the `headersHelper` value from the entry that `configure` printed in step 1. The path in it is the absolute path to `autotask-auth.ps1` on this machine, with each backslash doubled for JSON. The entry has this shape:
   ```json
   "autotask": {
     "type": "http",
     "url": "https://<mcp-host>/mcp",
     "headersHelper": "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File \"<path-to>\\autotask-auth.ps1\" headers -Profile default"
   }
   ```
4. Run `claude mcp get autotask`. The output shows the entry and its scope.

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

Skills in the Kaseya community come in two levels of complexity, and they work together.

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
| **search-entries** | Read | Finds the Autotask entity name that matches a plain-language description.|
| **describe-entity** | Read | Returns the live field schema: field names, data types, flags, picklist values, and supported operators.|
| **query-entity** | Read | Queries an entity with filters, one “anyOf” group, fields, and limit. Returns rows in id order, with a nextPage hint.|
| **count-entities** | Read | Counts rows matching the filters, without fetching them.|
| **get-entity** | Read | Gets one row by numeric id. Returns found: false if no row has that id.|
| **search-tickets** | Read | Searches tickets by company, status, title, assignment, and date. No query DSL needed. Defaults to open tickets.|
| **get-ticket** | Read | Gets one ticket by id, with full detail in ticket vocabulary. |
| **create-entity** | Write | Creates a row, reads it back, and returns it enriched. Do not resend the create to check whether it worked.|
| **update-entity** | Write | Updates one row by id, reads it back, and returns it enriched.|
| **delete-entity** | Write | Permanently deletes one row. Only working rows and link rows accept a delete — business records never do.|
| **add-ticket-note** | Write | Adds a note to an existing ticket. Returns the note, read back and enriched.|

### Datto RMM

| Tool | Operation | Description |
|---|---|---|
| **list-sites** | Read | Retrieve a paginated list of sites in the authenticated Datto RMM tenant. |
| **get-site** | Read | Retrieve detailed information about a specific site. |
| **list-devices** | Read | List and search managed devices, with optional site, device-filter, hostname, device-ID, or MAC-address filtering. |
| **get-device** | Read | Retrieve detailed information about a specific managed device. |
| **get-device-audit** | Read | Retrieve hardware, storage, network, and operating-system audit information for a device. |
| **list-device-software** | Read | Retrieve a paginated list of audited software installed on a device. |
| **list-patches** | Read | Retrieve patch information for a device or site, including installation and approval status. |
| **list_activity_logs** | Read | Retrieve activity history scoped by device, device filter, or account, with time-range filtering and cursor pagination. |
| **list_device_filters** | Read | Retrieve available default, custom, or site-specific device filters. |
| **update-device-udfs** | Read | Update selected device user-defined fields without modifying omitted fields. Previews changes by default; requires explicit confirmation to apply them. |
| **list-device-software** | Read | Retrieve a paginated catalog of automation components available for execution. |
| **create-job** | Write / Execute | Execute an automation component on a device and return the created job UID. Previews execution by default; requires explicit confirmation to submit the job. |
| **get-job-status** | Read | Retrieve job status, device-specific execution results, and available standard output and error output. |
| **list-alerts** | Read | Retrieve paginated open or resolved monitoring alerts for a device, site, or account. |
| **get-alert** | Read | Retrieve details of a specific monitoring alert. |
| **resolve-alert** | Write | Resolve a monitoring alert. Previews the action by default; requires explicit confirmation and leaves already-resolved alerts unchanged.

### IT Glue -- REMOVE FOR ALPHA

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

## Skills

Kaseya has developed nine skills for Claude Desktop that automate Datto RMM, IT Glue, and Autotask workflows -- no coding required. This guide walks through the skills and what you can expect when using the skills so your team can start saving time immediately. 

| Product | Skill | What It Automates |
|---|---|---|
| Autotask | [autotask-briefing](AUTOTASK/Autotask-Skills.md#autotask-briefing) | Assembles a complete briefing on one Autotask record and everything attached to it. Use this skill to understand, summarise, or get context on a ticket, company, contact, or device. |
| Autotask | [autotask-guarded-changes](AUTOTASK/Autotask-Skills.md#autotask-guarded-changes)| Controls every change to Autotask data. Reads the record first, proposes the change for the user to confirm, then sends each write once and reports what Autotask holds after. |
|DRMM | [drmm-morning-pulse](RMM/DRMM-Skills-documentation.md#morning-pulse) | Reads devices, open alerts, overnight resolved alerts and the overnight activity log; separates new overnight drops from long-dead gear, spots servers about to fail, and gives a plan ranked by customer impact. |
|DRMM | [drmm-device-quick-look](RMM/DRMM-Skills-documentation.md#device-quick-look) | Finds the device by hostname, part of a name, MAC or ID; reads its record, hardware, alerts, patches, software and recent activity; trends disk space and groups repeating alerts. |
|DRMM | [drmm-patch-posture](RMM/DRMM-Skills-documentation.md#patch-posture) | Reads patch status across servers and workstations, names failing and pending updates, and flags conditions that will break the next patch cycle (disk full, servicing errors). |
|DRMM |[drmm-stale-and-ghost-devices](RMM/DRMM-Skills-documentation.md#stale-and-ghost-devices)| Finds long-offline devices, ghosts (re-imaged or renamed machines left behind, duplicate enrolments), suspended agents and sites holding only dead records — with an estimate of the seats involved.|
|DRMM |[drmm-security-coverage-gaps](RMM/DRMM-Skills-documentation.md#security-coverage-gaps)| Vendor-neutral: checks antivirus presence, running state and updates, finds EDR/MDR agents through device filters, and flags conflicting products. Per-site figures you can hand to a customer or an insurance questionnaire. |
|DRMM |[drmm-device-timeline](RMM/DRMM-Skills-documentation.md#device-timeline)| Builds one timeline from the activity log (jobs, patches, remote sessions, changes) and alerts, marks what happened just before the problem, and states timing, never blame. Suggests which Windows event-log entries a technician should check.|
|DRMM |[drmm-alert-noise-review](RMM/DRMM-Skills-documentation.md#alert-noise-review)| Groups recent alerts by type and device, scores the noise (self-resolving, flapping, same time every day, tickets nobody needed, alerts on dead gear) and recommends a specific tuning step — while protecting alerts that are noisy but real.|
|DRMM |[drmm-software-finder](RMM/DRMM-Skills-documentation.md#software-finder)| Groups devices by version and site, rates versions current, behind or end of life against the vendor's latest release, and can look for shadow IT (remote-control tools, personal VPNs, P2P, other RMMs) or a whole category.
|DRMM |[drmm-od-lifecycle](RMM/DRMM-Skills-documentation.md#od-lifecycle)| Checks every device's OS and build against end-of-life dates looked up live (Windows, Windows Server, macOS, common Linux, ESXi); marks paid extended updates where possible; servers first.|

## Legal Documents 

The Kaseya Insights Community operates under a set of governing documents. All Participants are expected to read and comply with the documents applicable to their activities.

| Doc | Purpose |
|[License](LICENSE.md)|Apache License, Version 2.0. Governs all Contributions to the community.|
|[Code of Conduct](CODE_OF_CONDUCT.md)|Community standards and enforcement policy. Applies to all community spaces and Participants.|
|[Governance Policy](GOVERNANCE.md)|Community structure and roles.|
|[Security Policy](SECURITY.md)|How to report security vulnerabilities privately. Please do not post vulnerability reports in public Issues or forums.|
|[Disclaimers](DISCLAIMERS.md)|Consolidated disclaimers and claim waivers applicable to all community activities and Participants.|
