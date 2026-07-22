# BrightTV Dashboard — Power BI Build Guide

## Getting set up on a Mac without a work email

Power BI Desktop is Windows-only, and Power BI Service blocks personal Gmail/Outlook addresses at signup. Two free workarounds:

1. **Get a qualifying email:** join the free [Microsoft 365 Developer Program](https://developer.microsoft.com/microsoft-365/dev-program) — no real company needed. It gives a renewable 90-day sandbox with a `you@yourname.onmicrosoft.com` address and Power BI Pro-level access.
2. **Skip Desktop, build in-browser:** sign into [app.powerbi.com](https://app.powerbi.com) with that new email in Safari/Chrome. Upload `BrightTV_Dashboard.xlsx` (or the two CSVs) via **Get Data → Files**, then use **Create report** directly in the browser — every step below works the same way whether you're in Desktop or the browser.

If you'd rather run full Power BI Desktop, you'll need a Windows environment via Parallels/VMware Fusion or a cloud PC (Windows 365 / Azure Virtual Desktop) — not required for this dashboard, but useful if you outgrow the browser editor later.

---

Same two data files as the Looker Studio version:

| File | Grain | Rows | Use for |
|---|---|---|---|
| `BrightTV_Fact_Viewership.csv` | 1 row per viewing **session** | 10,000 | Overview, Channel Performance, Viewer Behaviour, session-level Audience Segments |
| `BrightTV_Dim_Subscribers.csv` | 1 row per **subscriber profile** | 5,375 | Active vs Dormant subscriber counts |

## 1. Load & model

1. **Home → Get Data → Text/CSV**, load both files. Name them `Fact_Viewership` and `Dim_Subscribers` in Power Query.
2. In Power Query, set data types:
   - `Fact_Viewership`: `record_date_sast` → Date/Time, `watch_date` → Date, `hour_of_day`/`weekend_flag`/`email_flag`/`social_media_flag`/`Age` → Whole Number, `screen_minutes` → Decimal Number, everything else → Text.
   - `Dim_Subscribers`: `Age` → Whole Number, everything else → Text.
3. **Close & Apply.**
4. **Model view:** create a relationship `Fact_Viewership[UserID]` → `Dim_Subscribers[UserID]`, cardinality Many-to-One, single direction (Dim filters Fact). This lets Region/Gender/Age slicers on the Dim table also filter session-level visuals if you want that later — the pages below mostly use each table independently, matching the Excel/Looker builds.
5. Create a **Calendar** date table if you want native Power BI date hierarchies on the trend chart: `CalendarAuto = CALENDAR(MIN(Fact_Viewership[watch_date]), MAX(Fact_Viewership[watch_date]))`, then relate it to `watch_date`. Optional — the flat date column works fine without it for this dataset's 3-month span.

## 2. DAX measures (create these once, reuse across all pages)

```dax
Total Sessions = COUNTROWS(Fact_Viewership)

Total Watch Hours = SUM(Fact_Viewership[screen_minutes]) / 60

Avg Watch Duration (min) = AVERAGE(Fact_Viewership[screen_minutes])

Distinct Channels = DISTINCTCOUNT(Fact_Viewership[tv_channel])

Active Subscribers = CALCULATE(COUNTROWS(Dim_Subscribers), Dim_Subscribers[subscriber_status] = "Active")

Dormant Subscribers = CALCULATE(COUNTROWS(Dim_Subscribers), Dim_Subscribers[subscriber_status] = "Dormant")

Top Channel = 
CALCULATE(
    VALUES(Fact_Viewership[tv_channel]),
    TOPN(1, VALUES(Fact_Viewership[tv_channel]), CALCULATE([Total Watch Hours]))
)

Weekend Avg Duration = 
CALCULATE([Avg Watch Duration (min)], Fact_Viewership[day_classification] = "Weekend")

Weekday Avg Duration = 
CALCULATE([Avg Watch Duration (min)], Fact_Viewership[day_classification] = "Weekday")

Zero Duration Sessions = CALCULATE([Total Sessions], Fact_Viewership[screen_minutes] = 0)
```

## 3. Page 1 — Overview

| Visual | Type | Fields |
|---|---|---|
| KPI cards (x6) | Card | `[Total Sessions]`, `[Total Watch Hours]`, `[Avg Watch Duration (min)]`, `[Distinct Channels]`, `[Active Subscribers]`, `[Dormant Subscribers]` |
| Top channel | Card | `[Top Channel]` |
| Viewership trend | Line chart | Axis: `watch_date`, Value: `[Total Sessions]` |
| Monthly trend (optional secondary) | Column chart | Axis: `year_month`, Value: `[Total Sessions]` |

## 4. Page 2 — Channel Performance

| Visual | Type | Axis | Value | Sort |
|---|---|---|---|---|
| Sessions by channel | Bar chart | `tv_channel` | `[Total Sessions]` | Descending |
| Watch time by channel | Bar chart | `tv_channel` | `[Total Watch Hours]` | Descending |
| Top 5 channels | Bar chart | `tv_channel` | `[Total Watch Hours]` | Descending, **Filter pane → Top N → 5 by [Total Watch Hours]** |
| Avg duration by channel | Bar chart | `tv_channel` | `[Avg Watch Duration (min)]` | Descending |

## 5. Page 3 — Viewer Behaviour

| Visual | Type | Fields |
|---|---|---|
| Sessions by hour of day | Line/column chart | Axis: `hour_of_day`, Value: `[Total Sessions]` |
| Weekday vs Weekend | Clustered column | Axis: `day_classification`, Values: `[Total Sessions]`, `[Avg Watch Duration (min)]` |
| Sessions by day of week | Bar chart | Axis: `day_name`, Value: `[Total Sessions]` — **Column tools → Sort by Column** and add a helper column `day_sort` (Mon=1…Sun=7) in Power Query to force correct order, since Power BI sorts text alphabetically by default |
| Peak viewing heatmap | Matrix visual with conditional formatting | Rows: `hour_of_day`, Columns: `day_name`, Values: `[Total Sessions]`, then **Format → Cell elements → Background color → enable, based on field = [Total Sessions]** |

## 6. Page 4 — Audience Segments

| Visual | Type | Data table | Fields |
|---|---|---|---|
| Sessions by region | Filled map or bar chart | Fact_Viewership | `Region`, `[Total Sessions]` |
| Sessions by age group | Bar chart | Fact_Viewership | `age_group` (sort by helper `age_sort` column: Infants=1…Senior=6), `[Total Sessions]` |
| Sessions by gender | Donut chart | Fact_Viewership | `Gender`, `[Total Sessions]` |
| Active vs Dormant | Donut chart | Dim_Subscribers | `subscriber_status`, Count of rows |
| Social handle engagement | Bar chart | Fact_Viewership | `social_media_flag`, `[Avg Watch Duration (min)]` |

## 7. Page 5 — Insights & Recommendations

Add **Text boxes** and paste the finalized narrative directly from the "5. Insights & Recommendations" sheet in `BrightTV_Dashboard.xlsx` — those numbers are already verified. Optionally add 1-2 supporting cards (e.g. `[Zero Duration Sessions]`) as visual anchors next to the relevant bullet points.

## Notes carried over from the Excel/Looker builds

- Times are already converted to **SAST (UTC+2)** — no timezone adjustment needed.
- `tv_channel` names are already consolidated (SuperSport/Supersport, SawSee/Sawsee, live-events variants merged).
- `age_group = "Infants"` mostly reflects incomplete `Age = 0` profiles, not literal infant viewers — worth a caption if presenting live.
- 860 sessions (8.6%) have `screen_minutes = 0` — add a `screen_minutes > 0` filter to any visual where you want duration averages excluding these.
