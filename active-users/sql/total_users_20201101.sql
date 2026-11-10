-- Total users on 1 Nov 2020, counted directly. The notebook checks that the four
-- parts of active_users_20201101.sql give the same number.
SELECT
  COUNT(DISTINCT user_pseudo_id) AS total_users
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201101`