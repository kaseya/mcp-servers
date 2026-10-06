---
name: autotask-guarded-changes
description: >
  Guards every change to Autotask data through the Autotask MCP server: reads
  the record first, proposes the change for the user to confirm, sends each
  write once, and reports what Autotask holds afterwards. Covers creating or
  updating a ticket, a note, a time entry, a contact, a checklist item, or any
  other entity, and deleting a checklist item or a ticket's link to an
  additional contact or device. Use this skill whenever the user asks to change
  Autotask data: "update ticket 12345", "set this ticket to In Progress",
  "reassign this to Dana", "change the priority", "add a note to the ticket",
  "log 2 hours against this", "create a ticket for Acme", "mark checklist item
  3 done", "apply the onboarding checklist", "add Jane to this ticket", "link
  this laptop to the ticket", "unlink that laptop from the ticket", or any
  request that ends in a create, update, or delete call. Use it before the
  write, not after it.
---

# Autotask Guarded Changes

Every change follows one workflow. Copy it into your response and tick each
step as it completes:

```
Change progress:
- [ ] 1. Read the record. For a checklist or a link, read that scope.
- [ ] 2. Check the change: value already set? Limit reached? Ownership?
- [ ] 3. Show the proposal: one line per field, old value → new value.
- [ ] 4. Wait for the user to confirm.
- [ ] 5. Send each write once.
- [ ] 6. Report what the server returned. For a checklist or a link, read the scope again.
```

Two conditions stop the workflow at any step: **a write fails**, and **the
credentials are rejected**. Both are described after the steps.

## Step 1 — Read the record

Fetch the current row first: `get_ticket` for a ticket, `get_entity` otherwise.

Without it there is no old value, so the proposal reads "set status to In
Progress" instead of "status: New → In Progress". The second tells the user
whether the change is needed at all. The first does not.

A change to a checklist, to a ticket's links, or to a time entry reads more
than one row. Read the reference file for it before this step:

| The change touches                                                 | Read                                 |
| ------------------------------------------------------------------ | ------------------------------------ |
| `TicketChecklistItems` or `TicketChecklistLibraries`               | `references/checklists.md`           |
| `TicketAdditionalContacts` or `TicketAdditionalConfigurationItems` | `references/ticket-relationships.md` |
| `TimeEntries`                                                      | `references/time-entries.md`         |
| Any other entity, including a ticket's own fields                  | None of them                         |

## Step 2 — Check the change

- **The value is already set.** If the read shows the field already holds the
  requested value, say so and make no write.
- **A limit is reached.** Autotask refuses a write past its limits. Count what
  the record already holds, and tell the user before the write rather than
  after the refusal.
- **Ownership.** A link to a contact or a device has an ownership rule.
  `references/ticket-relationships.md` gives the check. A time entry belongs
  to the person whose time it is, never to the API user;
  `references/time-entries.md` gives the check.
- **A picklist value.** Call `describe_entity` and use the picklist value's id,
  not its label. Labels are configured per tenant; ids are what the write takes.

## Step 3 — Show the proposal

Present one line per field: entity, id, field, old value, new value. For a
delete, present the row that will be removed instead.

Status changes carry downstream effects the write itself does not show — SLA
timers, workflow rules, and notifications. Name that in the proposal when the
field being changed is status.

## Step 4 — Wait for the user to confirm

Then stop and wait. The confirmation belongs to the user. Do not infer it from
an earlier instruction, and do not treat a request to "just do it" as covering
fields the user has not seen.

## Step 5 — Send each write once

A batch — "mark items 2, 4, and 5 done" — is confirmed once, as one proposal,
and then sent one write at a time. Wait for each write's answer before sending
the next. The first failure stops the batch: send nothing after it.

**Autotask decides required-field completeness.** This server validates field
names, types, and operators. It does not check that every field Autotask
requires on create is present — Autotask makes that call at write time. A
rejection naming a missing or invalid field is Autotask's answer, not a defect
in the request. Read the message, add what it names, and return to Step 3 with
the revised proposal. Do not work around it, and do not guess the field list.

## Step 6 — Report what the server returned

`update_entity` and `create_entity` both read the row back and return it.
Report the returned values, not the values that were sent. `delete_entity`
returns the row as it stood before the delete; report that as what was removed.

For a batch, name which writes landed, which one failed, and which were never
sent.

For a checklist or a link, read that scope again and report it, as the
reference file describes. A write can move rows it did not touch.

## Stop — a write fails

**Do not send it again.** Report the failure, read the record back, and tell
the user what it now holds.

Mutations do not retry at the transport layer, and that is deliberate. A
disconnect after the request body was sent is ambiguous: the write may have
succeeded. Autotask also signals some validation failures with a `500`, which
looks transient and is not. So a second attempt either duplicates a write that
already succeeded — a second create makes a second record, and a second
checklist library apply appends every item again — or spends another attempt
on a request that will never be accepted.

Never re-send a write to check whether it worked. The read-back is the check.

## Stop — the credentials are rejected

Report it and stop. Make no further call with those credentials.

Repeated failed authentication locks the tenant's Autotask API user out of the
API, which breaks every caller using that credential, not only this session.

## When the write tools are absent

A deployment with its write switch closed does not register `create_entity`,
`update_entity`, or `delete_entity` at all, so they are missing from the tool
list rather than refusing at call time.

If the write tools are not listed, the deployment is read-only. Tell the user
that, and do not look for another route to the same change.
