# Caravelo — Analytics Engineer Assignment

Welcome — this repository contains the implementation for the Caravelo Analytics Engineer assignment.
It demonstrates generating sample subscription data and calculating Monthly Recurring Revenue (MRR)
and related KPIs using Python (for data generation) and dbt (for transformations, tests and documentation).

This README guides a first-time cloner through setup, configuration, running the project locally,
and submission notes.

## Quick links
- Project root: repository root
- dbt project: `dbt_caravelo/`
- Data generator: `seeds/data_generator.py`

## Prerequisites
- Git (to clone the repository)
- Python 3.10+ (3.11 recommended)
- pip and virtualenv (or use `python -m venv`)
- dbt Core CLI (version 1.4+ recommended) and the adapter for your target (DuckDB recommended for local runs)

Notes:
- The project includes a `dbt_caravelo/profiles.yml` configured for DuckDB by default. You can run with
	DuckDB locally without external cloud warehouses.

## Repository structure (important files)

- `dbt_caravelo/` — dbt project containing models, seeds, tests and `dbt_project.yml`.
	- `models/staging/` — source cleaning & normalization
	- `models/marts/` — business logic and MRR aggregation
	- `seeds/` (inside dbt project) — csv seeds produced by the generator
- `seeds/data_generator.py` — Python script that creates example CSV datasets used as dbt seeds
- `requirements.txt` — Python dependencies for the generator and local tooling
- `target/` — dbt run/compile output (generated after running dbt)

## 1 — Clone the repository

Open a terminal and run:

```bash
git clone <your-repo-url>
cd caravelo-nmc
``` 

Replace `<your-repo-url>` with the SSH/HTTPS URL of the repo you received.

## 2 — Create and activate a Python virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
```

On macOS zsh this will activate the `.venv` environment. To deactivate later, run `deactivate`.

## 3 — Install Python dependencies

From the repository root run:

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

This installs the data generator dependencies and any small utilities used for local testing.

## 4 — Configure dbt profiles

dbt looks for `profiles.yml` in `~/.dbt/` by default. This repository already contains a working
`dbt_caravelo/profiles.yml` configured for DuckDB (local). You have two options:

Option A (recommended, no global changes): point dbt at the project's profiles directory when running dbt by
setting the `DBT_PROFILES_DIR` environment variable. Example:

```bash
export DBT_PROFILES_DIR=$(pwd)/dbt_caravelo
# Then run dbt commands from the project folder (see next section)
```

Option B (global): copy `dbt_caravelo/profiles.yml` to your `~/.dbt/profiles.yml`.

If you prefer BigQuery, Snowflake or another adapter, update `dbt_caravelo/profiles.yml` accordingly and
ensure credentials/environment variables are set.

## 5 — Generate sample data (seeds)

The repository contains a lightweight data generator that creates CSVs used by dbt seeds.

```bash
python seeds/data_generator.py
```

This will overwrite the files in `seeds/` (CSV files for `users`, `providers`, `plans`, `subscription_events`, `currency_rates`).

## 6 — Run the dbt project (recommended order)

Change into the dbt project and run:

```bash
cd dbt_caravelo
dbt deps
dbt seed --select +seeds --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

Notes:
- If you set `DBT_PROFILES_DIR` (Option A) you can omit `--profiles-dir .`.
- `dbt seed` will load the CSVs generated in step 5 into the dbt environment.
- `dbt test` runs schema and data tests defined in the project.

## 7 — Generate and view documentation (optional)

```bash
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

This will open a small local web server with the dbt docs site (graph, model descriptions, tests and lineage).

## 8 — What to expect / key artifacts

- The transformed MRR metrics and intermediate models are in `dbt_caravelo/models/marts/`.
- Test/validation SQL lives in the dbt tests configuration and the `tests/` folder.
- Output artifacts (compiled SQL, manifest, run_results, graph) are in `dbt_caravelo/target/`.

## Brief write-up — assumptions, design and optimisations

Assumptions:
- The dataset is a simplified synthetic representation of subscription and plan data.
- Timezones are not modelled; all timestamps are treated as UTC.
- Pricing is stored in a single currency for the example; `stg_currency_rates.sql` shows how to join rates if multi-currency support is required.

Design decisions:
- dbt is used for transformations, tests and documentation to reflect standard analytics engineering practice.
- Seeds (CSV) are used for deterministic, repeatable inputs so reviewers can run the project locally without external data sources.
- Models are separated into `staging` (cleaning) and `marts` (business logic) to keep transformations composable and testable.

Optimisations and notes:
- Models are written to be incremental-friendly where appropriate (see model materializations). For this small dataset, full-refresh runs are inexpensive.
- Source and schema tests are included to catch data quality regressions early.

## Submission guidelines (what to share)

When you're ready to submit:

- Share repository access with: `tech-assignment@caravelo.com` and `jlv@caravelo.com`.
- Include any additional notes or a short write-up if you changed assumptions, or want to highlight specific design decisions. You can place these in this README under a new section or add a `WRITEUP.md` at the repo root.

Suggested checklist for submission:
- [ ] All code committed and pushed to a branch
- [ ] README contains setup/run instructions (this file)
- [ ] Brief write-up included (assumptions, optimisations)

## Troubleshooting

- If dbt complains about profiles: ensure `DBT_PROFILES_DIR` is pointing to `dbt_caravelo` or copy the `profiles.yml` file to `~/.dbt/profiles.yml`.
- If a Python dependency fails: check your active Python version and recreate the virtualenv.
- If `dbt seed` doesn't find CSVs: re-run `python seeds/data_generator.py` from the repository root so `dbt_caravelo/seeds/` contains the CSVs.

## Contact / Questions

If anything is unclear or you need additional help during evaluation, include notes in the repo or reach out to the assignment contacts listed above.

----

Thank you for reviewing — the project is intentionally small and straightforward to make it easy to run locally. If you'd like, I can also provide a short script that runs the full workflow (`generate -> seed -> run -> test -> docs`) in one step.
