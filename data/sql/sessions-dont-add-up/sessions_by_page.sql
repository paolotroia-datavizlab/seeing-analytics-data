-- Sessions with at least one page view, by page title, Nov 2020 to Jan 2021: the top 8 pages and
-- one row for the rest. In When sessions don't add up, these rows add up to more than the total.
-- No date filter: the sample only covers these three months.
WITH page_views AS (
  SELECT
    -- GA4 reports show a missing title as "(not set)".
    COALESCE(
      (SELECT value.string_value FROM UNNEST(event_params)
       WHERE key = 'page_title'),
      '(not set)'
    ) AS page_title,
    CONCAT(
      user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) AS session_key
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'page_view'
),

per_page AS (
  -- A session counts once in the row of every page it viewed, as in a GA4 report by page.
  SELECT
    page_title,
    COUNT(DISTINCT session_key) AS sessions
  FROM page_views
  GROUP BY page_title
),

ranked AS (
  -- The title breaks ties, so the top 8 can't change between runs.
  SELECT
    page_title,
    sessions,
    ROW_NUMBER() OVER (ORDER BY sessions DESC, page_title) AS position
  FROM per_page
)

-- "Other pages" adds up the remaining rows, so it counts sessions more than once too.
SELECT
  IF(position <= 8, page_title, 'Other pages') AS page,
  SUM(sessions)                                AS sessions,
  MIN(position)                                AS position
FROM ranked
GROUP BY page
ORDER BY position
