# IT Glue Skills

Six skills turn IT Glue into answers technicians, admins and account managers use every day. Four only read from IT Glue. Two, which write documents from what was done in a ticket, change IT Glue only after you approve the exact text. All six work on one client at a time and are deliberately light on API calls. They say plainly what IT Glue could not show, so a missing item is treated as a finding and not hidden.

| Skill                                                                     | Built for                       | What you get                                                                                                                    |
| ------------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| [itglue-organization-overview](#itglue-organization-overview)             | Technicians                     | Site-visit pack: network gear, internet details, printers, site documents and ticket hints, with gaps flagged                   |
| [itglue-hygiene-check](#itglue-hygiene-check)                             | Admins, service desk leads      | Scorecard of one client's documentation quality plus what to fix first                                                          |
| [itglue-environment-review](#itglue-environment-review)                   | Account managers, vCIOs         | Documentation and Asset Health Review: lifecycle, security documentation, document age, recommended actions                     |
| [itglue-ticket-documentation-finder](#itglue-ticket-documentation-finder) | Technicians, service desk leads | Get an SOP to resolve a ticket: the most relevant IT Glue documents for the ticket, read in full, with why each one applies     |
| [itglue-update-docs-from-ticket](#itglue-update-docs-from-ticket)         | Technicians, admins             | Keep the SOP up-to-date: proposed edits to existing documents from what changed in a ticket, saved as a draft after you approve |
| [itglue-create-docs-from-ticket](#itglue-create-docs-from-ticket)         | Technicians, admins             | Share the knowledge with the team: a new document from the work done in a ticket, created unpublished after you approve         |

The last three work from an Autotask ticket when the Autotask connector is available. Without it, they work from what you tell Claude.

_Before using these skills, make sure the IT Glue MCP server is connected and the skills are installed. See the [Getting Started](../README.md#getting-started) section of the README._

---

## Rules every skill follows

IT Glue throttles the whole account at 3,000 requests per 5 minutes, and other integrations already use most of that. The skills are designed to be gentle.

- **One client at a time.** A request for "all clients" is not run. The skill explains the cost, offers a shortlist of up to 5 clients with an estimate, and waits for a go-ahead.
- **No bursts.** At most 3 calls run in parallel.
- **Stops on the first error.** Any connector error is treated as a possible rate limit. The skill reports what it has, says what was skipped, and does not retry in a loop.
- **Counts, not row dumps.** Totals come from pagination data using page size 1. Other reads use small pages.
- **No repeat calls.** Anything already fetched in the conversation is reused.
- **Nothing is written without your approval.** Four skills never change IT Glue. The two that write (update and create) show the exact text first and wait for your approval of that version.
- **No credentials.** No skill requests or copies passwords, keys or secrets.
- **Honest reporting.** Every result says what was and was not checked, whether a figure is a total or a sample, and how many calls were used.

| Skill                       | Default run                                                  | Hard cap |
| --------------------------- | ------------------------------------------------------------ | -------- |
| Organization overview       | About 10 calls (quick mode about 4)                          | 14       |
| Hygiene check               | 7 calls (13 with the optional archived-reference check)      | 15       |
| Environment review          | About 14 calls, stated before it starts (quick mode about 7) | 20       |
| Ticket documentation finder | About 7 calls (quick mode about 4)                           | 12       |
| Update docs from ticket     | About 8 calls                                                | 15       |
| Create docs from ticket     | About 8 calls                                                | 15       |

---

## itglue-organization-overview

**Overview**

Once you are in a server closet, the things you needed are hardest to find: what network gear is at the site, who the ISP is, which documents apply. This skill builds a site-visit pack so a technician arrives knowing what is on site. It also finds which client owns a device from a serial number, MAC address or asset tag.

**Benefits**

- One-page pack: site, network gear with brand, model and rack or closet, ISP and circuit details, printers, directory and DNS or DHCP summary, most-ticketed devices, connections, and site-specific documents
- Flags whatever is missing, for example "ISP details not found, add before the next outage"
- Flags duplicate serial numbers, which usually means cloned documentation
- Quick mode (about 4 calls) returns the asset list and the documents to open

**What to Expect**

1. Claude resolves the client. If several sites exist, it asks which one before doing anything else
2. It reads assets and documents for that client within the call budget
3. It delivers the pack, then lists what was not found and why

**How to Invoke**

```
"I'm going onsite to [client], [site name]. What do I need to know?"
"Give me an overview of [client] for a site visit. Keep it quick."
"What network gear is at [site] for [client], and who is their ISP?"
"Which client has the device with serial number [serial]?"
"Which printers are at [client], and where are they?"
/itglue-organization-overview
```

---

## itglue-hygiene-check

**Overview**

IT Glue is only as useful as it is complete and current. This skill answers how trustworthy one client's documentation is and where to start fixing it, using counts and a short sample, not a full export.

**Benefits**

- Measures missing serial numbers and asset tags, assets not marked Active, archived assets, stale documents and duplicate document titles
- Reports gaps as candidates, because virtual machines and cloud resources legitimately have no serial number
- Prioritizes cleanup by evidence, with effort estimates (small, medium, large)
- Optional check opens up to 5 archived assets to see whether other records still reference them

**What to Expect**

1. Claude resolves the client. If several organizations match, it lists them with IDs and asks
2. It runs about 7 calls: stale sample, identifier gaps, status, archived assets, documents
3. It delivers a one-screen scorecard (live assets, % missing serial, % missing asset tag, % not marked Active, archived count, documents not updated in 12 months, documents sharing a name), a "fix first" list of three to five actions, and the stalest records with links

Example from testing: one QA client with 250 live assets had 28% with no serial number and 78% with no asset tag. All 16 documents were over a year old and 11 shared one title. That took 6 calls.

**How to Invoke**

```
"How complete is the documentation for [client]?"
"Run a hygiene check on [client] and tell me what to fix first."
"We just onboarded [client]. Is their documentation in decent shape?"
"Check [client] and see whether any archived assets are still referenced."
/itglue-hygiene-check
```

---

## itglue-environment-review

**Overview**

Preparing for an account review or renewal normally means pulling asset lists, warranty dates and documents by hand. This skill produces a Documentation and Asset Health Review for one client. It is not a QBR: it covers documentation and asset health only.

**Benefits**

- Lifecycle view: warranty expirations and operating systems past end of life
- Security documentation: whether MFA, MDM and antivirus are documented
- Documentation health: documents older than 12 months and duplicate titles
- Prioritized recommended actions and an explicit "not covered" section
- Output as Word, PDF or slides on request, framed for internal or client-facing audiences. Figures are never softened

**What to Expect**

1. Claude resolves the client and states the plan and call count before starting (about 14, quick mode about 7, capped at 20)
2. It checks up to 5 key assets (servers and network gear first) for warranty and OS, and says "N of M checked"
3. It delivers a two-page report: summary, environment at a glance, lifecycle, security documentation, documentation health, data quality, recommended actions, not covered

Reusing a recent hygiene check in the same conversation saves calls.

**How to Invoke**

```
"Prepare a client environment review for [client]."
"I have a renewal meeting with [client] on Thursday. Show me the state of their environment."
"Which of [client]'s key assets are out of warranty or on an unsupported OS?"
"Prepare a client-facing review for [client] as a Word document."
"Prepare a review for [client]. I already ran a hygiene check, so reuse it."
/itglue-environment-review
```

---

## itglue-ticket-documentation-finder

**Overview**

A technician with an open ticket needs the one or two documents that help right now: the runbook, the setup guide, the last person's notes on this device. This skill turns the ticket into a targeted search, reads the best matches in full, and explains why each one applies. It only reads documents, and it prefers returning nothing over returning something unrelated.

**Benefits**

- Starts from the Autotask ticket (client, notes, history, affected device), or from the client and error message you give it when Autotask is not connected
- Treats documents linked to the affected device as strong matches, ranks the rest by title, error text and site, and flags a document not updated in over 12 months as possibly stale
- Shows the relevant sections in the document's own order without rewording the steps, and never repeats a password or key found in a document
- Says plainly when nothing clearly matches and asks for what would sharpen the search

**What to Expect**

1. Claude gets the ticket context and resolves the client. Without Autotask it asks only for the client and one concrete handle: a device name, an error message, a product or a task. If several organizations match, it lists them with IDs and asks
2. It searches document titles and content, then looks up the affected device and its related items (about 7 calls, quick mode about 4, capped at 12)
3. It reads the top 1 to 3 documents in full and presents each with its link, last updated date, why it applies and the relevant content, then a short "Not checked" line

Search covers document titles and text, not flexible assets, passwords or attachments, so "no matching document found" does not mean nothing is documented. One client per run.

**How to Invoke**

```
"Investigate ticket #1234 and find the relevant IT Glue documentation to troubleshoot."
"Is there a runbook for this ticket?"
"What do we have in IT Glue on a VPN failure at [client]?"
"Find the documentation for the firewall on this ticket. Keep it quick."
/itglue-ticket-documentation-finder
```

---

## itglue-update-docs-from-ticket

**Overview**

What a technician learns while resolving a ticket (a config change, a workaround, a corrected detail) belongs in the client's IT Glue documents, but copying it over by hand is the step that gets skipped. This skill finds the documents that should change, shows each proposed edit section by section, and writes them only after you approve.

**Benefits**

- Picks out only what changes the documentation and skips chatter and status updates
- Reads the document first, so each fact goes in one section and nothing already documented is added again
- Shows the current text and the new text side by side, and checks the document again just before writing in case a section changed
- Saves the edits as a draft, so readers keep seeing the last published version until someone publishes it. Ticket numbers and passwords are kept out of the text

**What to Expect**

1. Claude reads the ticket from Autotask, or asks you what changed. It resolves the client and picks up to 3 candidate documents (about 8 calls, capped at 15)
2. It reads the documents and proposes the edits: sections to change (before and after), sections to add, and sections left alone, plus what it did and did not read. You approve, edit or drop each document
3. After you approve, it writes each document once, one after another, and stops at the first failure. It reports the link and the sections changed, and that they are drafts

If no existing document fits, it does not create one and points to `/itglue-create-docs-from-ticket`. It cannot remove a section, publish or move a document, or add images. Up to 3 documents and one client per run.

**How to Invoke**

```
"Update the IT Glue documentation with the changes made in this ticket."
"The firewall rule changed. Update our network document."
"Add the new ISP circuit ID to the client's documentation."
"Update the IT Glue docs with what we changed in ticket 12345."
/itglue-update-docs-from-ticket
```

---

## itglue-create-docs-from-ticket

**Overview**

When a technician resolves a ticket, the issue, the work done and the result are worth keeping, but writing them up from scratch means the knowledge often stays in the ticket. This skill turns it into a new, structured document in the client's organization. It checks for an existing document first and creates nothing until you approve the exact title, folder and content.

**Benefits**

- Drafts a short, factual document from the ticket: a summary, the steps in order and the result, or another structure when the topic calls for it, such as a how-to
- Checks for an existing document on the topic first and points to `/itglue-update-docs-from-ticket` instead of creating a duplicate
- Names the document for what it is about (for example "FW-HQ-01 WAN2 failover setup"), and suggests a folder only when one clearly fits
- Creates the document unpublished, so someone reviews it in IT Glue before readers see it. Passwords and keys from the ticket are left out

**What to Expect**

1. Claude reads the ticket from Autotask, or asks you what to document, and stops if nothing is worth keeping. It resolves the client and searches that client's documents for the topic (about 8 calls, capped at 15)
2. It shows the organization, name, folder, source ticket and full content, plus what it did and did not read. You approve, edit or drop each document
3. After you approve, it creates each document once, one after another, and stops at the first failure. It reports the name, link, folder and section count, and that the document is unpublished

It cannot publish, delete or move a document, change its folder afterwards, or add images, so a wrong or duplicate document stays until someone removes it in IT Glue. Up to 3 documents and one client per run.

**How to Invoke**

```
"Document the work completed on ticket #1234."
"Write up this fix in IT Glue."
"Create a how-to from this ticket."
"Document the new VLAN we set up for [client]."
/itglue-create-docs-from-ticket
```
