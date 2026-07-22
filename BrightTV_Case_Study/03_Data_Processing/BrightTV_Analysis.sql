/* ============================================================================
   BrightTV Viewership Analytics — Data Processing SQL
   Platform: Databricks SQL (Spark SQL)
   Source tables: workspace.default.bright_tv_users_profiles
                  workspace.default.bright_tv_viewership
   Author: [Your Name]
   ============================================================================
   Notes:
   - Raw timestamps are supplied in UTC and are converted to SAST (UTC+2).
   - Consumption is per session: one row in Viewership = one viewing session.
   - Two mismatched ID columns existed in the raw viewership export
     (UserID vs userid, likely a case-insensitive column collision on ingest);
     UserID is used as the trusted join key throughout, since it matched
     100% of subscriber profiles.
   - Channel name variants (spelling/casing differences and duplicate live-
     event feeds) are consolidated before aggregation so volumes are not
     artificially split across near-duplicate channel names.
   ========================================================================= */


/* ----------------------------------------------------------------------
   QUERY 1 — Session-level fact table
   Grain: one row per viewing session (10,000 rows)
   Joins cleaned viewership sessions to cleaned subscriber attributes.
   ---------------------------------------------------------------------- */

WITH User_Profiles AS (
  SELECT
    UserID,
    CASE
      WHEN Province IS NULL
        OR TRIM(Province) = ''
        OR Province = 'None'
      THEN 'Uncategorized'
      ELSE TRIM(Province)
    END AS Region,
    Age,
    CASE
      WHEN Age BETWEEN 0  AND 2  THEN 'Infants'
      WHEN Age BETWEEN 3  AND 12 THEN 'Kids'
      WHEN Age BETWEEN 13 AND 18 THEN 'Teenager'
      WHEN Age BETWEEN 19 AND 35 THEN 'Young Adult'
      WHEN Age BETWEEN 36 AND 64 THEN 'Middle Aged Adult'
      WHEN Age >= 65             THEN 'Senior'
    END AS age_group,
    CASE
      WHEN Email IS NOT NULL
       AND Email <> ''
       AND Email <> 'None' THEN 1
      ELSE 0
    END AS email_flag,
    CASE
      WHEN `Social Media Handle` IS NOT NULL
       AND `Social Media Handle` <> ''
       AND `Social Media Handle` <> 'None' THEN 1
      ELSE 0
    END AS social_media_flag,
    CASE
      WHEN Race ILIKE '%other%' THEN 'None'
      WHEN Race IS NULL OR Race = '' THEN 'None'
      ELSE Race
    END AS Race,
    CASE
      WHEN Gender IS NULL OR Gender = '' THEN 'Unknown'
      ELSE Gender
    END AS Gender
  FROM workspace.default.bright_tv_users_profiles
),

-- Step 1: convert UTC -> SAST and extract raw fields
viewership_raw AS (
  SELECT
    COALESCE(UserID0, userid4, 'Unknown')              AS UserID,

    -- SAST conversion (+2 hours)
    DATEADD(HOUR, 2, RecordDate2)                      AS record_date_sast,

    DATE_FORMAT(
      DATEADD(HOUR, 2, RecordDate2), 'yyyy-MM')        AS year_month,
    DATE(DATEADD(HOUR, 2, RecordDate2))                AS watch_date,
    DATE_FORMAT(
      DATEADD(HOUR, 2, RecordDate2), 'HH:mm:ss')       AS watch_time,
    DAYNAME(DATEADD(HOUR, 2, RecordDate2))             AS day_name,
    HOUR(DATEADD(HOUR, 2, RecordDate2))                AS hour_of_day,
    MONTHNAME(DATEADD(HOUR, 2, RecordDate2))           AS month_name,

    -- Channel cleaning: consolidate spelling/casing variants
    CASE
      WHEN Channel2 IN ('SawSee', 'Sawsee') THEN 'SawSee'
      WHEN Channel2 IN (
        'SuperSport Live Events', 'Supersport Live Events',
        'DStv Events 1', 'Live on SuperSport', 'Live Events'
      ) THEN 'Live Events'
      ELSE Channel2
    END AS tv_channel,

    -- Screen time
    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS screen_time,

    -- Numeric screen time (minutes)
    ROUND(
        (
            HOUR(`Duration 2`) * 60
            + MINUTE(`Duration 2`)
            + SECOND(`Duration 2`) / 60
        ),
        2
    ) AS screen_minutes

  FROM workspace.default.bright_tv_viewership
),

-- Step 2: apply CASE logic that depends on derived columns
Viewership AS (
  SELECT
    *,
    CASE
      WHEN DAYNAME(record_date_sast) IN ('Saturday', 'Sunday') THEN 'Weekend'
      ELSE 'Weekday'
    END AS day_classification,

    CASE
      WHEN DAYNAME(record_date_sast) IN ('Saturday', 'Sunday') THEN 1
      ELSE 0
    END AS weekend_flag,

    CASE
      WHEN hour_of_day BETWEEN 6 AND 11 THEN 'Morning'
      WHEN hour_of_day BETWEEN 12 AND 16 THEN 'Lunch'
      WHEN hour_of_day BETWEEN 17 AND 22 THEN 'Prime Time'
      ELSE 'Late Night'
    END AS viewing_period,

    CASE
      WHEN screen_time BETWEEN '00:00:00' AND '00:30:00' THEN '01. Short Session'
      WHEN screen_time BETWEEN '00:30:01' AND '00:59:59' THEN '02. Medium Session'
      WHEN screen_time >  '00:59:59'                     THEN '03. Long Session'
      ELSE 'Unknown'
    END AS screen_session

  FROM viewership_raw
)

-- Final output: join viewership sessions to subscriber attributes
SELECT
  A.*,
  B.Region,
  B.Age,
  B.age_group,
  B.email_flag,
  B.social_media_flag,
  B.Race,
  B.Gender,
  CASE WHEN B.UserID IS NOT NULL THEN 1 ELSE 0 END AS active_subscriber
FROM Viewership    AS A
LEFT JOIN User_Profiles AS B
  ON A.UserID = B.UserID;


/* ----------------------------------------------------------------------
   QUERY 2 — Subscriber-level dimension table
   Grain: one row per subscriber profile (5,375 rows)
   Flags each subscriber as Active (watched at least one session in the
   period) or Dormant (zero sessions) -- used for the CVM
   re-engagement/growth analysis on the Audience Segments page.
   ---------------------------------------------------------------------- */

WITH Watched_Users AS (
  SELECT DISTINCT
    COALESCE(UserID0, userid4) AS UserID
  FROM workspace.default.bright_tv_viewership
),

User_Profiles_Clean AS (
  SELECT
    UserID,
    CASE
      WHEN Province IS NULL OR TRIM(Province) = '' OR Province = 'None'
      THEN 'Uncategorized' ELSE TRIM(Province)
    END AS Region,
    Age,
    CASE
      WHEN Age BETWEEN 0  AND 2  THEN 'Infants'
      WHEN Age BETWEEN 3  AND 12 THEN 'Kids'
      WHEN Age BETWEEN 13 AND 18 THEN 'Teenager'
      WHEN Age BETWEEN 19 AND 35 THEN 'Young Adult'
      WHEN Age BETWEEN 36 AND 64 THEN 'Middle Aged Adult'
      WHEN Age >= 65             THEN 'Senior'
    END AS age_group,
    CASE WHEN Gender IS NULL OR Gender = '' THEN 'Unknown' ELSE Gender END AS Gender,
    CASE WHEN Race IS NULL OR Race = '' THEN 'None' ELSE Race END AS Race
  FROM workspace.default.bright_tv_users_profiles
)

SELECT
  P.*,
  CASE WHEN W.UserID IS NOT NULL THEN 'Active' ELSE 'Dormant' END AS subscriber_status
FROM User_Profiles_Clean AS P
LEFT JOIN Watched_Users AS W
  ON P.UserID = W.UserID;
