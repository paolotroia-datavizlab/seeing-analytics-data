-- Sessions with at least one page view, by device category, Nov 2020 to Jan 2021.
-- Used by When sessions don't add up: these rows add up to the real total.
-- No date filter: the sample only covers these three months.

-- Only sessions with a page view, so the total is comparable with sessions_by_page.sql, which only
-- counts those. Device is fixed for a session, so each one lands in exactly one row.
WITH page_view_sessions AS (
  SELECT DISTINCT
    device.category AS device_category,
    CONCAT(
      user_pseudo_id, '-',
      CAST((SELECT value.int_value FROM UNNEST(event_params)
            WHERE key = 'ga_session_id') AS STRING)
    ) AS session_key
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'page_view'
)

SELECT
  device_category,
  COUNT(DISTINCT session_key) AS sessions
FROM page_view_sessions
GROUP BY device_category
ORDER BY sessions DESC
