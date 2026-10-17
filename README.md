# Seeing Analytics data

The SQL, notebooks and results behind [Seeing Analytics](https://seeinganalytics.com), a site that
explains web analytics metrics with interactive visuals.

## Folders

Each explorable has its own folder with its notebook, its queries (`sql/`) and their results (`csv/`).

## Run it yourself

1. Create a project in the free BigQuery sandbox.
2. Sign in from your machine: `gcloud auth application-default login`.
3. Copy `.env.example` to `.env` and add your project ID.
4. Install the packages: `pip install -r requirements.txt jupyterlab`.
5. Open a notebook and run all cells from the top. It checks the results against the numbers on
   the site before saving the CSVs. If nothing has changed, `git status` shows no modified CSV.

## Data sources

- [Google Analytics 4 sample dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset):
  obfuscated data from the Google Merchandise Store, November 2020 to January 2021.

## Licence

The code (SQL and notebooks) is under the MIT licence. The CSVs are aggregated results of queries
on the data sources above.
