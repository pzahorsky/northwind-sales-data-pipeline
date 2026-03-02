# Northwind Sales Data Pipeline

This project demonstrates SQL-based feature engineering in PostgreSQL 
and downstream KPI analysis in Python.

## Objective

Build an analysis-ready customer × year sales dataset using:
- multi-table joins
- CTE-based transformations
- aggregations
- window functions (yearly ranking)

## Structure

- `sql/final_dataset.sql` – main SQL feature engineering query
- `notebooks/` – lightweight analytical notebook
- `assets/schema.png` – database schema reference

## How to Run

1. Create PostgreSQL database (Northwind)
2. Activate virtual environment
3. Install dependencies:
   pip install -r requirements.txt
4. Run the notebook