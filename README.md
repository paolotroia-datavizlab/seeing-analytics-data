# Seeing Analytics: data

The queries and results behind the explorables on [seeinganalytics.com](https://seeinganalytics.com).
Every number comes from Google's public GA4 sample dataset in BigQuery, counted with the SQL here.

This repo currently holds the files for one explorable,
[When sessions don't add up](https://seeinganalytics.com/reports/sessions-dont-add-up). The other
explorables will follow, one at a time.

## What is here

```text
data/sql/sessions-dont-add-up/     The BigQuery queries.
data/raw/sessions-dont-add-up/     Their results, as CSV files, exactly as BigQuery returned them.
data/notebooks/                    The notebook that runs the queries, checks the results and saves the CSVs.
data/requirements.txt              The Python packages the notebook needs.
```

| Query                | Result                   | What it counts                                               |
| -------------------- | ------------------------ | ------------------------------------------------------------ |
| `real_sessions`      | `real_sessions.csv`      | Sessions with a page view, each counted once: the real total |
| `sessions_by_device` | `sessions_by_device.csv` | The same sessions by device category: these rows add up      |
| `sessions_by_page`   | `sessions_by_page.csv`   | The same sessions by page title: these rows add up to more   |

## Reproduce the CSVs

You need a Google account, Python 3.13 and Jupyter (or VS Code with the Python extension). Every
query fits in the free BigQuery sandbox: no billing account needed.

1. Create a project in the [BigQuery sandbox](https://cloud.google.com/bigquery/docs/sandbox) and note
   its project ID.
2. Sign in from your machine, so the notebook can use your account:
   `gcloud auth application-default login`
   (with the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)).
3. Copy `data/.env.example` to `data/.env` and set `GOOGLE_CLOUD_PROJECT` to your project ID. The
   queries run on your project, and `.env` stays out of git.
4. Install the packages, from the `data/` folder:

   ```sh
   python -m venv .venv
   source .venv/bin/activate        # Windows: .venv\Scripts\Activate.ps1
   pip install -r requirements.txt jupyterlab
   ```

5. Open `data/notebooks/sessions-dont-add-up.ipynb` and run every cell, top to bottom. It prints how
   much data each query will read before running it, checks the results against the numbers the site
   shows, and only then writes the CSVs into `data/raw/`.

A re-run should change nothing: `git status data/raw` shows no modified file. If a check fails or a
CSV changes, the dataset or a query has changed.

## Methods

### Assumptions

- **A session is a user and a session ID together.** `ga_session_id` alone is not unique across users,
  so sessions are counted by `user_pseudo_id` and `ga_session_id` combined
  ([BigQuery Export schema](https://support.google.com/analytics/answer/7029846)).
- **Sessions with a page view.** The queries count only sessions with at least one `page_view`, so the
  totals by device and by page compare like with like. GA4's Sessions metric counts every session, so
  its total can be higher.
- **Days follow the dataset's timezone.** `event_date` and the daily tables use the property's
  timezone; `event_timestamp` is in UTC.
- **Periods are inclusive.** "1 Nov 2020 to 31 Jan 2021" includes both days. The dataset's 92 daily
  tables cover exactly that range, so the queries need no date filter.
- **Counts are exact.** `COUNT(DISTINCT …)` gives exact numbers. GA4's own reports estimate unique
  counts, so they can differ slightly from these.

### Definitions used

- Sessions: [About Analytics sessions](https://support.google.com/analytics/answer/9191807)

### Limits of the data

The [dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)
(`bigquery-public-data.ga4_obfuscated_sample_ecommerce`) is a three-month sample of the Google
Merchandise Store's GA4 export, 1 November 2020 to 31 January 2021. Google describes it as
obfuscated data that emulates a real dataset: some fields hold placeholder values (`<Other>`, `NULL`,
`''`), internal consistency is somewhat limited, and it can't be compared with the Google Analytics
demo account. The numbers show how GA4 counts, not how this store performed.

The site says 'Hundreds of other pages' instead of an exact count: the sample has exactly 500 page titles, a round number that may be a limit set by Google's obfuscation.

## Source line on the site

> Data: Google's GA4 sample from the Merchandise Store, November 2020 to January 2021, exact counts
> from BigQuery.

## Licence

The CSVs in `data/raw/` are aggregated results of the queries in `data/sql/`, run on Google's public
sample dataset `ga4_obfuscated_sample_ecommerce`
([Google's page for the dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)).

The MIT licence in `LICENSE` covers the code only: the SQL and the notebooks.
