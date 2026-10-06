---
name: autotask-briefing
description: >
  Assembles a briefing on one Autotask record — a ticket, company, contact, or
  device — and everything attached to it, or on one section of a ticket: its
  checklist, or the other contacts and devices on it. Use this skill when the
  user asks to understand, summarise, or get context on a record — "brief me on
  ticket 12345", "give me everything on T20260918.0001", "catch me up on this
  ticket", "what do I need to know before working this ticket", "tell me about
  Acme Corp", "who is jane@acme.com and what are they waiting on", "what's the
  history on this laptop" — and when the user asks about one section of a
  ticket: "what's left on the checklist for 12345", "which checklist items are
  still open", "who else is on this ticket", "which devices are linked to this
  ticket". Use it whenever a request needs more than one field of one record.
---

# Autotask Briefing

Assemble one briefing that answers the reader's next three questions before they
ask them. The reader is a technician or an account manager, not a database user.

The pattern is the same for every record type:

1. Find the anchor record.
2. Decide the scope: the whole record, or one section of a ticket.
3. Fan out to the records that scope needs.
4. Write the briefing, stating what is absent as plainly as what is present.

## Step 1 — Find the anchor

Identify which of the four anchors the request names, then resolve it to a
numeric id.

| Anchor  | How to find it                                                                                                                                 |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Ticket  | `get_ticket` with the numeric id. For a `T…` number, call `search_tickets` with `ticketNumber` first, then `get_ticket` with the id it returns |
| Company | `query_entity` on `Companies`, field `companyName`, operator `contains`                                                                        |
| Contact | `query_entity` on `Contacts`, filtering on `firstName`, `lastName`, or `emailAddress`                                                          |
| Device  | `query_entity` on `ConfigurationItems`, filtering on `referenceTitle` (its name), `serialNumber`, or `companyID`                               |

When the anchor query returns more than one match, stop and list the matches.
Do not guess which one the reader meant, and do not brief all of them.

When the anchor query returns nothing, say so and stop. An empty anchor is not
an empty briefing.

## Step 2 — Decide the scope

A request about one section of a ticket gets a **scoped briefing**: the
briefing header and that section alone. A full briefing is eight or more
queries for a question that one or two answer.

| The request asks about                           | Scope         | Queries                                                                                                                                                 |
| ------------------------------------------------ | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The checklist — what is left, what is done       | Checklist     | `get_ticket`, then `TicketChecklistItems`                                                                                                               |
| The other people or devices on the ticket        | Relationships | `get_ticket`; `get_entity` on `Tickets` for `configurationItemID`; the two link queries; one naming query on `Contacts` and one on `ConfigurationItems` |
| The ticket as a whole, or anything else about it | Full          | Every ticket row of the table in Step 3                                                                                                                 |

The relationships scope names the primary device and the additional devices in
the same `ConfigurationItems` query, with `id in [<primary>, <additional ids>]`.

Companies, contacts, and devices are always briefed in full.

## Step 3 — Fan out

Issue calls against one entity one at a time; calls against different entities
may run in parallel, as every tool description states. Three kinds of call
wait for another call's answer, because they need an id it returns:

- A naming query waits for the query whose ids it names.
- The linked device's query waits for the `get_entity` call that returns its id.
- The contract-service queries wait for the `Contracts` query.

| Anchor  | Fan out to                           | Filter                                             |
| ------- | ------------------------------------ | -------------------------------------------------- |
| Ticket  | `TicketNotes`                        | `ticketID eq <id>`                                 |
| Ticket  | `TicketHistory`                      | `ticketID eq <id>`                                 |
| Ticket  | `TimeEntries`                        | `ticketID eq <id>`                                 |
| Ticket  | `Contracts`                          | `companyID eq <company.id>`                        |
| Ticket  | The contract services                | See "contract services" below                      |
| Ticket  | `ConfigurationItems`                 | `id eq <configurationItemID>` — see the note below |
| Ticket  | `TicketChecklistItems`               | `ticketID eq <id>`, with `fields` — see below      |
| Ticket  | `TicketAdditionalContacts`           | `ticketID eq <id>`, then name them — see below     |
| Ticket  | `TicketAdditionalConfigurationItems` | `ticketID eq <id>`, then name them — see below     |
| Company | `Contacts`                           | `companyID eq <id>`                                |
| Company | tickets, via `search_tickets`        | `companyId`                                        |
| Company | `Contracts`                          | `companyID eq <id>`                                |
| Company | The contract services                | See "contract services" below                      |
| Company | `ConfigurationItems`                 | `companyID eq <id>`                                |
| Contact | `Companies`                          | `id eq <companyID>`                                |
| Contact | `Tickets`                            | `contactID eq <id>`                                |
| Device  | `Companies`                          | `id eq <companyID>`                                |
| Device  | `Tickets`                            | `configurationItemID eq <id>`                      |

**The ticket's linked device needs an extra call.** `get_ticket` returns the
ticket's company, contact, queue, and status, but not its
`configurationItemID`. To reach the device, call `get_entity` on `Tickets` with
the ticket id and an explicit `fields` list naming `configurationItemID` — the
default projection returns eight fields and will not include it.

**The additional contacts and devices arrive as bare ids.** A
`TicketAdditionalContacts` row carries `contactID` as `{ "id": n }` with no
name, and a `TicketAdditionalConfigurationItems` row does the same with
`configurationItemID`. Name them with one more query each, with `id in [<the ids>]`
and an explicit `fields` list:

- `Contacts` — `id`, `firstName`, `lastName`, `emailAddress`
- `ConfigurationItems` — `id`, `referenceTitle`, `isActive`

Skip that query when the link query returned no rows.

**The checklist query needs a `fields` list too.** The default projection omits
`completedDateTime`, which the template prints. Request `id`, `itemName`,
`position`, `isCompleted`, `isImportant`, `completedByResourceID`, and
`completedDateTime`.

**The contract services wait for the `Contracts` query.** Read what a contract
covers only when its `contractType` is 7 (Recurring Service), its `status` is 1
(Active), and its `startDate` and `endDate` contain today. Only a Recurring
Service contract carries services, and an active contract can still have
ended. Print every other contract by name, type, status, and dates alone, and
do not query its services. With `<ids>` the ids of the contracts that qualify:

1. `ContractServices`, with `contractID in [<ids>]` and `fields` `id`,
   `contractID`, `serviceID`, `unitPrice`.
2. `ContractServiceBundles`, with `contractID in [<ids>]` and `fields` `id`,
   `contractID`, `serviceBundleID`, `unitPrice`.
3. `ContractServiceUnits`, with `contractID in [<ids>]`,
   `startDate lte <today>`, `endDate gte <today>`, and `fields` `id`,
   `contractServiceID`, `units`, `startDate`, `endDate`.
4. `ContractServiceBundleUnits`, with the same filters and `fields` `id`,
   `contractServiceBundleID`, `units`, `startDate`, `endDate`.
5. `Services`, with `id in [<the serviceID values>]` and `fields` `id`, `name`.
6. `ServiceBundles`, with `id in [<the serviceBundleID values>]` and `fields`
   `id`, `name`.

Queries 1 to 4 may run in parallel. Query 5 waits for query 1, and query 6
waits for query 2. Skip a naming query when the query it waits for returned no
rows.

- **Name every service from `Services`, and every bundle from
  `ServiceBundles`.** A service row names its service only by `serviceID`, and
  its `invoiceDescription` is often empty.
- **A unit row exists for every billing period** of the contract, past and
  future, so the unit queries never run without the two date filters.
- **Match a unit row to its service row by `contractServiceID`**, and a bundle
  unit row by `contractServiceBundleID`, never by `serviceID`: one contract may
  carry the same service more than once.
- **A service with no unit row for today** is printed with "no units recorded
  for this period". Do not print a count from another period.

The default projection returns eight fields chosen from each tenant's own
schema, and it can omit `emailAddress` from `Contacts` and `referenceTitle`
from `ConfigurationItems`. Name every field the template prints.

Request 25 records at most for notes and for history. Request 50 for the
checklist and the additional contacts, and 100 for the additional devices:
Autotask allows at most 40, 30, and 100 of them on one ticket, so one page
holds them all. The default of 25 cuts off a long checklist. Ask for more notes
or history only when the reader asks. Request 100 for each contract-service
query, and follow `nextPage` when `hasMore` is true.

## Step 4 — Write the briefing

Read the template for the anchor being briefed:

- Ticket, in any scope — `references/ticket-briefing.md`
- Company — `references/company-briefing.md`
- Contact — `references/contact-briefing.md`
- Device — `references/device-briefing.md`

## Rules that apply to every briefing

**Honest empty sections.** Write every section of the template, even when its
data is absent, and state the absence in a short sentence. A section that is
missing is indistinguishable from a section that was never checked, and the
reader cannot tell which.

**No query sorts the rows.** The query grammar carries no sort parameter, and
rows arrive in ascending `id` order. Produce a chronological view by sorting the
rows after they arrive. Never tell the reader the query returned them in order.

**Filterability is set per tenant.** `contactID`, `configurationItemID`, and
`contractID` are filterable only when the tenant's live schema says so. When a
filter is refused, call `describe_entity` on that entity and report what the
schema permits. Never treat a refused filter as a result of zero rows.

**Collapse system-generated notes.** Workflow rule notes rarely carry
actionable content. Report them as one line giving the count, and list the
human-written notes in full.

**Truncate long text at roughly 200 characters** and mark it `(truncated)`. The
reader can ask for the full text of one record.

**Price, not cost.** Print the `unitPrice` of each service and bundle row.
Print a cost or a margin only when the reader asks for one, and only then add
`unitCost` to the `fields` of the `ContractServices` query and of the
`ServiceBundles` naming query. A bundle row carries no cost of its own, so a
bundle's cost is its standard cost from `ServiceBundles`: say so beside it.
Internal cost is commercially sensitive inside the MSP, and a briefing is
handed to other people.

**Write like a colleague handing over work.** Lead with what the reader must act
on. Facts in the order they would ask for them, not in the order the queries ran.

**Curated tools before generic ones.** Use `get_ticket`, `search_tickets`, and
`add_ticket_note` where they fit, and `query_entity` or `get_entity` for
everything else.
