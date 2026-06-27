# California County Fiscal Trend Reliability Analysis
**Author:** Karen Wu
**Date:** June 2026

## Overview
A follow-up to my first county finance project, this analysis goes deeper by examining 
21 years (2003-2024) of raw county-level revenue and expenditure data, loaded into a 
SQLite database and analyzed using SQL window functions, CTEs, and statistical measures 
rather than pre-aggregated data.

## Key Finding
Naively ranking counties by average year-over-year per-capita financial improvement is 
misleading. Small counties like Alpine and Sierra top the naive ranking, but their 
volatility is 13 to 68 times their average change, meaning the apparent "trend" is 
statistical noise from a small population base rather than genuine fiscal improvement. 
After calculating a reliability ratio (average change divided by volatility), San Joaquin 
and San Bernardino emerge as the most consistently improving large counties, while Tehama, 
Solano, and Napa show real, sustained per-capita fiscal decline over the full 21-year window.

## Methodology
1. Loaded raw county-level revenue and expenditure line-item data (1M+ combined rows) 
   into a local SQLite database
2. Used SQL to aggregate, join, and calculate year-over-year change via window functions (LAG)
3. Normalized year-over-year change by population to enable fair cross-county comparison
4. Identified that naive average-based ranking was dominated by small, volatile counties
5. Calculated volatility (standard deviation) and a signal-to-noise reliability ratio 
   to separate genuine trends from statistical noise
6. Built an interactive Tableau dashboard visualizing trends, rankings, and the 
   volatility/reliability relationship

## Tools Used
- SQLite — relational database for raw data storage and querying
- SQL — CTEs, window functions (LAG, RANK), aggregate functions, custom statistical calculations
- Python (pandas) — data loading and export
- Tableau Public — visualization and dashboarding

## Data Source
[California State Controller's Office — Local Government Financial Data](https://lab.data.ca.gov)

## View the Dashboard
[Live interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/karen.wu6142/viz/CACountyFiscalTrendReliabilityAnalysis/CaliforniaCountyFiscalTrends2003-2024SeparatingSignalfromNoise)

## Files
- `sql/trend_analysis_queries.sql` — full SQL pipeline from raw data to final ranking
- `notebooks/county_trend_analysis.ipynb` — data loading and export workflow
- `data/county_trend_reliability.csv` — final ranked output with reliability scores
- `data/county_yearly_finances.csv` — full year-by-year detail for time-series analysis
- `dashboard_screenshot.png` — static preview of the final dashboard
