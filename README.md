# Customer Engagement & Subscription Analysis (SQL + Tableau)

End-to-end analytics project that turns raw platform logs from an online learning company into a decision-ready Tableau dashboard. The work covers data modeling and cleaning in SQL, business-logic derivation (subscription windows, onboarding status, paid-vs-free viewership), and visualization of engagement KPIs for stakeholders.

## Business Context

The company sells course subscriptions (**Monthly**, **Quarterly**, **Annual**) and wants to understand how students engage with content after registering, and how that engagement relates to whether they are paying customers. The core questions this project answers:

- How many students register, and what share of them actually start watching content ("onboard")?
- How much content (in minutes) is watched, by course and over time?
- How are courses rated, and how does that compare across content?
- On any given day a student watches content, were they inside an active paid subscription window?

## Data

Source data (exported as CSV) lives in [`/data`](./data):

| File | Description | Rows |
|---|---|---|
| `sql_task3_studentInfo.csv` | One row per student per day watched, with country, registration date, minutes watched, onboarding flag, and paid flag | ~81.5K |
| `sql_task2_purchases_info.csv` | Purchase records: subscription type and the derived start/end date of each subscription window | ~3K |
| `sql_task1_coursesInfo.csv` | Per-course aggregates: total minutes watched, average minutes per student, rating count, and average rating | 46 |

Raw source tables (not included, referenced by the SQL) are `365_student_info`, `365_student_learning`, `365_student_purchases`, `365_course_info`, and `365_course_ratings` in a MySQL schema named `365_database`.

## SQL Logic

All transformation logic lives in [`/sql`](./sql):

- **[`2_purchases_info.sql`](./sql/2_purchases_info.sql)** — a view that derives each subscription's `end_date` from its `start_date` and `purchase_type`:
  - Monthly → `start_date + 1 month`
  - Quarterly → `start_date + 3 months`
  - Annual → `start_date + 12 months`

- **[`1_totalmin.sql`](./sql/1_totalmin.sql)** — a chained CTE pipeline that:
  1. Aggregates total minutes watched and distinct student count per course
  2. Derives average minutes watched per student
  3. Joins in course ratings and computes average rating per course (safely handling courses with zero ratings)

A third query (student-level engagement, onboarding, and paid-flag detection via a date-range join against the purchases view) produces `sql_task3_studentInfo.csv`. It flags a watch-day as "paid" when it falls inside any of that student's active subscription windows, and flags a student as "onboarded" the first time they have any recorded watch activity.

## Dashboard

[`/dashboard`](./dashboard) contains the packaged Tableau workbook (`.twbx`), including three dashboards built from the SQL outputs:

- **Dashboard 1** — Registration & onboarding funnel (KPIs: registrations, onboarded students, onboarding funnel chart)
- **Dashboard 2** — Engagement depth (KPIs: total minutes watched, average minutes per student, minutes-watched funnel/combo chart)
- **Dashboard 3** — Country-level and course-level breakdown (onboarding by country, detail tables)

Open `Customer_Engagement_Analysis_Dashboard.twbx` in [Tableau Desktop or Tableau Public](https://www.tableau.com/products/desktop) — it's a self-contained packaged file with the extracted data, so no live database connection is required.

## Key Skills Demonstrated

- SQL: CTEs, window-independent aggregation, `LEFT JOIN` vs `JOIN` semantics, conditional (`CASE`/`IF`) logic, date arithmetic, view creation
- Data modeling: reconciling grain mismatches across multiple joined tables (student-day grain vs. purchase-window grain)
- Data visualization: KPI cards, funnel charts, combo charts, and cross-filtered dashboards in Tableau
- Business framing: translating raw event logs into onboarding and monetization metrics stakeholders can act on

## Repository Structure

```
├── sql/          -- transformation & view-creation queries
├── data/         -- CSV exports produced by the SQL layer
├── dashboard/     -- packaged Tableau workbook (.twbx)

```

## How to Reproduce

1. Load the raw source tables into a MySQL instance under a schema named `365_database`.
2. Run [`sql/2_purchases_info.sql`](./sql/2_purchases_info.sql) to create the `purchases_info` view.
3. Run [`sql/1_totalmin.sql`](./sql/1_totalmin.sql) for course-level aggregates.
4. Run the student-level engagement query (see [`docs/queries.md`](./docs/queries.md)) to reproduce `sql_task3_studentInfo.csv`.
5. Open the workbook in `dashboard/` with Tableau, or point Tableau at fresh exports of the same three CSVs to refresh the visuals.

## Author

Ananya KP | https://www.linkedin.com/in/ananyakp/ |
