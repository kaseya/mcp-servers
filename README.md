# Kaseya MCP servers and skills

**Find the official Kaseya Model Context Protocol (MCP) servers, tools, and skills for MSP and IT operations builders.**

## Overview
This repo provides MCP servers that connect Claude Desktop to Kaseya products. It also provides skills and other automation libraries you can try and contribute to. 

MCP is an open standard that lets AI tools call external tools. Kaseya MCP servers connect the AI tools you already use to Datto RMM, Autotask, and IT Glue, and Kaseya-built skills help automate common MSP workflows, so you don't have to build and maintain everything yourself.

This community proves patterns, builds guardrails, and makes collective expertise available to every member who needs it.

> [!NOTE]
> This release is in alpha. MCP server availability and skill scope may change as testing continues.

---
### What we share

This repo includes:

- **MCP servers** - first-party connectors that give AI tools access to Kaseya product data and actions for Datto RMM, Autotask, and IT Glue
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

| Channel | Details |
|---|---|
| Discord | You receive a discord link a few days prior to kickoff. |
| Office Hours | Daily. See Discord for the schedule. |
| Community Calls | Bi-weekly. See Discord for the schedule. |

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Supported Clients](#supported-clients)
3. [Supported Products and Tools](#supported-products-and-tools)
4. [Example Tools & Skills](#example-tools-and-skills)
5. [RMM Resources](RMM/)
6. [Autotask Resources](AUTOTASK/)
7. [ITGlue Resources](ITGLUE/)
8. [Disclaimer](Governance/DISCLAIMERS.md#disclaimers-and-claim-waivers)
9. [Security](Governance/SECURITY.md)
10. [Code of Conduct](Governance/CODE_OF_CONDUCT.md)
11. [Governance Policy](Governance/GOVERNANCE.md)

---

## Getting started
To get started, complete the following steps:

1. Browse the repo for tools, skills, and MCP servers relevant to your stack.
2. Try something - break it, learn from it, and share what you found.
3. Review the prerequisites, and then follow the setup steps to connect your MCP servers and install skills in Claude.

### Prerequisites

Before you begin, make sure you have:

- An account with administrator access for each Kaseya product you want to connect: Datto RMM, Autotask, or IT Glue.
- Claude Desktop.

### Setup: Connecting to MCP servers and skills

#### Step 1: Generate credentials
Before connecting to MCP Servers, generate application programming interface (API) credentials for each platform. **Have all values on hand before proceeding to Step 2.**

| Product | Values needed | How to generate credentials |
|---|---|---|
| **Datto RMM** | API Key, API Secret | [Generate API Key + Secret](GENERATING-API-KEYS.md#datto-rmm) |
| **IT Glue** | API Key | [Generate API Key](GENERATING-API-KEYS.md#it-glue) |
| **Autotask** | Username, secret, integration code (also called tracking identifier) | [Generate username, secret, and determine your Autotask MCP endpoint](GENERATING-API-KEYS.md#autotask) |

> [!IMPORTANT]
> The [Kaseya API License](https://www.kaseya.com/legal/kaseya-api-license/) governs your use of any MCP server.
> **Do not share keys, and use minimally scoped permissions for each use case and user. Be aware** that, once connected, AI services can:
> 1. Read and access the Content in your Kaseya product platform.
> 2. Create and update the Content in your Kaseya product platform.
>    
> **AI services access Content exactly as the Kaseya product platform stores it. Content may include sensitive information such as usernames, passwords or other confidential data.**
>
> The [Kaseya Master Agreement](https://www.kaseya.com/legal/kaseya-master-agreement/) classifies AI services as Third Party Technology.

---

#### Step 2: Connect to MCP servers and install skills in Claude Desktop

Complete the following steps to connect Claude Desktop to an MCP server and install its skills:

1. Download the MCPB Bundle (MCPB) file and skills ZIP file listed for each product you want to connect.

    | Product | Files | Link |
    |---|---|---|
    | Autotask | autotask-mcp.mcpb, autotask-plugin.zip | [Autotask folder](AUTOTASK) |
    | Datto RMM | drmm-mcp.mcpb, Datto-RMM-plugin.zip | [Datto RMM folder](RMM) |
    | IT Glue | itg-mcp.mcpb | IT Glue folder (MCPB file needed; no skills for alpha) |

2. Open Claude settings and navigate to **Extensions** in the left sidebar. Drag the MCPB file into Claude Desktop.

   > [!NOTE]
   >If you can't drag the file, click **Advanced Settings**, click **Install Extension**, and then select the file in the window that opens.

4. Enter the credentials you generated in [Step 1](#step-1-generate-credentials) when prompted, and then click **Save**.
5. Enable the extension. Repeat steps 2 through 4 for each product you want to connect.
6. Upload the skills ZIP file for each product you connected:
   1. In Claude, click **Skills** in the left sidebar.
   2. Click the **Plus** icon in the upper-right corner.
   3. Click **Upload File**, and then select the ZIP file you downloaded earlier.
   4. Click **Upload**.
   5. Repeat these steps for each product.
   
---

## Supported clients

| Client | Supported |
|---|---|
| Claude Desktop | ✅ |
| Claude Code | Planned for a future release. |

---

## Supported products and tools

| Product | What skills can do |
|---|---|
| **Datto RMM** | Run components and scripts, triage alerts, check device health, and audit hardware |
| **IT Glue** | Create and update configuration records, document devices, and log triage notes |
| **Autotask** | Read and update tickets, post notes, and provide ticket briefings |

---

## Example tools and skills

Skills in the Kaseya community come in two levels of complexity, and they work together.

- **Tools** do one specific thing — read a ticket, check whether a device is online, post a note, or run a script. Tools are simple, fast, and useful on their own.

- **Skills** are complete workflows. They string tools together in the right order to handle an entire process from first look to final documentation, and you approve the key steps along the way.

Run any tool or skill on its own, outside of a workflow, whenever you need it. 

Follow this approach as you explore tools and skills with MCP servers:
1. Start with simple query tools (read).
2. Move to simple update tools (write, with guardrails).
3. Progress to simple skills as workflows.

## Common MSP tools
### Autotask

| Tool | Operation | Description |
|---|---|---|
| **search-entities** | Read | Find the Autotask entity name that matches a plain-language description.|
| **describe-entity** | Read | Return the live field schema: field names, data types, flags, picklist values, and supported operators.|
| **query-entity** | Read | Query an entity with filters, one `anyOf` group, fields, and a limit. Return rows in identifier (ID) order, with a `nextPage` hint.|
| **count-entities** | Read | Count rows that match the filters, without fetching them.|
| **get-entity** | Read | Get one row by numeric ID. Return `found: false` if no row has that ID.|
| **search-tickets** | Read | Search tickets by company, status, title, assignment, and date. No query DSL needed. Default to open tickets.|
| **get-ticket** | Read | Get one ticket by ID, with full detail in ticket vocabulary. |
| **create-entity** | Write | Create a row, read it back, and return it enriched. Do not resend the create request to check whether it worked.|
| **update-entity** | Write | Update one row by ID, read it back, and return it enriched.|
| **delete-entity** | Write | Permanently delete one row. Only working rows and link rows accept a delete; business records never do.|
| **add-ticket-note** | Write | Add a note to an existing ticket. Return the note, read back and enriched.|

### Datto RMM

| Tool | Operation | Description |
|---|---|---|
| **list-sites** | Read | Retrieve a paginated list of sites in the authenticated Datto RMM tenant. |
| **get-site** | Read | Retrieve detailed information about a specific site. |
| **list-devices** | Read | List and search managed devices, with optional site, device filter, hostname, device ID, or MAC address filtering. |
| **get-device** | Read | Retrieve detailed information about a specific managed device. |
| **get-device-audit** | Read | Retrieve hardware, storage, network, and operating-system audit information for a device. |
| **list-device-software** | Read | Retrieve a paginated list of audited software installed on a device. |
| **list-patches** | Read | Retrieve patch information for a device or site, including installation and approval status. |
| **list_activity_logs** | Read | Retrieve activity history scoped by device, device filter, or account, with time-range filtering and cursor pagination. |
| **list_device_filters** | Read | Retrieve available default, custom, or site-specific device filters. |
| **update-device-udfs** | Write | Update selected device user-defined fields without modifying omitted fields. Preview changes by default; require explicit confirmation to apply them. |
| **list-device-software** | Read | Retrieve a paginated catalog of automation components available for execution. |
| **create-job** | Write / Execute | Execute an automation component on a device and return the created job UID. Preview execution by default; require explicit confirmation to submit the job. |
| **get-job-status** | Read | Retrieve job status, device-specific execution results, and available standard output and error output. |
| **list-alerts** | Read | Retrieve paginated open or resolved monitoring alerts for a device, site, or account. |
| **get-alert** | Read | Retrieve details of a specific monitoring alert. |
| **resolve-alert** | Write | Resolve a monitoring alert. Preview the action by default; require explicit confirmation and leave already-resolved alerts unchanged.

## Skills

The following skills for Claude Desktop automate Datto RMM, IT Glue, and Autotask workflows, with no coding required. This guide walks through each skill and what to expect when you use it, so your team can start saving time immediately. 

| Product | Skill | What it automates |
|---|---|---|
| Autotask | [autotask-briefing](AUTOTASK/Autotask-Skills.md#autotask-briefing) | Assembles a complete briefing on one Autotask record and everything attached to it. Use this skill to understand, summarise, or get context on a ticket, company, contact, or device. |
| Autotask | [autotask-guarded-changes](AUTOTASK/Autotask-Skills.md#autotask-guarded-changes)| Controls every change to Autotask data. Reads the record first, proposes the change for you to confirm, sends each write once, and reports what Autotask holds afterward. |
|Datto RMM | [drmm-morning-pulse](RMM/DRMM-Skills-documentation.md#morning-pulse) | Reads devices, open alerts, overnight resolved alerts, and the overnight activity log; separates new overnight drops from long-dead gear, spots servers about to fail, and gives you a plan ranked by customer impact. |
|Datto RMM | [drmm-device-quick-look](RMM/DRMM-Skills-documentation.md#device-quick-look) | Finds the device by hostname, part of a name, MAC address, or ID; reads its record, hardware, alerts, patches, software, and recent activity; trends disk space and groups repeating alerts. |
|Datto RMM | [drmm-patch-posture](RMM/DRMM-Skills-documentation.md#patch-posture) | Reads patch status across servers and workstations, names failing and pending updates, and flags conditions that will break the next patch cycle (such as disk full or servicing errors). |
|Datto RMM |[drmm-stale-and-ghost-devices](RMM/DRMM-Skills-documentation.md#stale-and-ghost-devices)| Finds long-offline devices, ghosts (re-imaged or renamed machines left behind, duplicate enrolments), suspended agents, and sites holding only dead records, with an estimate of the seats involved.|
|Datto RMM |[drmm-security-coverage-gaps](RMM/DRMM-Skills-documentation.md#security-coverage-gaps)| Vendor-neutral: checks antivirus presence, running state and updates; finds EDR and MDR agents through device filters; and flags conflicting products. Provides per-site figures you can hand to a customer or an insurance questionnaire. |
|DRMM |[drmm-device-timeline](RMM/DRMM-Skills-documentation.md#device-timeline)| Builds one timeline from the activity log (jobs, patches, remote sessions, changes) and alerts, marks what happened just before the problem, and states timing, never blame. Suggests which Windows event log entries a technician should check.|
|Datto RMM |[drmm-alert-noise-review](RMM/DRMM-Skills-documentation.md#alert-noise-review)| Groups recent alerts by type and device, scores the noise (self-resolving, flapping, same time every day, tickets nobody needed, alerts on dead gear), and recommends a specific tuning step while protecting alerts that are noisy but real.|
|Datto RMM |[drmm-software-finder](RMM/DRMM-Skills-documentation.md#software-finder)| Groups devices by version and site, rates versions current, behind, or end of life against the vendor's latest release, and can look for shadow IT (remote-control tools, personal VPNs, P2P, other RMMs) or a whole category of software.
|Datto RMM |[drmm-od-lifecycle](RMM/DRMM-Skills-documentation.md#od-lifecycle)| Checks every device's OS and build against live end-of-life dates for Windows, Windows Server, macOS, common Linux distributions, and ESXi); marks paid extended updates where possible; servers first.|

## Legal Documents 

The Kaseya Insights Community operates under a set of governing documents. All Participants are expected to read and comply with the documents applicable to their activities.

| Doc | Purpose |
|[License](LICENSE.md)|Apache License, Version 2.0. Governs all contributions to the community.|
|[Code of Conduct](CODE_OF_CONDUCT.md)|Community standards and enforcement policy. Applies to all community spaces and Participants.|
|[Governance Policy](GOVERNANCE.md)|Community structure and roles.|
|[Security Policy](SECURITY.md)|How to report security vulnerabilities privately. Do not post vulnerability reports in public issues or forums.|
|[Disclaimers](DISCLAIMERS.md)|Consolidated disclaimers and claim waivers applicable to all community activities and Participants.|
