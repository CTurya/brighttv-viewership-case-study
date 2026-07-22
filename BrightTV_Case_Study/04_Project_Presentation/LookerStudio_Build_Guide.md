# BrightTV Dashboard — Looker Studio Build Guide (Single-Source Version)

**This version uses only `BrightTV_Fact_Viewership.csv` as the data source.** The Dim_Subscribers file kept failing to upload as a second source, so every chart below is built to work off the one Fact table you already have connected. The only thing this drops versus the full two-source version is the "Active vs Dormant Subscribers" chart, since that specifically requires the full profile list (including people who never watched anything) — not something the Fact table (viewers only) can show. That insight is still covered qualitatively on the Insights page and in your Excel/Power BI/Lovable versions.

## Setup

1. You should already have **"Fact - Viewership"** connected as a File Upload data source (10,000 rows). If not: **home screen → Create → Data Source → File Upload → `BrightTV_Fact_Viewership.csv`**.
2. In the field editor, set these types before connecting:
   - `record_date_sast` → Date & Time (Datetime, `YYYY-MM-DD HH:MM:SS`)
   - `watch_date` → Date (`YYYY-MM-DD`)
   - `year_month` → Text (keep as text so it sorts correctly)
   - `hour_of_day`, `weekend_flag`, `email_flag`, `social_media_flag`, `Age` → Number
   - `screen_minutes` → Number (Metric, default aggregation **Sum**)
   - Everything else (`tv_channel`, `day_name`, `viewing_period`, `screen_session`, `Region`, `age_group`, `Race`, `Gender`, `day_classification`) → Text (Dimension)
3. Create a blank report, add 5 pages named exactly as below.

---

## Page 1 — Overview

| Element | Type | Field(s) | Notes |
|---|---|---|---|
| Total viewing records | Scorecard | Record Count | |
| Total viewing hours | Scorecard | Calculated field `= SUM(screen_minutes)/60` | |
| Avg watch duration | Scorecard | `screen_minutes` (Average) | |
| Number of TV channels | Scorecard | `tv_channel` (Count Distinct) | |
| Top channel | Table (sorted, limit 1) or Scorecard | `tv_channel` dimension, `screen_minutes` Sum, sort descending | |
| Viewership trend | Time series chart | Dimension: `watch_date`, Metric: Record Count (or `screen_minutes` Sum) | Default date range Jan 1 – Apr 1 2016 |

*(Active/Dormant subscriber scorecards are dropped in this version — no profile-level data available.)*

---

## Page 2 — Channel Performance

| Chart | Type | Dimension | Metric | Sort |
|---|---|---|---|---|
| Sessions by channel | Bar chart | `tv_channel` | Record Count | Descending |
| Total watch time by channel | Bar chart | `tv_channel` | `screen_minutes` Sum ÷ 60 (calculated field `watch_hours`) | Descending |
| Top 5 most-watched channels | Bar chart | `tv_channel` | `watch_hours` | Descending, **Row limit = 5** |
| Avg watch duration by channel | Bar chart | `tv_channel` | `screen_minutes` Average | Descending |

---

## Page 3 — Viewer Behaviour

| Chart | Type | Dimension | Metric |
|---|---|---|---|
| Sessions by hour of day | Column/line chart | `hour_of_day` | Record Count |
| Weekday vs Weekend | Bar chart | `day_classification` | Record Count, and a second chart with `screen_minutes` Average |
| Sessions by day of week | Bar chart | `day_name` | Record Count — **Style → Sort → Manual**, order Monday→Sunday (Looker sorts alphabetically by default) |
| Peak viewing time heatmap | Pivot table with heatmap | Rows: `hour_of_day`, Columns: `day_name`, Metric: Record Count, then enable **conditional formatting / heatmap** in the pivot table style panel | |

---

## Page 4 — Audience Segments

| Chart | Type | Dimension | Metric |
|---|---|---|---|
| Viewership by region | Map chart or bar chart | `Region` | Record Count |
| Viewership by age group | Bar chart | `age_group` | Record Count — manual sort: Infants, Kids, Teenager, Young Adult, Middle Aged Adult, Senior |
| Viewership by gender | Pie/donut chart | `Gender` | Record Count |
| Social handle engagement | Bar chart | `social_media_flag` (0/1) | `screen_minutes` Average |
| Distinct viewers by region *(replaces Active/Dormant)* | Bar chart | `Region` | `UserID` Count Distinct | Shows how many unique subscribers watched per region — the closest Fact-only proxy for engagement breadth |

---

## Page 5 — Insights & Recommendations

Build this as **text boxes**, not charts — copy the narrative content directly from the "5. Insights & Recommendations" sheet in `BrightTV_Dashboard.xlsx`. Note: the dormant-subscriber finding (989 profiles, 18.4% inactive) came from the two-source Excel/Power BI/Lovable builds — mention it as a supporting stat in the text box even though this Looker Studio version can't chart it live from Fact alone.

---

## Known data caveats to carry into Looker Studio

- **Channel names are already consolidated** in the CSV (`tv_channel` column) — don't re-clean this field.
- **`age_group` "Infants"** reflects `Age = 0` placeholder/incomplete profiles more than literal infant viewers — worth a caption on the chart if presenting live.
- **860 sessions (8.6%) have `screen_minutes = 0`** — if you want an average-duration metric that excludes these, add a filter `screen_minutes > 0` to that specific chart only, and label it accordingly.
- All time fields are already converted to **SAST (UTC+2)** — no further timezone adjustment needed in Looker Studio.

