---
name: itglue-organization-overview
description: Build a site-visit pack for an MSP client from IT Glue, so a technician arrives knowing what is on site. Use whenever a technician or admin says they are going onsite, heading to a site visit, or asks "what do I need for [client or site]", "give me an overview of [client]", "what network gear is at [site]", "who is the ISP at [client]", or "which client has this serial number, MAC address or asset tag", even if they never say "overview" or "IT Glue". Covers site location hints, network gear with brand and model, rack or closet, ISP and circuit details, printers, directory and DNS or DHCP, most-ticketed devices, connections, and site-specific documents, and flags whatever is missing. Not for ticket or call preparation. About 10 IT Glue calls (4 in quick mode) because the account's API limit is shared and nearly full.
---

# IT Glue organization overview (site-visit pack)

A technician heading to a site needs the things that are hardest to find once they are standing in a closet: where the gear is, what it is, who the ISP is, and who to call. This skill gathers what IT Glue can show and, just as important, tells the technician what is **not** documented so they can ask before they leave.

## What the tools can and cannot read

Be upfront about this in every result. The IT Glue tools read configurations (assets) and documents. They cannot read Locations, Contacts, or Flexible Assets directly.

| Needed on site | Where it can come from | Reliability |
|---|---|---|
| Site name | The location name on each asset | Good |
| Address, directions, on-site contacts | A document, if someone wrote one | Only if documented. Otherwise say "not readable through current tools, check Locations and Contacts in IT Glue" |
| Network gear, brand and model | Asset type and name (list), then manufacturer and model (single-record lookup) | Good for the devices you open |
| Rack or closet | Asset notes or the location name | Only if documented |
| ISP, circuit ID, support number | A document, asset notes, or records linked to the firewall or router | Only if documented. Report names of linked records as links, because their content cannot be read |
| Printers, model and location | Asset type and location (list), model (single-record lookup) | Good |
| AD type, DNS, DHCP | A document or asset notes | Only if documented |
| Tickets | Single-record lookup of a device | Per device only |
| Connections | Single-record lookup of a device | Only if documented |

A missing item is a **finding**. For ISP and circuit details especially, "not found" is the most useful thing the technician can hear before an outage.

## Call budget (read first)

IT Glue throttles the whole account (documented at 3,000 requests per 5 minutes) and other integrations already use most of it.

**Default: about 10 calls, never exceed 14. Quick mode: about 4.** Use quick mode when the user says quick, short, or "just the basics": it skips steps 4 and the document reads.

- At most 3 calls in parallel.
- Treat any error as a possible rate limit, including the generic "connector returned an error or an invalid response". Stop, report what you have, and say what was skipped. Do not retry in a loop.
- Reuse anything already fetched in this conversation.
- Use the page sizes given below. Never request 250-row pages here.
- Never include `passwords`.

## Procedure

**1. Resolve the client** (1 call). `search_organizations`, page size 5. If several plausible matches exist (names repeat across organization IDs), list them with IDs and ask which. Make no further calls until it is settled.

**2. Asset listing** (1 call, 2 at most). `list_configurations` with `archived: false`, that organization, page size 100, `sort: name`. Use page 2 only if the total is 200 or less and the first page did not cover the site. If the total is larger, say the view covers the first 200 assets by name.
- Tally the distinct location names. If the user did not name a site and there is more than one location, show the names and ask which one. Spend no more calls until they answer.
- Keep the assets whose location matches the site.
- Classify them by type name: firewall, router, switch, wireless or access point, printer, server, internet or ISP or circuit or modem, anti-virus.
- List rows do not include manufacturer, model, notes, or contact. Those need step 4.

**3. Documents** (1 call plus up to 2 reads). `list_documents` with `document_folder_id: "null"`, page size 50. Scan the titles locally for: the site name, "site", "location", "access", "directions", "contacts", "on-call", "internet", "ISP", "circuit", "WAN", "carrier", "rack", "closet", "MDF", "IDF", "network", "diagram", "Active Directory", "DNS", "DHCP". Read at most 2 documents with `get_document`, choosing site-specific titles first, then the best ISP or circuit match. Summarize them; never paste them.
- If the organization has more than 50 documents, add one `search_documents` for the site name and say the listing covered the first 50 only.
- Document search matches titles, not content. If nothing matches, say "no document with a matching title", never "nothing is documented".

**4. Key devices** (up to 5 calls, skipped in quick mode). Open, in this order: the firewall or router at the site, the main switch, a second switch or an access point, then one printer. For each, call `get_configuration` with `include` set to `related_items`, `to_configuration_connections`, `from_configuration_connections`, and `tickets`. Report manufacturer, model, serial number, IP address, notes (look for rack or closet text), and contact name.
- `related_items` lists documents and flexible asset records that mention the device. Show their titles as links. A record titled like an internet circuit is a strong lead for ISP details.
- Count the tickets returned per device.

## Most-ticketed devices

Rank only the devices you opened in step 4, and say so: "Most-ticketed among the 5 devices opened." Sideloading tickets across a whole page of assets was tried and failed in testing, and one lookup per asset across the estate would be too many calls. A true estate-wide ranking needs the ticketing connector.

## Output

Keep it to one page for the technician.

**[Client] / [Site]**
- **Where and who:** site name; address, directions and on-site contacts if a document gave them (name the document), otherwise the "not readable" note; contact names seen on assets.
- **Network at this site:** a table of device, type, brand and model, rack or closet, IP. Name the other devices you did not open, with links.
- **Internet:** ISP, circuit ID, support number, or **NOT FOUND, add before the next outage**, plus any linked circuit records as links.
- **Printers:** model and location.
- **Directory and DNS or DHCP:** one line, or "not documented in readable sources".
- **Most-ticketed devices:** from step 4, with counts and the limit noted.
- **Connections:** what the key devices connect to. If none are documented, say "no connections documented" and treat it as a gap.
- **Site documents:** titles with links, only those specific to the site or organization.
- **Not checked:** what was skipped, whether any list is partial, and "IT Glue calls used: N".

## Device lookup

If the user gives only a serial number, MAC address, or asset tag, call `list_configurations` once with that single filter and no organization, page size 10. Several matches mean duplicated documentation: list each with client, name, type, and archived flag, and ask which to open. There is no IP address filter, so for an IP ask for a hostname, serial, or client name instead of scanning. MACs are stored as typed, so try the other separator once before saying not found.

## When ticketing and RMM connectors are available

Replace the per-device ticket counts with a true ranking and open tickets for the site. Fill brand, model, and OS in bulk from the RMM instead of opening devices one by one, and add device health and last-seen. The IT Glue budget stays the same, since the new sources use their own calls.
