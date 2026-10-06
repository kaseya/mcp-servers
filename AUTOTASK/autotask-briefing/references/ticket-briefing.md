# Ticket briefing

## Overdue check

Before writing anything else, compare the ticket's `dueDate` to today's date.
When `isComplete` is false and `dueDate` has passed, open the briefing with:

> ⚠️ **OVERDUE** — due [date], now [N] days past due.

A complete ticket is never overdue, whatever its due date says.

## Template

```
## Ticket [ticketNumber] — [title]

### Summary
- **Status**: [status.label]
- **Priority**: [priority.label]
- **Type**: [ticketType.label]
- **Queue**: [queue.label]
- **Company**: [company.name]
- **Assigned to**: [assignedResource.name, or "Unassigned"]
- **Created**: [createdDate]
- **Due**: [dueDate] [⚠️ OVERDUE — N days, when applicable]
- **Last activity**: [lastActivityDate]

### Description
[description, or "None provided."]

### Resolution
[resolution, or "Not resolved."]

### Contact
[name — email — phone]
[Or: "No contact attached to this ticket."]

### Additional contacts ([N])
[Per contact: name — email]
[Or: "No additional contacts on this ticket."]

### Linked device
[type — location — install date — active or inactive]
[Or: "No device linked to this ticket."]

### Additional devices ([N])
[Per device: name — active or inactive]
[Or: "No additional devices on this ticket."]

### Checklist ([done] of [N] complete)
[In position order. Per item: ✅ or ⬜ — name — "important" when flagged]
[Per completed item: completed by [completedByResourceID.name] on [completedDateTime]]
[Or: "No checklist on this ticket."]

### Time logged
[Total: X.X hours worked, Y.Y billable, across N entries]
[Per entry: date — resource — hours — summary]
[Or: "No time logged."]

### Contracts
[Per contract: name — type — status — start to end]
[Under an active Recurring Service contract whose dates contain today, per service, then per bundle:]
[  name — units this period — unit price]
[  Or: "No services or bundles on this contract."]
[Or: "No contracts found for this company."]

### Notes ([N])
[Oldest first. Per note: date — type — title, then the description.]
[N workflow rule notifications fired.]
[Or: "No notes on this ticket."]

### Change history ([N])
[Per entry: date — field — old value → new value]
[Or: "No field changes recorded."]
```

## Scoped briefings

A scoped briefing prints the header and one section. It follows the same
judgment calls as the full template, below.

### Checklist scope

```
## Ticket [ticketNumber] — [title] ([status.label])

### Checklist — [done] of [N] complete

Open, important
- [position]. ⬜ [itemName]

Open
- [position]. ⬜ [itemName]

Complete: [done] items ([their positions]). Ask to see who completed them, and when.
```

- The number is the item's `position`, so "mark item 4 done" refers to this
  list. Sort each group by `position`.
- Leave out a group that has no items.
- Complete items appear as a count with their positions. Print who completed
  them, and when, only when the reader asks, with the judgment call on the API
  user below.
- A ticket with no checklist, a checklist with every item complete, and a
  complete ticket with open items each get one sentence in place of the lists.

### Relationships scope

```
## Ticket [ticketNumber] — [title] ([status.label])
Company: [company.name]

### Contacts
Primary: [name — email, or "None"]
Additional ([N] of 30 allowed):
- [name — email]

### Devices
Primary: [referenceTitle — active or inactive, or "None"]
Additional ([N] of 100 allowed):
- [referenceTitle — active or inactive]
```

- Print the primary contact and device beside the additional ones: Autotask
  refuses a primary as an additional link, so the reader needs both to plan a
  change.
- Print the count against each limit even when it is zero.
- When a link query returns no rows, print "None" under that heading.

## Judgment calls

**A picklist `label` of `null`** means the value is inactive or beyond the
schema's bound. Print the raw `value` and mark it inactive. Do not print
"null".

**A reference with no `name` key** means no display name was resolved — the
lookup budget ran out, the lookup failed, or the type is not enriched. Print the
id and say the name was not resolved. An absent `name` is not an empty name.

**More than 10 notes**: show the most recent 10 in full and summarise the rest
as one line, for example "5 earlier notes not shown". Recent activity is what
the reader acts on.

**Checklist order is `position`, not arrival order.** Rows arrive in ascending
`id` order, and a reordered or library-applied checklist has ids out of step
with positions. Sort by `position` before writing the section.

**The checklist completer may be the API user.** An item completed through
the API records the API user's own resource as `completedByResourceID`, not the
technician who did the work. Print the name as returned, and do not describe
it as the person who did the task.

**Open checklist items are what the reader acts on.** When the ticket is open
and items remain, name the first incomplete item in the opening lines of the
briefing.

**Billable versus worked hours**: `hoursWorked` is the time spent and
`hoursToBill` is the time charged. Report both. They differ, and the difference
matters to whoever reads the briefing next.
