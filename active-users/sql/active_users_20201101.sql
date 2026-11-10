-- Active users on 1 Nov 2020, split into the four parts of the Active Users bar.
-- A user counts as active with a first_visit, an engaged session or any engagement
-- time. Each user goes in the first of these that applies, so nobody is counted
-- twice. Users with none of them are in Total users but not in Active users.

WITH events AS (
  -- One row per event, keeping only the two parameters used below
  SELECT
    user_pseudo_id,
    event_name,
    -- Usually stored as a string ('1'), but some events have it as an int
    (SELECT COALESCE(value.string_value, CAST(value.int_value AS STRING))
     FROM UNNEST(event_params)
     WHERE key = 'session_engaged') AS session_engaged,
    (SELECT value.int_value
     FROM UNNEST(event_params)
     WHERE key = 'engagement_time_msec') AS engagement_ms
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201101`
),

users AS (
  -- One row per user. LOGICAL_OR gives NULL when a user never had the parameter,
  -- so those become FALSE
  SELECT
    user_pseudo_id,
    LOGICAL_OR(event_name = 'first_visit')             AS is_new,
    COALESCE(LOGICAL_OR(session_engaged = '1'), FALSE) AS has_engaged_session,
    COALESCE(LOGICAL_OR(engagement_ms > 0), FALSE)     AS has_engagement_time
  FROM events
  GROUP BY user_pseudo_id
)

-- The CASE order decides the part: a new user who also engaged stays under
-- first_visit. The number prefix is only there for ORDER BY.
SELECT
  CASE
    WHEN is_new              THEN '1 first_visit'
    WHEN has_engaged_session THEN '2 engaged session'
    WHEN has_engagement_time THEN '3 engagement_time_msec'
    ELSE                          '4 not active'
  END AS part,
  COUNT(*) AS users
FROM users
GROUP BY part
ORDER BY part
