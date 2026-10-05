# Kaseya MCP Readme

**The official Kaseya Model Context Protocol (MCP) servers, tools, skills and other automation scripts library, for Kaseya community of MSP and IT operation builders.**

## Overview
This repo provides MCP servers for Kaseya products for Claude Code and Claude Desktop. It also provides skills and other autmoation libraries Kaseya users can try and contribute to. 

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

### Community Channels & Support

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
5. [RMM Skills Page](RMM-Skills.md)
6. [Autotask Skills Page](Autotask-Skills.md)
7. [Security](SECURITY.md)
8. [Code of Conduct](CODE_OF_CONDUCT.md)
9. [Disclaimer](#disclaimer)

---

## Getting Started
1. Browse the repo for skills, MCPs, and runbooks relevant to your stack.
2. Learn how to contribute to this community — see [Contributing](CONTRIBUTING.md).
3. Follow the steps below to set up your MCP servers and install skills into Claude.

### Setup: Connecting to MCP Servers & Skills

#### Step 1: API credentials
Before connecting to MCP Servers, you will need generate credentials for each platform. **Have all values on hand before proceeding** to the next steps:

| Product | Values Needed | How to Generate Secret Keys |
|---|---|---|
| **Datto RMM** | API Key, API Secret | [Generate API Key + Secret](GENERATING-API-KEYS.md#datto-rmm) |
| **IT Glue** | API Key | [Generate API Key](GENERATING-API-KEYS.md#it-glue) |
| **Autotask** | Username, secret, integration code (aka tracking identifier) | [Generate username, secret, and integration code](GENERATING-API-KEYS.md#autotask) |

> [!TIP]
> **Do not share keys and use minimally scoped permissions for each use case and user.**

---

### Step 2: Connecting to MCP Servers 
#### Option 1: MCPB Bundle (Claude Desktop and Claude Code)
1. Download autotask-mcp.mcpb , xxx, xxx  from this repo.
2. Open Claude and navigate to extensions in the left sidebar. Drag the mcpb file into Claude Desktop/Code).
3. Enter your Product credentials when prompted (generated in the pre-requisite step) and save.
4. Enable the extension.
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
| **list_sites** | Read | Retrieve a paginated list of sites in the authenticated Datto RMM tenant. |
| **get_site** | Read | Retrieve detailed information about a specific site. |
| **list_devices** | Read | List and search managed devices, with optional site, device-filter, hostname, device-ID, or MAC-address filtering. |
| **get_device** | Read | Retrieve detailed information about a specific managed device. |
| **get_device_audit** | Read | Retrieve hardware, storage, network, and operating-system audit information for a device. |
| **list_device_software** | Read | Retrieve a paginated list of audited software installed on a device. |
| **list_patches** | Read | Retrieve patch information for a device or site, including installation and approval status. |
| **list_activity_logs** | Read | Retrieve activity history scoped by device, device filter, or account, with time-range filtering and cursor pagination. |
| **list_device_filters** | Read | Retrieve available default, custom, or site-specific device filters. |
| **update_device_udfs** | Write | Update selected device user-defined fields without modifying omitted fields. Previews changes by default; requires explicit confirmation to apply them. |
| **list_components** | Read | Retrieve a paginated catalog of automation components available for execution. |
| **create_job** | Write / Execute | Execute an automation component on a device and return the created job UID. Previews execution by default; requires explicit confirmation to submit the job. |
| **get_job_status** | Read | Retrieve job status, device-specific execution results, and available standard output and error output. |
| **list_alerts** | Read | Retrieve paginated open or resolved monitoring alerts for a device, site, or account. |
| **get_alert** | Read | Retrieve details of a specific monitoring alert. |
| **resolve_alert** | Write | Resolve a monitoring alert. Previews the action by default; requires explicit confirmation and leaves already-resolved alerts unchanged. |

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

Kaseya has developed nine skills for Claude Desktop that automate Datto RMM, IT Glue, and Autotask workflows -- no coding required. This guide walks through the skills and what you can expect when using the skills so your team can start saving time immediately. 

| Skill | What It Automates |
|---|---|
| [autotask-briefing](Autotask-Skills.md#autotask-briefing) | Assembles a complete briefing on one Autotask record and everything attached to it. Use this skill to understand, summarise, or get context on a ticket, company, contact, or device. |
| [autotask-guarded-changes](Autotask-Skills.md#autotask-guarded-changes)| Controls every change to Autotask data. Reads the record first, proposes the change for the user to confirm, then sends each write once and reports what Autotask holds after. |
| [morning-pulse](RMM-Skills.md#morning-pulse) | TBD |
| [device-quick-look](RMM-SKills.md#device-quick-look) | TBD |
| [patch-posture](RMM-Skills.md#patch-posture) | TBD |
| search-ITGlue-documents | TBD |
| update-ITGlue-documents | TBD |
| create-ITGlue-documents | TBD |
| Document Summary | TBD |

---

## Disclaimer

This repository is a community resource. Skills and scripts are provided as-is. Always confirm what a skill will do before authorising execution — especially for steps that delete data, modify records, or affect production devices.

API credentials grant access to your live Kaseya environment. Keep them secure, rotate them regularly, and revoke any key you believe has been compromised.
---
