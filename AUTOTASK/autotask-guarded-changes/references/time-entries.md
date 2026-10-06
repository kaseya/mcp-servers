# Time Entries

Read this before any create or update of a `TimeEntries` row. The workflow in
`SKILL.md` applies to it.

## Whose time it is

A time entry belongs to the person who did the work: its `resourceID` is that
person's Autotask resource. Autotask refuses an API-only user there, with
`API-only user cannot be selected for this field.`, and an API user is the
identity this connection authenticates as. So the connection itself can never
own a time entry, and nothing in the connection tells you who the user is.

- **The user has not named a technician.** Ask whose time it is before you
  read anything else. "As me", "my time", and "log this for me" name the person
  typing, not the API user, and you do not know who that person is until they
  say.
- **The user has named a technician.** Find that person in `Resources`.

## Find the resource

Query `Resources` by name — `firstName` and `lastName`, or `email` — with
`isActive eq true`, and widen `fields` to include `licenseType`.

- **No match, or more than one.** Show what you found and ask. Do not pick.
- **The match's `licenseType` is API User.** That resource cannot own the
  entry. Tell the user, and ask for the technician whose time it is.
- **One match with a user licence.** Use its `id` as `resourceID`.

Never use the resource that stamps the API user's own writes — the
`completedByResourceID` of a checklist item it completed, or the
`creatorResourceID` of a note it added. That resource is the API user.

## The proposal

Step 1's read is the ticket or task the time goes against: confirm that it
exists, and name it in the proposal. Then propose these fields together, as
Step 3 requires:

| Field                  | Value                                        |
| ---------------------- | -------------------------------------------- |
| `resourceID`           | The technician, by name and id               |
| `ticketID` or `taskID` | The work item, by number and title           |
| `dateWorked`           | The day the work was done; ask if not stated |
| `hoursWorked`          | In hours: 15 minutes is `0.25`               |
| `summaryNotes`         | What was done, in the user's words           |

Call `describe_entity` on `TimeEntries` for any other field Autotask requires
on this tenant, such as a role or a billing code.

## When Autotask refuses the create

`API-only user cannot be selected for this field.` means the `resourceID` is an
API user. No row was written. Do not send the create again with the same
resource. Ask the user whose time it is, and return to Step 3 with the new
resource.
