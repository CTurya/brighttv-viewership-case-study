# BrightTV Viewership Analytics — Case Study

## Overview

BrightTV's CEO set an objective to grow the company's subscription base this financial year. The CVM (Customer Value Management) team commissioned this analysis to turn subscriber and viewership data into concrete, actionable insight in support of that goal.

The dataset covers **10,000 viewing sessions** from **5,375 subscriber profiles** over a 3-month window (Jan–Mar 2016). This project takes that raw data through cleaning, analysis, and dashboarding, and ends with a set of specific recommendations for content scheduling, promotional timing, and subscriber growth.

## How the case study was done

1. **Data cleaning & transformation (SQL, Databricks)** — resolved a duplicate/mismatched subscriber ID column in the raw export, consolidated inconsistent channel name spellings (e.g. "SuperSport"/"Supersport", "SawSee"/"Sawsee"), converted all timestamps from UTC to SAST, and derived time-of-day, day-of-week, and session-length classifications. A second query builds a subscriber-level Active/Dormant flag by checking which profiles have zero sessions in the period.
2. **Excel analysis** — a fully formula-driven workbook (SUMIFS/COUNTIFS/AVERAGEIFS, no hardcoded numbers) plus native pivot tables, covering 5 pages: Overview, Channel Performance, Viewer Behaviour, Audience Segments, and Insights & Recommendations.
3. **Dashboards** — the same analysis was rebuilt across **Power BI**, **Google Looker Studio**, **Databricks**, and a custom **web app (Lovable)**, to demonstrate the same insight translating cleanly across BI tools.
4. **Presentation** — a stakeholder-facing summary structured around the CEO's four original questions.

## What was found

- **Prime Time (17:00–22:00 SAST)** is the single biggest viewing window — the clear anchor slot for any promotional push.
- **Monday is the lowest-consumption day** (957 sessions) versus **Friday** (1,675 sessions) — a ~1.75x swing between the weekly low and high.
- **Live sport dominates**: ICC Cricket World Cup 2011 and the consolidated Live Events feed together account for over 40% of total watch hours.
- **18.4% of subscriber profiles (989 people) never watched anything** in the period — but 75% of those are also missing most other profile data (Age = 0, no region), suggesting they're incomplete/placeholder signups rather than genuinely lapsed viewers. The *real* at-risk subscriber base is meaningfully smaller than the headline dormancy rate suggests.
- **Gauteng** is the largest viewing region by a wide margin, followed by Western Cape and Kwazulu-Natal.

Full detail, numbers, and the resulting recommendations are in the Insights & Recommendations page of the Excel workbook and in the final presentation.

## Tools used

- **SQL (Databricks / Spark SQL)** — data cleaning and transformation
- **Microsoft Excel** — formula-driven analysis, pivot tables, and charts
- **Power BI** — interactive dashboard with DAX measures
- **Google Looker Studio** — cloud-hosted interactive dashboard
- **Databricks** — dashboard built directly on the cleaned Spark tables
- **Lovable** — custom-built web application dashboard
- **Miro** — project planning flowchart
- **PowerPoint/Canva** — final stakeholder presentation

## Repository structure

```
BrightTV_Case_Study/
├── README.md
├── 01_Project_Description_and_Raw_Data/
│   ├── Project_Description.pdf
│   └── raw_data/
│       ├── BrightTV_UserProfiles_RAW.csv
│       └── BrightTV_Viewership_RAW.csv
├── 02_Project_Planning/
│   ├── BrightTV_Gantt_Chart.xlsx
│   └── Miro_Flowchart.md  (+ exported image)
├── 03_Data_Processing/
│   ├── BrightTV_Analysis.sql
│   └── BrightTV_Dashboard.xlsx
└── 04_Project_Presentation/
    ├── BrightTV_Presentation.pptx
    ├── PowerBI_Build_Guide.md
    ├── LookerStudio_Build_Guide.md
    ├── Databricks_Dashboard_Guide.md
    └── Lovable_Dashboard_Link.md
```
