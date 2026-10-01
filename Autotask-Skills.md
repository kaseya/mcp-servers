####Autotask Skills
### Autotask Briefing

**Overview**

Before a technician works a ticket or an account manager jumps on a customer call, they typically have to open multiple tabs to get a full view of what is happening — pulling up the ticket, checking the contact, reviewing contracts, scanning note history. That's five minutes of setup before any real work begins, and it's easy to miss something logged in a different place.

This skill assembles the complete picture in one step, pulling everything attached to the record you name — ticket, company, contact, or device — and delivering it as a single structured briefing. When you only need one part of a ticket, such as its checklist or the other people and devices on it, it answers that question on its own without building the full briefing.

  *Before using this skill, make sure your MCP servers are connected and the skills are installed. See the [Getting Started](#getting-started) section of this README for setup instructions.*

**Benefits**
- Covers all four record types: tickets, companies, contacts, and devices
- Automatically searches across related notes, history, time entries, contracts, checklists, and linked contacts and devices
- Answers focused questions — "what's left on the checklist?", "who else is on this ticket?" — quickly, without pulling the whole record
- States clearly when a section has no data, so nothing looks like it was skipped
- Collapses automated workflow notes into a single count, so the human-written notes stand out
- Presents information the way a colleague would hand over work — what to act on first, not the order the data arrived

**What to Expect**
1. Claude finds the record you named and resolves it to a single match — if more than one comes back, it lists the options and asks you to confirm before going further. If nothing matches, it says so and stops
2. Claude decides how much to gather: a question about a ticket's checklist or its linked contacts and devices gets a focused answer; anything else gets the full briefing
3. Claude fans out to everything attached: notes, history, time entries, contracts, the linked device, checklist items, and any additional contacts and devices on the ticket — collecting up to 25 notes and history entries by default, with more available on request
4. A structured briefing is delivered for the record type you asked about, sorted chronologically, with every section included — even when there's nothing to report, Claude says so plainly


**How to Invoke**
```
"Brief me on ticket 12345"
"Give me everything on T20260918.0001"
"catch me up on this ticket"
"What do I need to know before working this ticket"
"What's left on the checklist for 12345"
"Which checklist items are still open"
"Who else is on this ticket"
"Which devices are linked to this ticket"
"Tell me about Acme Corp"
"Who is jane@acme.com and what are they waiting on?"
"What's the history on this laptop"
/autotask-briefing
```

### Autotask Guarded Changes 

**Overview**

Every update to an Autotask ticket can be time consuming, or simply a step that may get missed due to human error.

This skill governs every change to Autotask through Claude — creating, updating, or deleting records — by reading the current record first, showing you exactly what will change, and waiting for your confirmation before anything is written. It covers tickets, notes, time entries, contacts, checklist items and checklist libraries, and the additional contacts and devices linked to a ticket.

    *Before using this skill, make sure your MCP servers are connected and the skills are installed. See the [Getting Started](#getting-started) section of this README for setup instructions.*


**Benefits**
- Shows you the current value and the new value side by side before any change is made — no surprises
- Confirms that a field actually needs updating before writing it; if it already holds the right value, Claude says so and makes no change
- Checks Autotask's limits and ownership rules up front — such as the maximum number of checklist items or linked contacts on a ticket — so you hear about a problem before the write, not after a refusal
- Handles batches, like "mark items 2, 4, and 5 done", with a single confirmation, then sends each change one at a time and stops at the first failure
- Never retries a failed write, eliminating the risk of duplicate records, duplicated checklist items, or a locked-out API user
- Reports what Autotask actually saved after each write, not just what was sent

**What to Expect**
1. Claude fetches the current record so the proposal shows exactly what will change — for a checklist or a ticket's linked contacts and devices, it reads the full list. If the field already holds the right value, it says so and stops
2. Claude checks the change against Autotask's limits and ownership rules, and looks up the correct values for any dropdown field
3. A one-line-per-field summary is presented — entity, ID, field, old value, new value — or, for a delete, the record that will be removed. Downstream effects such as SLA timers, workflow rules, and notifications are called out for any status change. Claude waits for your confirmation before proceeding
4. Each write is made once. Claude reports what Autotask returned, not what was sent; for a batch, it tells you which changes landed, which failed, and which were never sent. For checklists and linked records, it re-reads the list, since one change can shift others
5. If a write fails, Claude reports it, reads the record back to show what it now holds, and stops — no retries, no workarounds. If Autotask rejects the credentials, Claude stops immediately to avoid locking out the API user
6. If your deployment is configured as read-only, Claude tells you so rather than looking for another way to make the change

**How to Invoke**
```
"Update ticket 12345"
"set this ticket to In Progress"
"Reassign this ticket to Dana"
"change the priority"
"Add a note to the ticket"
"Log 2 hours against this ticket"
"Create a ticket for Acme Corp"
"Mark checklist item 3 done"
"Apply the onboarding checklist"
"Add Jane to this ticket"
"Link this laptop to the ticket"
"Unlink that laptop from the ticket"
/autotask-guarded-changes
```