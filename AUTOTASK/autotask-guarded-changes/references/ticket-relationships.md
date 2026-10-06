# Ticket relationships

Read this before any write to `TicketAdditionalContacts` or
`TicketAdditionalConfigurationItems` — adding a contact or a device to a
ticket beyond its primary one, or removing it. The workflow in `SKILL.md`
applies to each of them.

## The relationships read

Step 1's read and Step 6's read are the same calls:

1. `get_ticket`, for the ticket's company and its primary contact.
2. `get_entity` on `Tickets` with `fields: ["id", "configurationItemID"]`, for
   the primary device. `get_ticket` does not return it.
3. `get_entity` on `Companies` for the ticket's company, with
   `fields: ["id", "companyName", "parentCompanyID"]`.
4. `query_entity` on `TicketAdditionalContacts` and on
   `TicketAdditionalConfigurationItems`, each by `ticketID eq <id>`, with
   `limit: 50` and `limit: 100`.

Link rows carry bare ids. Name them with one `query_entity` on `Contacts` and
one on `ConfigurationItems`, with `id in [<ids>]` and explicit `fields`.

## The ownership check

Autotask accepts a link only to a contact or a device it considers owned by the
ticket's company, and the rule differs between the two:

| Link               | Autotask accepts                                        |
| ------------------ | ------------------------------------------------------- |
| Additional contact | A contact of the ticket's company or its parent company |
| Additional device  | A device of the ticket's company alone                  |

Check ownership before you propose the link, so the proposal names the problem
instead of Autotask's refusal naming it after the write:

1. Read the relationships scope above. It gives the ticket's company, its
   `parentCompanyID`, the primary contact and device, and the current links.
2. Find what the user names with a filter that states the rule. A contact's
   name is `firstName` and `lastName`; a device's name is `referenceTitle`, and
   a `ConfigurationItems` row has no `name` field.
   - A contact: `companyID in [<company id>, <parent company id>]`, or
     `companyID eq <company id>` when the company has no parent.
   - A device: `companyID eq <company id>`. A device of the parent company is
     refused.
3. **One match.** Check that it is not the primary, not already linked, and
   within the limit, and for a device that `isActive` is true. Then propose.
4. **No match.** Do not stop at "not found": the user named something that
   usually exists, in the wrong company. Search once more by the same name
   without the company filter, then answer:
   - Found in another company: name that company, say that Autotask refuses
     the link and why, and propose no write. "Tom Lee belongs to Globex, not
     Acme Corp or its parent company. Autotask refuses a link to a contact of
     any other company." "NW-SRV-02 belongs to Northwind Holdings, the
     parent company of Northwind Ltd. Autotask links a device only from the
     ticket's own company."
   - Found nowhere: say so, and ask the user to check the name.
5. **Several matches.** List them and stop. Do not guess which one the user
   meant.

Autotask still decides whatever the check does not cover. It answers a refused
link with a `500`, which the server relays as `UPSTREAM_ERROR` carrying
Autotask's text. That `500` is a validation failure, not a transient one: the
stop condition for a failed write applies.

**Autotask's device refusal names the two ids the wrong way round.** It reads
"The configurationItemID [<ticket id>] cannot be associated with ticketID
[<device id>] because they are not associated to the same Company." When you
report it, name the ticket and the device from your own request, never from
the refusal text.

## Limits and rules

Autotask enforces these at write time. The server does not check them first,
so a write past a limit is Autotask's refusal, not a defect.

| Entity                               | Limit and rules                                                                                            |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `TicketAdditionalContacts`           | 30 per ticket. The ticket's primary contact cannot also be an additional one.                              |
| `TicketAdditionalConfigurationItems` | 100 per ticket. The device must be active and not the ticket's primary device. Each device is linked once. |

Count the links the ticket already holds before proposing a batch that could
pass a limit.

## Removing a link

To detach a contact or a device, delete the **link row**, never the contact or
the device. Find the link row's id with one `query_entity` on
`TicketAdditionalContacts` with `ticketID` and `contactID`, or on
`TicketAdditionalConfigurationItems` with `ticketID` and `configurationItemID`.
The link row's own `id` is what `delete_entity` takes.

`delete_entity` is permanent, and returns the row it removed. A result of
`found: false` means no row had that id, so nothing was deleted: tell the user
it was already gone, and do not search for another row to delete in its place.

## Permission refusals

A refusal can arrive as `AUTHORIZATION_FAILED` or as an `UPSTREAM_ERROR`
carrying Autotask's own text. Read the text either way. When it names a
permission, report that the API user lacks it, and stop. No retry and no other
route changes a permission.
