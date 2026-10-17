-- Real sessions with at least one page view, Nov 2020 to Jan 2021, each counted once.
-- When sessions don't add up compares the rows of its reports with this total.
-- No date filter: the sample only covers these three months.

-- Only sessions with a page view, so the total is comparable with the report by page.
-- A session is identified by user and ga_session_id together: the id alone is only unique per user.
SELECT
  COUNT(DISTINCT CONCAT(
    user_pseudo_id, '-',
    CAST((SELECT value.int_value FROM UNNEST(event_params)
          WHERE key = 'ga_session_id') AS STRING)
  )) AS sessions
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'page_view'
