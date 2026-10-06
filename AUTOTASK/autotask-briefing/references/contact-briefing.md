# Contact briefing

The reader is about to speak to this person. Tell them who the person is and
what the person is waiting on.

## Template

```
## [firstName lastName] — [company name]

### Summary
- **Title**: [title, or "Not recorded"]
- **Email**: [emailAddress]
- **Phone**: [phone] / [mobilePhone]
- **Company**: [company name]
- **Active**: [isActive]

### Open tickets ([N])
[Per ticket, most recently active first: ticketNumber — title — status — assigned to — last activity]
[Or: "No open tickets raised by this contact."]

### Recently closed ([N])
[Per ticket: ticketNumber — title — completed date]
[Or: "No recently closed tickets."]

### Flags
[Anything the reader should know before the call — see below.]
[Or: "Nothing flagged."]
```

## Flags to raise

- **The contact is inactive**, but has open tickets.
- **The contact's company is inactive.**
- **An open ticket is overdue.** Name it. This is the most likely reason the
  person is calling.
- **An open ticket is unassigned.** Nobody is working it.

## Judgment calls

**Ticket search needs `query_entity` here.** `search_tickets` cannot scope by
contact, so query `Tickets` with `contactID eq <id>`.

**Separate open from closed using `completedDate`.** A ticket with no
completion date is open. Do not infer completion from a status label — status
picklists are configured per tenant, so no status id means "complete"
everywhere.

**Name resolution, not name guessing.** When a ticket's `assignedResource`
carries no `name` key, print the id and say the name was not resolved.
