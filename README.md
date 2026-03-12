# SQL Data Cleaning & Exploration Projects
This repository contains two SQL projects that demonstrate practical data processing and analysis skills using real-world datasets. The project's focus is on data cleaning, transformation, and exploratory analysis using SQL.

## Skills Demonstrated
- Data cleaning and preprocessing
- Exploratory data analysis using SQL
- SQL joins and aggregations
- Window functions
- Common Table Expressions (CTEs)
- Temporary tables and views
- Data transformation and formatting
---

## Project 1: Nashville Housing Data Cleaning
This project focuses on cleaning and preparing a housing dataset for analysis. Several common data cleaning techniques were applied directly using SQL queries.

### Key tasks performed:
- Standardizing date formats.
- Filling missing property addresses using self joins.
- Splitting address fields into multiple columns (address, city, state).
- Converting categorical values (e.g., Y / N) into readable values (Yes / No).
- Removing duplicate records using window functions.
- Dropping unused or redundant columns.

### SQL features used include:
- ALTER TABLE
- UPDATE
- CASE
- SUBSTRING
- CHARINDEX
- PARSENAME
- CTE
- ROW_NUMBER()
- Window functions
The goal of this project was to transform raw housing data into a clean and structured dataset ready for analysis.

---
## Project 2: COVID-19 Data Exploration
This project explores global COVID-19 datasets to analyze infection, death, and vaccination trends across countries and continents.

### Key analyses performed:
- Calculating death rates relative to total cases.
- Measuring infection rates compared to the population.
- Identifying countries with the highest infection and death rates.
- Aggregating global case and death statistics.
- Tracking vaccination progress over time.

### SQL features used include:
- JOIN
- GROUP BY
- Aggregate functions (SUM, MAX)
- Window functions
- CTE
- Temporary tables
- Data type conversion
- Creating SQL views for reusable analysis.
A view (PercentPopulationVaccinated) was created to store vaccination metrics for future analysis and visualization.
