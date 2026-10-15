---
name: itglue-skills-team-brief
description: Explain the three IT Glue Claude skills (organization overview, hygiene check, client environment review) to technicians, admins, account managers and vCIOs. Use whenever someone asks what the IT Glue skills are, which one to use, how many API calls they cost, what they cannot do, what to type to trigger them, how they protect the shared IT Glue API limit, or asks for the team brief, an onboarding summary, or example prompts, even if they do not say "skill". This skill only explains. It makes no IT Glue calls. To actually run a check, use the matching skill (itglue-organization-overview, itglue-hygiene-check, itglue-environment-review).
---

# IT Glue skills: team brief

Answer questions about the three IT Glue skills using the facts below. This skill makes **no IT Glue calls**. If the user wants a result for a client, point them to the right skill (or invoke it) instead of answering from this brief. Keep answers short and match the question: if they ask which skill to use, name one and give an example prompt, and do not paste the whole brief.

## At a glance

Three Claude skills read from IT Glue and turn it into answers for technicians, admins and account managers. All three are read-only, work on one client at a time, and are deliberately light on API calls. They say plainly what IT Glue could not show, so a missing item is treated as a finding and not hidden.

| Skill | Built for | What you get | IT Glue calls |
|---|---|---|---|
| `itglue-organization-overview` | Technicians | Site-visit pack: network gear, internet details, printers, site documents and ticket hints, with gaps flagged | About 10 (max 14). Quick mode about 4 |
| `itglue-hygiene-check` | Admins, service desk leads | Scorecard of one client's documentation quality plus a short list of what to fix first | 7 (13 with the optional check, max 15) |
| `itglue-environment-review` | Account managers, vCIOs | Documentation and Asset Health Review: lifecycle, security documentation, document age, recommended actions | About 14 (max 20). Quick mode about 7 |

## Why they matter

- **Technicians arrive prepared.** The overview gathers what is hardest to find in a closet: network gear at the site, the ISP, and which documents apply. It also finds a device by serial number, MAC address or asset tag across all clients.
- **Documentation we can trust.** The hygiene check measures missing serial numbers and asset tags, stale documents and duplicates, so cleanup is prioritized by evidence.
- **Reviews that show what to fix.** The environment review shows warranty and end-of-life exposure, security documentation and document health, with actions.
- **One method for everyone.** Same steps and output format each time.
- **A shared resource stays protected.** IT Glue throttles the whole account at 3,000 requests per 5 minutes and other integrations already use most of it.

## Rules every skill follows

- **One client at a time.** A request for "all clients" is not run. The skill explains the cost, offers a shortlist of up to 5 clients with an estimate, and waits for a go-ahead.
- **No bursts.** At most 3 calls in parallel.
- **Stops on the first error.** Any connector error is treated as a possible rate limit. Report what was gathered, say what was skipped, no retry loops.
- **Counts, not row dumps.** Totals come from pagination data using page size 1. Other reads use small pages.
- **No repeat calls.** Anything already fetched in the conversation is reused.
- **Read-only, no credentials.** Never changes IT Glue, never requests passwords.
- **Honest reporting.** Say what was and was not checked, whether a figure is a total or a sample, and how many calls were used. Client-facing reviews are framed constructively, but figures are never softened or left out.

## What they cannot do today

- **Locations, contacts and flexible assets are not readable.** The IT Glue tools read only assets and documents. Site addresses, directions, on-site contacts, ISP circuit records and AD or DNS details appear only if written into a document or asset notes. Otherwise they are flagged as not found.
- **Warranty and OS data need one lookup per device.** The environment review checks up to 5 key assets and says so.
- **No estate-wide ticket ranking.** Tickets can be read per device, so the overview ranks only devices it opens. A true ranking comes with the Autotask connector.
- **Document search matches titles only,** not content. "Not found" means no matching title, not that nothing is documented.
- **PSA and RMM linkage cannot be counted,** and there is no IP address search.
- **No patching, alerts or backup status.** That data is not in IT Glue. It arrives with the Autotask and Datto RMM connectors.

## Using the skills

### 1. Organization overview (`itglue-organization-overview`)

Use when heading to a client site, needing to know what is installed there, or finding which client owns a device.

Example prompts:
- "I'm going onsite to [client], [site name]. What do I need to know?"
- "Give me an overview of [client] for a site visit. Keep it quick."
- "What network gear is at [site] for [client], and who is their ISP?"
- "Which client has the device with serial number [serial]?"
- "Which printers are at [client], and where are they?"

Output: a one-page pack covering site name (plus address, directions and contacts when a document gives them), network gear with brand, model and rack or closet, ISP and circuit details, printers, a one-line directory and DNS or DHCP summary, most-ticketed devices among those opened, connections, and site-specific documents. Missing items are called out.

Good to know:
- With several sites it asks which one first. Naming the site up front saves a step.
- Quick mode (about 4 calls) skips device lookups and document reads and returns the asset list and the documents to open.
- Duplicate serial numbers are flagged, which usually means cloned documentation.

### 2. Hygiene check (`itglue-hygiene-check`)

Use to learn how trustworthy one client's documentation is, what to fix first, or whether a newly onboarded client was documented properly.

Example prompts:
- "How complete is the documentation for [client]?"
- "Run a hygiene check on [client] and tell me what to fix first."
- "We just onboarded [client]. Is their documentation in decent shape?"
- "Check [client] and see whether any archived assets are still referenced."
- "Which recently onboarded clients should I check first?"

Output: a scorecard (live assets, % missing serial number, % missing asset tag, % not marked Active, archived count, documents not updated in 12 months, documents sharing a name), a prioritized "fix first" list, and the stalest records with links.

Example from testing: one QA client with 250 live assets had 28% with no serial number and 78% with no asset tag. All 16 documents were over a year old and 11 shared one title. That took 6 calls.

Good to know:
- A blank serial number is not always wrong (VMs and cloud resources often have none), so gaps are reported as candidates.
- The optional archived-reference check opens up to 5 archived assets to see whether other records still point at them.
- For recently onboarded clients it lists them and asks you to pick one.

### 3. Client environment review (`itglue-environment-review`)

Use when preparing an account review, renewal meeting or client summary. It is a Documentation and Asset Health Review, not a QBR.

Example prompts:
- "Prepare a client environment review for [client]."
- "I have a renewal meeting with [client] on Thursday. Show me the state of their environment."
- "Which of [client]'s key assets are out of warranty or on an unsupported OS?"
- "Prepare a client-facing review for [client] as a Word document."
- "Prepare a review for [client]. I already ran a hygiene check, so reuse it."

Output: a two-page report with summary, environment at a glance, lifecycle (warranty expirations, operating systems past end of life), security documentation (MFA, MDM, antivirus), documentation health (documents over 12 months old, duplicate titles), data quality, recommended actions, and an explicit "not covered" section. Delivered as Word, PDF or slides on request.

Good to know:
- Warranty and OS findings cover up to 5 key assets (servers and network gear first) and say "N of M checked". The Datto RMM connector will extend this to every device.
- MFA, MDM and antivirus findings read "not found in document titles or asset types we can read". Treat them as prompts to confirm, not proof.
- Ask whether the audience is internal or the client. A client-facing version frames gaps as a plan but keeps every figure as measured.
- It is the heaviest skill, so it states the call count before starting. Reusing a recent hygiene check saves calls.

## Status and what comes next

- **Status.** The hygiene check was tested live on one client in the QA instance. The organization overview and environment review were redesigned after the first round of feedback and have not been run live, because the IT Glue connector began returning errors during testing. Invite users to try them and report what is missing or wrong.
- **Next.** With the Autotask and Datto RMM connectors, the overview gets a true ticket ranking and bulk device details, the hygiene check adds PSA and RMM linkage reconciliation, and the environment review covers warranty and OS for every device plus ticket and patch data. IT Glue call budgets stay the same or shrink.
