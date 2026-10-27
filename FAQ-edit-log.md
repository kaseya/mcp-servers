# FAQ edit log

This log maps each yellow-highlighted row in `MCP_Servers_FAQ.docx` to its row in the updated `README.md` FAQ table. The Word doc row numbers count from the header row (row 0).

## Summary

- **Highlighted rows processed:** 30 (rows 2, 5, 6, 13, 14, 15, 16, 20, 24, 26, 28, 30, 31, 35, 36, 37, 39, 40, 41, 42, 44, 45, 47, 48, 49, 50, 51, 52, 53, 54).
- **README FAQ table:** 41 rows total (11 existing and 30 new). Docx row 16 updates an existing row instead of adding one, and docx row 14 is split into two rows.
- **Not included:** Row 17 (only its "In Repo?" cell is highlighted, not the question or answer), rows already in the README, and rows that still need research.
- **Removed from every row:** The Notes column (attendee names and session references) and time-specific details, such as session dates.

## Row-by-row changes

| Docx row | README category | README question (shortened) | Key edits |
|---|---|---|---|
| 2 | Roadmap, identity, and security | Is an MCP gateway planned...? | Simplified the answer, spelled out RBAC, kept the interim workaround, and dropped "described as temporary." |
| 5 | Roadmap, identity, and security | Can I limit what each individual user can do...? | Shortened the question (examples removed), cut "design partners" and "charge-back," and removed the runtime sentence that repeats row 2. |
| 6 | Roadmap, identity, and security | What is the limit for calls...? | Wording only. |
| 13 | Setup and connectivity - Autotask | Why is my Autotask MCP server URL not accepted...? | Turned the statement into a question. Added the `/mcp` requirement and example from the README. Removed "the team said they would add this." |
| 14 | Setup and connectivity - IT Glue | Two rows: availability and region; credential error | Split into two questions. Removed regional release dates and the note about Australian accounts. |
| 15 | Setup and connectivity - Datto RMM | Is the Datto RMM MCP server available in my region? | Reworded as a direct question and answer. |
| 16 | Setup and connectivity - Datto RMM | Why is the Datto RMM MCP server installed in the Organization settings...? | Updated the existing README row. The old answer cut off mid-sentence, so I completed it. Clarified the question. |
| 20 | Setup and connectivity | Is there documentation for setting up skills...? | Aligned with README Step 2 (**Plugins** in the left sidebar) instead of the older Settings path. Removed the "four files" detail. |
| 24 | Setup and connectivity | Where do I generate the API keys...? | Linked to `GENERATING-API-KEYS.md`. |
| 26 | Setup and connectivity - Datto RMM | ...403 Forbidden error... | Added bold UI labels and shortened the steps. |
| 28 | Capabilities and limitations - Autotask | Can the MCP do a global notes search? | Spelled out UI and named the autotask-briefing skill. |
| 30 | Capabilities and limitations - Autotask | Can the MCP audit my workflow rules? | Removed the "clean up the mess" aside. |
| 31 | Capabilities and limitations - Autotask | Can a workflow change the company on a ticket? | Led with the answer and removed "help article to be sent separately." |
| 35 | Capabilities and limitations | ...update IT Glue documentation from ticket information...? | Changed "In this pre-alpha" to "Currently." |
| 36 | Capabilities and limitations - Autotask | Can I create a dashboard to share with a client? | Light edit. |
| 37 | Capabilities and limitations - Autotask | Can the MCP export data... to Excel? | Light edit. |
| 39 | Capabilities and limitations | What skills does Kaseya provide...? | Replaced the "()" and "linked here" placeholders with links to the Skills section and the product folders. |
| 40 | Capabilities and limitations | Can I control which actions Claude can take...? | Applied the dropdown and bold-label style rules. |
| 41 | Capabilities and limitations | Are there example prompts...? | Replaced "Ex: RMM linked here" with links to all three product folders. |
| 42 | Capabilities and limitations | Can I build my own skills...? | Spelled out KB, named Claude Cowork, and removed the show-and-tell date. |
| 44 | Capabilities and limitations | Why does my output... look different...? | Light edit. See open item 4. |
| 45 | Other AI platforms, strategy, and community | Can I use the MCP servers with Copilot Studio...? | Condensed it into one clear answer. See open item 7. |
| 47 | Other AI platforms, strategy, and community | Why does Kaseya offer an MCP...? | Changed "vs." to "instead of." |
| 48 | Other AI platforms, strategy, and community | What is the roadmap beyond the alpha...? | Replaced "MVP" with "first version" and dropped "lessons learned" from the question. See open item 2. |
| 49 | Other AI platforms, strategy, and community | Do MCP calls count against my hourly API call limit...? | Rewrote the question so it matches the answer. See open item 8. |
| 50 | Other AI platforms, strategy, and community | How should I share skills and prompts...? | Used the contact email already in the README and removed the date. |
| 51 | Program, support, and feedback | When are office hours...? | Removed the start date. |
| 52 | Program, support, and feedback | How do I contact the team...? | Added the Calendly link and removed the "week of Oct 26" request. |
| 53 | Program, support, and feedback | Will I get a recording...? | Linked to Getting Started instead of repeating the steps. |
| 54 | Kaseya Insights | What is Kaseya Insights...? | Spelled out K1, APAC, and EMEA. |

## Other changes to existing README rows

- **Category labels:** I changed "Roadmap, identity and security" to "Roadmap, identity, and security" in the three existing rows (Oxford comma). I also changed the existing RMM category to "Setup and connectivity - Datto RMM" so all Datto RMM rows group together.
- **Existing rows left alone:** I did not change any other existing rows, even where I noticed issues (see open item 6).

## Open items

1. **Show-and-tell dates conflict.** Row 42 says the week of Oct 26, and row 50 says Oct 30. I removed the dates and pointed to Discord.
2. **Forward-looking statements.** Several answers state timelines or commitments: gateway "early FY27," identity improvements "early FY27 through Q2 FY27," Copilot support "FY27," API features in "6 to 9 months," and the Insights alpha in "mid-November." The Word doc is internally inconsistent (row 45 also says "Q1 2027"). The existing README row says "H1 FY27" for unified APIs. Please confirm these with the PMs, and with legal if needed.
3. **Row 16 premise.** The question says the MCP is installed in the Organization settings, but the answer says you cannot install it at the organization level. Please confirm what the question means. The answer also says the Datto RMM client runs locally, while the existing README row says the extension "does not do anything on your desktop." Clarify so security-minded readers aren't confused.
4. **Row 44 source.** The Word doc notes call this a customer tip, not official guidance. Confirm before publishing.
5. **Terminology.** The sources mix "pre-alpha," "alpha," and "early access." I used "alpha" and "early access," except in the Teams channel name, which includes "pre-alpha."
6. **Existing README issues I did not change.** The "different platform" row has "CLaude" and "creating" (should be "created"). The "What do I need" row has "pre-reqs" and a `#Getting-started` that is not a link. The Autotask endpoint row links to `Generation-API-Keys.md` (should be `GENERATING-API-KEYS.md`). The Autotask skill links use two different file names (`Autotask-Skills.md` and `Autotask-Skills-documentation.md`), so I linked product folders instead.
7. **Row 45 overlaps an existing row.** The existing "different platform than Claude" row covers similar ground. Consider merging the two.
8. **Row 49 inference.** The source says only that MCP servers are free. I added that calls are subject to your account's API throttling limit, based on row 6. Also confirm that the pricing statement is approved.
9. **Row 5 and IT Glue passwords.** The original question asks about blocking IT Glue passwords from the AI platform, but the source answer doesn't address it. The README IT Glue tool list contains no password tool, but confirm with the IT Glue PM before stating it.
10. **Row 13 overlap.** It overlaps with the existing Autotask endpoint row, which also says the URL needs `https://`.
11. **UI labels to verify.** **Configure**, **Needs Approval**, **Always Allow**, **Setup** > **Users**, **Security Level**, **Sites**, **View**, **Plugins**, and **Skills**.
12. **"In Repo?" column.** Row 16 says "No," but the README already has a version of it.
