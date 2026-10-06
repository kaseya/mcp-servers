# Device briefing

The reader wants to know whether this device is the problem. Lead with its
ticket history, not with its specification.

## Template

```
## [referenceTitle or configurationItemType] — [company name]

### Summary
- **Type**: [configurationItemType.label]
- **Serial number**: [serialNumber, or "Not recorded"]
- **Location**: [location, or "Not recorded"]
- **Domain**: [domain, or "Not recorded"]
- **Installed**: [installDate]
- **Warranty expires**: [warrantyExpirationDate, or "Not recorded"]
- **Active**: [isActive]
- **Company**: [company name]

### Ticket history ([N])
[Per ticket, most recent first: ticketNumber — title — status — created — completed]
[Or: "No tickets reference this device."]

### Flags
[Anything the reader should act on — see below.]
[Or: "Nothing flagged."]
```

## Flags to raise

- **A recurring fault.** Three or more tickets in the last 90 days suggests the
  device, not the user, is the cause. Say how many and over what period.
- **The device is inactive**, but has an open ticket.
- **The warranty has expired**, and an open ticket exists. A repair decision may
  depend on this.
- **An open ticket is overdue.**

## Judgment calls

**Ticket search needs `query_entity` here.** `search_tickets` cannot scope by
device, so query `Tickets` with `configurationItemID eq <id>`.

**Count the recurrence, do not assert the cause.** Three tickets in 90 days is
a pattern worth naming. It is not proof the hardware is faulty, and the briefing
should not say it is.

**A device search may match several rows.** Serial numbers are unique, names are
not. When more than one row matches, list the matches and stop.
