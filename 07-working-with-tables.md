# Working with tables in Kaseya Insights

> **DRAFT for Technical Writing.** Kaseya Insights is not yet implemented. This article describes Alpha design intent taken from the published Alpha PRDs. Verify every navigation path, UI label and message string against a build before publication. See `kb-technical-writer-handover-2026-10-06.md`.

**Security and navigation**

NAVIGATION  Header > Insights  `[CONFIRM against a build]`

PERMISSIONS  Kaseya Insights

Every list page in Kaseya Insights uses the same table. Learn it once and it works the same way on Endpoints, Tickets, Organizations, Technicians and the detail pages.

NOTE  The Service Delivery page has no table. Its widgets link through to the Tickets, Technicians or Organizations page with a filter applied.

## Parts of the table

| Part | Where | What it does |
|---|---|---|
| Title and information icon | Card header, left | Hovering the icon shows what the table contains |
| Filter summary | Card header, right | Reads `N filters active · Clear all` when filters are applied, hidden otherwise |
| Filter pills | Card header, right | The quick filters for this table |
| Search field | Below the header | Free text search |
| Column selector | Below the header, right | Choose which columns are shown |
| Footer | Below the table | `Showing X-Y of N items`, page navigation, and an items-per-page selector |

Which columns and which filters a table has is decided per page. Refer to Kaseya Insights pages reference.

## How to...

### Filter a table

To filter a table, do the following:

1. Click a filter pill in the card header. A list of values opens, each with a check box.
2. Select one or more values.

   `[SCREENSHOT: a filter pill open with values selected]`

3. Click outside the list to close it.

The table filters immediately. With one value selected the pill reads `Label: Value`. With more than one it reads `Label: N Selected`.

NOTE  Every filter is multi-select and there is no **All** option. Clearing every check box means the filter is not applied.

To remove every filter on that table at once, click **Clear all** in the filter summary.

TIP  Where a table has more filters than fit inline, the first few are shown and the rest are under **More filters**.

### Search a table

Type in the search field below the card header. Search is free text and not case sensitive.

Search and filters combine - a row must match the search **and** every applied filter to appear.

NOTE  Some tables search a single field rather than the whole row. The Endpoints table, for example, searches endpoint names only. Refer to Kaseya Insights pages reference.

### Choose which columns are shown

To choose which columns are shown, do the following:

1. Click the column selector icon below the card header.
2. Select or clear the check box beside each column.

   `[SCREENSHOT: column selector open]`

3. Click outside the list to close it.

Your choice is saved for you, per table, and is still there when you return.

IMPORTANT  The first column identifies the record and cannot be hidden. At least two columns must stay visible - the identifier plus one more. Once a table is down to two, the remaining check boxes are disabled.

There is no upper limit. If the columns you enable are wider than the window, the table scrolls sideways rather than squeezing or dropping them, and the identifier column stays in view while you scroll.

NOTE  Some columns are hidden by default and are found through the column selector. Switching between real-time and historical changes which columns exist, so your column choices are re-applied from that view's default set.

### Sort a table

Click a column header to sort by it. Clicking again reverses the sort, and clicking a third time removes it.

NOTE  Columns whose values are not naturally alphabetical - health bands, priorities, SLA statuses - sort by severity, most severe first, rather than alphabetically. Ties are broken alphabetically by name.

### Open a record

Click anywhere on a row to open that record's detail page.

NOTE  Rows are clickable only where a detail page exists. In this release that means Organizations and technicians. The Endpoints table has no detail page, so its rows are not clickable and show no hover highlight.

Clicking a link inside a cell acts on that link and does not open the row.

### Move between pages of results

Use the page navigation in the footer. The items-per-page selector sets how many rows are shown at a time.

## Understanding a column

Hover a column title to see what the column measures. The tooltip carries the column's definition and, where the column shows health bands, the band legend. Refer to Understanding metrics in Kaseya Insights.

## When a table shows nothing

| What you see | What it means |
|---|---|
| **No [entity] found** with the body **No results for the selected period** | The table has no qualifying data. The title and filters stay on screen |
| An explicit no-results message with a way to clear the filter or search | Your filter or search combination matched no rows. There is data - the filter is hiding it |
| A full-page message instead of the table | The whole page has no data. Refer to Kaseya Insights states and troubleshooting |

## Table settings are separate from the page controls

The Organization scope and the time range in the page header are global and apply to every Insights page.

A table's own search text, filter pills and hidden columns are not. They belong to that table, are remembered separately, and are unaffected when you change the Organization scope or the time range. Refer to Setting the Organization scope and time range.
