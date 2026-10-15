---
name: itglue-environment-review
description: Produce a Documentation and Asset Health Review for one client from IT Glue, covering asset inventory by type, warranty expirations, operating systems past end of life, whether MFA, MDM and antivirus are documented, documents older than 12 months, duplicate document titles, and a prioritized action list. Use whenever an account manager, vCIO, or admin asks for a client environment review, account review, health review, renewal prep, "state of the environment", or a client-facing summary of what is documented, even if they only say "prepare something for my meeting with X". If someone calls it a QBR, still use this skill and explain it covers documentation and asset health only. About 14 IT Glue calls (7 in quick mode), capped at 20, so state the plan first. The account's API limit is shared and nearly full.
---

# IT Glue client environment review

An account manager needs something they can put in front of a client or use to plan the next quarter: what is in the environment, how well it is documented, and what to do about it. This skill builds a **Documentation and Asset Health Review** from IT Glue and is honest about what IT Glue cannot show.

It is not a QBR. A QBR also needs tickets, SLA performance, patching, and security posture, which are not in IT Glue. Use the title "Documentation and Asset Health Review" in every output.

## Why it states a plan first

IT Glue throttles the whole account (documented at 3,000 requests per 5 minutes) and other integrations already use most of it. This is the heaviest skill, so it runs for **one client** and says what it will cost.

**Default: about 14 calls, never exceed 20. Quick mode: about 7.** Before the first call say: "This will use about 14 IT Glue calls for [client]. Starting now." Use quick mode when the user asks for something fast or light. It skips the type counts and the key-asset lookups (steps 3 and 6).

- At most 3 calls in parallel.
- Treat any error as a possible rate limit, including the generic "connector returned an error or an invalid response". Stop, report what you have, and mark the unfinished sections "not completed". Do not retry in a loop.
- Count with `page size 1` and read `pagination.total_count`.
- Reuse anything already fetched in this conversation. If a hygiene check was run for this client, reuse its identifier gap and archived figures and skip step 5.
- Never include `passwords`.

## Procedure

1. **Resolve the client** (1 call). `search_organizations`, page size 5. If several plausible matches exist, list them with IDs and ask which.
2. **Asset sample** (1 call). `list_configurations`, `archived: false`, `sort: -updated_at`, page size 50. The pagination total is the live asset count. Note the type names and IDs, the ID of the status named "Active" (status IDs differ per tenant, never hard-code one), and any type named like anti-virus, endpoint, MDM, or MFA.
3. **Inventory by type** (up to 3 calls). Count the three most frequent types in the sample with `configuration_type_id`, `archived: false`, page size 1. Report everything else as "Other types" (total minus the three). Say the types were chosen from the 50 most recently updated assets.
4. **Status** (1 call). `configuration_status_id` set to the Active ID, page size 1. Not marked Active equals total minus this count.
5. **Identifier gaps** (2 calls). `serial_number: "null"` and `asset_tag: "null"`, page size 1.
6. **Key assets for lifecycle** (up to 5 calls). Pick up to 5: servers first, then firewalls, routers, and switches, preferring ones with a serial number. Call `get_configuration` on each with no `include`. Record warranty expiry, operating system, manufacturer, model, purchase and install dates, and any firmware text in the notes.
7. **Documents** (1 call). `list_documents` with `document_folder_id: "null"`, page size 50. Report the total, how many were last updated more than 12 months ago, how many are archived, and every title that appears more than once. If the total is above 50, say "first 50 of N" and add up to 3 `search_documents` calls for "MFA", "MDM", and "antivirus" so the security check is not blind.

## What to report, and how to word it

**Lifecycle (key assets only).** List warranty expiry with status as of today: expired, expiring within 90 days, or in warranty, and "no date recorded" where blank. For each distinct operating system, state its end-of-life date and whether it is past it. Use what you know, and run a web search to confirm any date you are not certain of, then name the source. Report firmware only if the notes mention it, otherwise "firmware not documented". Always say "N of M assets checked, chosen as the most important": warranty and OS data exist only on single-record lookups, so the whole estate cannot be checked without an RMM.

**MFA, MDM, and antivirus.** Look in three places: document titles (MFA, 2FA, multi-factor, Duo, Authenticator, MDM, Intune, Jamf, device management, antivirus, endpoint, EDR), asset type names in the sample, and the search results from step 7 if you ran them. Word findings as **"not found in document titles or asset types we can read"**, never "not documented". Flexible assets and document contents cannot be searched, so a real policy could still exist. Recommend confirming, and make it an action item either way.

**Documents.** Count older than 12 months, count archived, and list duplicate titles with how many copies each has (for example one title used 11 times usually means a failed import or copied template).

## Report structure

Use this exact structure and keep it to about two pages:

1. **Summary**: three sentences and three headline numbers (live assets, share with a serial number and asset tag, documents over 12 months old).
2. **Environment at a glance**: table of type, count, and share, ending with "Other types".
3. **Lifecycle**: warranty and operating system or firmware findings, with the "N of M assets" note.
4. **Security documentation**: MFA, MDM, antivirus, with the title-only wording above.
5. **Documentation health**: document age, archived count, duplicate titles, folder structure.
6. **Data quality**: missing serial %, missing asset tag %, not marked Active %. Note that blank serials on virtual or cloud types are often legitimate.
7. **Recommended actions**: three to five items in priority order, each with the reason and effort (small, medium, large).
8. **Not covered**: tickets, patching, alerts, backup success, SLA performance, locations, contacts, flexible assets, and warranty or OS data for assets outside the checked set. Do not pad this section.

End with "Prepared [date]. Source: IT Glue."

## Audience: internal or client-facing

Default to **internal**: plain figures and direct recommendations. If the user says it goes to the client, switch to **client-facing**: frame gaps as a plan ("we will complete serial numbers for physical servers by [quarter]") and leave out test records and internal jargon. In both versions report the figures exactly as measured. Never soften or omit a number. If the numbers are poor, say so and let the recommendations carry the message. Keep the call count out of a client-facing version and put it in the chat reply instead.

## Format

Deliver in whatever format the user names (Word, PDF, slides). If they name none, produce a readable document page. One simple bar for assets by type is enough as a chart.

## When ticketing and RMM connectors are available

The review becomes much stronger. The RMM can supply warranty and OS for every device, so section 3 covers the whole estate instead of 5 assets and step 6 can be skipped. Add ticket volume and top categories to section 2, patch and alert data to section 6, and PSA/RMM linkage gaps to section 6. The IT Glue budget shrinks, and the connectors add their own calls.
