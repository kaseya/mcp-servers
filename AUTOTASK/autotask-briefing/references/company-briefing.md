# Company briefing

The reader is deciding how to treat this customer today. Lead with the service
position, not with the address.

## Template

```
## [companyName]

### Summary
- **Type**: [companyType.label]
- **Owner**: [ownerResource.name, or "No owner assigned"]
- **Active**: [isActive]
- **Location**: [city, state, country]
- **Phone**: [phone]

### Open tickets ([N])
[Counts by status: e.g. New 4 · In Progress 7 · Waiting Customer 2]
[Then the 5 most recently active: ticketNumber — title — status — assigned to]
[Or: "No open tickets."]

### Contacts ([N])
[Per contact: name — email — phone — primary or not]
[Or: "No contacts on record for this company."]

### Contracts ([N])
[Per contract: name — type — status — start to end]
[Under an active Recurring Service contract whose dates contain today, per service, then per bundle:]
[  name — units this period — unit price]
[  Or: "No services or bundles on this contract."]
[Or: "No contracts found for this company."]

### Devices ([N])
[Count by type, then the count of inactive devices]
[Or: "No configuration items recorded."]

### Flags
[Anything the reader should act on — see below.]
[Or: "Nothing flagged."]
```

## Flags to raise

Raise a flag only when the condition is true. An empty Flags section is a
result, not a gap.

- **No active contract**, while open tickets exist. Work is being done without a
  recorded agreement.
- **No contacts on record.** Nobody can be reached about these tickets.
- **No owner resource.** The account is unassigned.
- **Every device inactive**, while the company is active.

## Judgment calls

**Ticket counts come from `search_tickets`.** It scopes by `companyId` and
defaults to open tickets. Set `status` to `any` only when the reader asked about
closed work.

**`companyMatchesTruncated` means the answer is incomplete.** When
`search_tickets` sets it true, say so. The ticket list does not cover every
matching company, and presenting it as complete would be wrong.

**Do not list every device.** A company may hold hundreds. Give counts by type
and name only the inactive ones, unless the reader asked for the inventory.
