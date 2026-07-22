# BrightTV Dashboard — Databricks Dashboard Build Guide

This dashboard is built directly on the two tables produced by `BrightTV_Analysis.sql` in Databricks — no export/import needed, since the data already lives in your workspace.

## Setup

1. Run `BrightTV_Analysis.sql` in a Databricks SQL editor (or notebook) against your workspace, and save each of the two result sets as tables:
   - `workspace.default.brighttv_fact_viewership` (Query 1 output — session grain, 10,000 rows)
   - `workspace.default.brighttv_dim_subscribers` (Query 2 output — subscriber grain, 5,375 rows)

   ```sql
   CREATE OR REPLACE TABLE workspace.default.brighttv_fact_viewership AS
   -- paste Query 1 here

   CREATE OR REPLACE TABLE workspace.default.brighttv_dim_subscribers AS
   -- paste Query 2 here
   ```

2. In the Databricks workspace, go to **New → Dashboard** (Lakeview dashboards).
3. Add both tables as datasets: **Data → Add data source → select each table**.

## Page 1 — Overview

Add a **counter/KPI widget** for each: `COUNT(*)` on fact table (Total Sessions), `SUM(screen_minutes)/60` (Total Watch Hours), `AVG(screen_minutes)` (Avg Duration), `COUNT(DISTINCT tv_channel)` (Distinct Channels), and two counters filtered on `brighttv_dim_subscribers.subscriber_status` = 'Active' / 'Dormant'.
Add a **line chart**: X = `watch_date`, Y = `COUNT(*)`.

## Page 2 — Channel Performance

Add **bar charts** on `brighttv_fact_viewership`, grouped by `tv_channel`:
- Sessions: Y = `COUNT(*)`
- Watch hours: Y = `SUM(screen_minutes)/60`
- Avg duration: Y = `AVG(screen_minutes)`
- For Top 5: add a **Top N filter** on the visualization (Databricks dashboards support a "Top N" sort + limit control) sorted by watch hours descending, limit 5.

## Page 3 — Viewer Behaviour

- Line/bar chart: X = `hour_of_day`, Y = `COUNT(*)`
- Bar chart: X = `day_classification` (Weekday/Weekend), Y = `COUNT(*)` and a second one with `AVG(screen_minutes)`
- Bar chart: X = `day_name`, Y = `COUNT(*)` — use a **custom sort order** field (add a `day_sort_order` computed column 1–7 if the dashboard editor doesn't support manual category ordering)
- **Pivot/heatmap table**: rows = `hour_of_day`, columns = `day_name`, values = `COUNT(*)`, with a color scale applied via the table's conditional formatting option

## Page 4 — Audience Segments

- Bar chart by `Region` (sessions)
- Bar chart by `age_group` (sessions) — keep Infants/Kids/Teenager/Young Adult/Middle Aged Adult/Senior order
- Pie chart by `Gender`
- Pie chart on `brighttv_dim_subscribers.subscriber_status` (Active vs Dormant)
- Bar chart comparing `AVG(screen_minutes)` by `social_media_flag`

## Page 5 — Insights & Recommendations

Add a **Text/Markdown widget** and paste the finalized narrative from the "5. Insights & Recommendations" sheet in `BrightTV_Dashboard.xlsx`.

## Notes

- All time fields are already SAST-converted — no further timezone handling needed.
- Channel names are already consolidated in `tv_channel`.
- Since this dashboard reads live from the Databricks tables, re-running the SQL script will automatically refresh every visualization — no manual re-import required, unlike the Looker Studio/Power BI CSV versions.
