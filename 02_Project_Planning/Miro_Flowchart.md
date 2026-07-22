# Miro Planning Flowchart — BrightTV Case Study

Miro itself isn't something that can be built through this tool, so this document gives you the exact flow to recreate on a Miro board (free-form canvas, ~10 minutes to build), plus a reference diagram (`Miro_Flowchart_Reference.svg` in this folder) you can drop straight onto the board as a sticky-note-style guide or just screenshot into Miro as a background reference.

## Recommended board layout (left to right, 4 swimlanes)

**Swimlane 1 — Planning**
1. `Kickoff: CEO objective — grow subscription base`
2. `Define CVM questions (usage trends, consumption drivers, low-day content, growth initiatives)`
3. `Scope deliverables (SQL, Excel, 3x dashboards, presentation)`

**Swimlane 2 — Data Processing**
4. `Receive raw data (User Profiles + Viewership, 2 tables)`
5. `Identify data quality issues (duplicate ID column, channel name variants, nulls, Age=0 placeholders)`
6. `Write SQL: clean + transform (Databricks)`
7. `Build session-level fact table + subscriber-level dimension table`

**Swimlane 3 — Analysis & Dashboards**
8. `Excel: KPIs, pivot tables, charts (5 pages)`
9. `Power BI dashboard`
10. `Looker Studio dashboard`
11. `Databricks dashboard`
12. `Lovable web dashboard`

**Swimlane 4 — Delivery**
13. `Synthesize insights & recommendations`
14. `Build final presentation`
15. `Present to CVM team / CEO`
16. `Publish to GitHub portfolio`

## Arrows / connections

- Linear flow 1 → 2 → 3 → ... → 16 within and across swimlanes as listed above.
- Branch: step 7 fans out into steps 8, 9, 10, 11, 12 (all four dashboards + Excel are built in parallel from the same two cleaned tables).
- All of 8–12 converge into step 13 (insights are synthesized from all analysis outputs, not just one).

## Suggested sticky-note colors (Miro)

- Yellow = Planning
- Blue = Data Processing
- Green = Analysis & Dashboards
- Pink = Delivery

## Steps to build in Miro

1. Create a new Miro board → use the **Flowchart** template or a blank board.
2. Add 4 horizontal swimlanes (Miro's "Frame" or table feature), labeled as above.
3. Add one sticky note per step listed above, color-coded by swimlane.
4. Connect them with arrows in the order given, including the fan-out/fan-in around steps 7–13.
5. Export the board as PNG/PDF and add it into this folder alongside this file for the final submission.
