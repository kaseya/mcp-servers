# Checklists

Read this before any write to `TicketChecklistItems` or
`TicketChecklistLibraries`. The workflow in `SKILL.md` applies to each of them.

## The checklist read

Step 1's read and Step 6's read are the same call: one `query_entity` on
`TicketChecklistItems` with `ticketID eq <id>`, `limit: 50`, and the fields
`id`, `itemName`, `position`, `isCompleted`, `isImportant`,
`completedByResourceID`, and `completedDateTime`.

A ticket holds up to 40 items, and the default limit of 25 can cut the
checklist off. Rows arrive in `id` order, which is not `position` order: sort
them by `position` before you show them.

After each write, report the checklist this way:

```
### Checklist — [done] of [N] complete

Open, important
- [position]. ⬜ [itemName]

Open
- [position]. ⬜ [itemName]

Complete: [done] items ([their positions]).
```

## Positions move without a write

A checklist item's `position` is not stable. Moving one item to position 1
moves the item there to position 2, and deleting the item at position 2 moves
every later item up by one. Neither of the moved items was written.

Never report positions from the rows held before the write. Report them from
Step 6's read.

A position the user names — "mark item 3 done" — refers to the checklist as
they last saw it. Read the checklist, find the item at that position, and name
it in the proposal: "item 3, _Back up the mailbox_: incomplete → complete".
Write to the item's `id`, never to its position.

## Completing an item stamps the API user

Setting `isCompleted: true` makes Autotask record the API user's own resource
as `completedByResourceID`, with the current time. It does not record the
technician the user is working for, and the field is read-only.

Say this in the proposal when the user is completing an item for someone else.

Un-completing an item is a separate Autotask permission from completing one.

## Applying a checklist library

A library is applied with `create_entity` on `TicketChecklistLibraries`, with
`ticketID` and `checklistLibraryID`. Find the library's id by name with
`query_entity` on `ChecklistLibraries` first.

- **Step 1's read is the ticket's checklist, not the library row.**
  `TicketChecklistLibraries` has no readable row, and `get_entity` refuses it.
  Read the checklist the apply will change, and show the user its current item
  count.
- Autotask appends the library's items after the ones already there. It does
  not merge or replace them.
- The create returns `id: null` and `item: null`. That is a success: the apply
  makes no row of its own. Read the checklist to show the user what it added.
- **Never re-send an apply.** A second apply appends every item again. When
  the apply fails or its answer is lost, read the checklist: the library's
  items at the end of it mean the apply landed.
- Autotask refuses a library of more than 40 items, an inactive library, and
  an apply that would take the ticket past 40 items.

## Limits

| Rule             | Detail                                            |
| ---------------- | ------------------------------------------------- |
| Items per ticket | 40. Count the checklist before proposing a batch. |
| `ticketID`       | Cannot change after create.                       |

## Deleting an item

`delete_entity` is permanent. Autotask keeps no undo, and a deleted checklist
item comes back only as a new item with a new id, and its completion stamp is
lost. State that in the proposal.

`delete_entity` returns the row it removed. A result of `found: false` means
no row had that id, so nothing was deleted: tell the user it was already gone,
and do not search for another row to delete in its place.

## Permission refusals

Autotask Security Levels govern viewing, adding, editing, deleting, and
un-completing checklist items separately. Applying a library also needs the
Application-wide (Shared) Features permission.

A refusal can arrive as `AUTHORIZATION_FAILED` or as an `UPSTREAM_ERROR`
carrying Autotask's own text. Read the text either way. When it names a
permission, report that the API user lacks it, and stop. No retry and no other
route changes a permission.
