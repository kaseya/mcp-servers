---
name: itglue-hygiene-check
description: Run a light documentation quality check on ONE client in IT Glue and say what to fix first. Covers missing serial numbers and asset tags, assets not marked Active, stale records, archived assets, document freshness, and duplicated identifiers. Use whenever an admin, service desk lead, or account manager asks to audit, clean up, health-check, or score the documentation for a client, asks "how complete is the documentation for X", "what should we fix in IT Glue", or wants to verify a newly onboarded client, even if they do not say "audit". Count-based, about 7 calls by default (13 with options), so use this instead of ad-hoc querying, because the account's API limit is shared and runs close to full.
---

# IT Glue hygiene check (one client)

An admin wants to know how trustworthy one client's documentation is and where to start fixing it. This skill answers that with counts and a short sample, not a full export.

## Why this is one client at a time

IT Glue's API limit (documented at 3,000 requests per 5 minutes) covers the whole account and is shared with other integrations that already use most of it. A full-instance audit means hundreds of calls. One client costs about 7. If someone asks for "all clients", do not start. See "Portfolio requests".

**Budget: the default run is 7 calls, optional extras bring it to 13, never exceed 15.** Rules:

- Run at most 3 calls in parallel.
- Treat any error as a possible rate limit, including the generic "connector returned an error or an invalid response". Stop, report what you have, and say what was skipped. No retry loops.
- Count with `page size 1` and read `pagination.total_count`. Do not read rows just to count them.
- Reuse anything already fetched in this conversation.
- Never include `passwords`.

## Procedure

**1. Resolve the client** (1 call). `search_organizations`, page size 5. Names repeat across organization IDs, so if more than one plausible match appears, list them with IDs and ask. Make no further calls until it is settled.

**2. Stale sample** (1 call). `list_configurations` for that organization with `archived: false`, `sort: updated_at` (ascending, so the stalest come first), page size 15. The pagination total is the live asset count. From this sample, note the type mix and find the ID of the status named "Active". Status IDs differ per tenant, so never hard-code one. If no sampled record has an Active status, skip step 4 and say so.

**3. Identifier gaps** (2 calls). Same organization, `archived: false`, page size 1:
- `serial_number: "null"` gives the count with no serial number.
- `asset_tag: "null"` gives the count with no asset tag.

**4. Not marked Active** (1 call). Same organization, `archived: false`, `configuration_status_id` set to the Active ID from step 2, page size 1. Not marked Active equals live total minus this count. The `null` trick does **not** work for status (the API rejects it), so this subtraction is the honest way. Label it "not marked Active", because it includes Inactive as well as unset.

**5. Archived assets** (1 call). `archived: true`, page size 25. The total is the archived count. Note any that were archived recently.

**6. Documents** (1 call). `list_documents` with `document_folder_id: "null"` (all folders), page size 50. Listings include `updated_at` and `archived`, but there is no sort option, so you only see the first 50. If the total is higher, say "first 50 of N". Report how many were last updated more than 12 months ago, how many are archived, and whether several documents share the same name (copy-pasted templates and failed imports often leave a pile of identical titles). This check costs no extra call.

That is 7 calls.

**Optional, only if the user asks or accepts the offer:**
- **Archived assets still referenced** (up to 5 calls). Run `get_configuration` on the most recently updated archived assets with `include` set to `related_items`, `to_configuration_connections`, `from_configuration_connections`. A returned `included` list means something still points at the asset. Say how many of how many you opened.
- **Gap examples** (1 call). One page of up to 50 records with `serial_number: "null"` so the user can see which types are affected. Treat it as a sample.

## How to read the results

Blank is not always wrong. Virtual machines, cloud resources, and some network gear legitimately have no serial number. So:

- Report gaps as **candidates**, grouped by type where the sample shows it.
- Weight the findings. A high missing-serial rate on physical servers and workstations matters. The same rate on cloud or virtual types usually does not.
- Rough guide for the headline: under 20% missing is healthy, 20 to 50% needs a plan, over 50% means the field is effectively unused.
- If sampled records share the same serial number, flag the duplicate. It usually means cloned documentation.

## Output

Use this structure and keep it to one screen:

**Documentation health: [client]** (checked [date])
- **Scorecard:** live assets, missing serial %, missing asset tag %, not marked Active %, archived count, documents not updated in 12 months, documents sharing a name.
- **Fix first:** three to five actions in priority order, each with a one-line reason and effort (small, medium, large).
- **Stalest records:** the oldest few from the sample, with links.
- **Not checked:** what was skipped, whether any figure is a sample, and "IT Glue calls used: N".

Then offer, with its cost stated: the archived-reference check, a spreadsheet of gap examples, or a dashboard page.

## Newly onboarded clients

If the user asks to check recently onboarded clients, call `list_organizations` once with a `created_at` filter (for example `"2026-07-01, *"`) and `sort: -created_at`, page size 10. Show the list and ask which one to check. Run the procedure for **one** organization at a time.

## Portfolio requests

If asked to check all clients, do not run it. Explain that it is roughly 7 calls per client against a shared limit. Offer a shortlist of at most 5 clients (the most recently updated, from one `list_organizations` call), give the estimate, and wait for an explicit go-ahead. Run them one after another, not in parallel.

## Limits to state when relevant

- PSA and RMM linkage cannot be counted. The API rejects `null` for those filters. Do not guess a figure.
- Warranty and manufacturer data exist only on single-record lookups, so this skill does not report them.
- This skill reads only. It never changes IT Glue.

## When ticketing and RMM connectors are available

Add PSA and RMM linkage reconciliation (devices in IT Glue with no matching record, and the reverse). That is the check the IT Glue API cannot do alone, and the connectors make it possible without extra IT Glue calls.
