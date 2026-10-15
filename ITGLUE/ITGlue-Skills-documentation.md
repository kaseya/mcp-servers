# IT Glue Skills

Three skills read from IT Glue and turn it into answers technicians, admins and account managers use every day. All three are read-only, work on one client at a time, and are deliberately light on API calls. They say plainly what IT Glue could not show, so a missing item is treated as a finding and not hidden.

| Skill | Built for | What you get | IT Glue calls |
|---|---|---|---|
| [itglue-organization-overview](#itglue-organization-overview) | Technicians | Site-visit pack: network gear, internet details, printers, site documents and ticket hints, with gaps flagged | About 10 (max 14). Quick mode about 4 |
| [itglue-hygiene-check](#itglue-hygiene-check) | Admins, service desk leads | Scorecard of one client's documentation quality plus what to fix first | 7 (13 with the optional check, max 15) |
| [itglue-environment-review](#itglue-environment-review) | Account managers, vCIOs | Documentation and Asset Health Review: lifecycle, security documentation, document age, recommended actions | About 14 (max 20). Quick mode about 7 |

A fourth skill, `itglue-skills-team-brief`, explains the other three (what each does, call costs, limits, example prompts). It makes no IT Glue calls. The original team brief is included as `itglue-plugin/itglue-skills-team-brief/itglue-skills-team-brief.docx`.

*Before using these skills, make sure the IT Glue MCP server is connected and the skills are installed. See the [Getting Started](../README.md#getting-started) section of the README.*

---

## Rules every skill follows

IT Glue throttles the whole account at 3,000 requests per 5 minutes, and other integrations already use most of that. The skills are designed to be gentle.

- **One client at a time.** A request for "all clients" is not run. The skill explains the cost, offers a shortlist of up to 5 clients with an estimate, and waits for a go-ahead.
- **No bursts.** At most 3 calls run in parallel.
- **Stops on the first error.** Any connector error is treated as a possible rate limit. The skill reports what it has, says what was skipped, and does not retry in a loop.
- **Counts, not row dumps.** Totals come from pagination data using page size 1. Other reads use small pages.
- **No repeat calls.** Anything already fetched in the conversation is reused.
- **Read-only, no credentials.** The skills never change IT Glue and never request passwords.
- **Honest reporting.** Every result says what was and was not checked, whether a figure is a total or a sample, and how many calls were used.

| Skill | Default run | Hard cap |
|---|---|---|
| Organization overview | About 10 calls (quick mode about 4) | 14 |
| Hygiene check | 7 calls (13 with the optional archived-reference check) | 15 |
| Environment review | About 14 calls, stated before it starts (quick mode about 7) | 20 |

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

## What the skills cannot do today

- **Locations, contacts and flexible assets are not readable.** The IT Glue tools read only assets and documents. Site addresses, directions, on-site contacts, ISP circuit records and AD or DNS details appear only if written into a document or asset notes. Otherwise they are flagged as not found.
- **Warranty and OS data need one lookup per device.** The environment review checks up to 5 key assets.
- **No estate-wide ticket ranking.** Tickets are read per device, so the overview ranks only devices it opens.
- **Document search matches titles only,** not content. "Not found" means no matching title, not that nothing is documented. MFA, MDM and antivirus findings are prompts to confirm, not proof.
- **PSA and RMM linkage cannot be counted,** and there is no IP address search.
- **No patching, alerts or backup status.** That data is not in IT Glue. Use the Datto RMM and Autotask skills.

## Status and what comes next

The hygiene check was tested live on one client in a QA instance. The organization overview and environment review were redesigned after the first round of feedback and have not yet been run live, because the IT Glue connector began returning errors during testing. Please try them and tell us what is missing or wrong.

With the Autotask and Datto RMM connectors, the overview gets a true ticket ranking and bulk device details, the hygiene check adds PSA and RMM linkage reconciliation, and the environment review covers warranty and operating systems for every device. IT Glue call budgets stay the same or shrink.
