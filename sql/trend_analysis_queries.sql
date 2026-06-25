
-- California County Spending Trend Analysis --

-- Query 1: Total revenues by county and year
CREATE VIEW revenue_by_county_year AS
SELECT 
    "Entity Name" AS county,
    "Fiscal Year" AS fiscal_year,
    SUM("Values") AS total_revenue,
    "Estimated Population" AS population
FROM revenues
GROUP BY "Entity Name", "Fiscal Year", "Estimated Population";

-- Query 1b: Total expenditures by county and year
CREATE VIEW expenditure_by_county_year AS
SELECT 
    "Entity Name" AS county,
    "Fiscal Year" AS fiscal_year,
    SUM("Values") AS total_expenditure
FROM expenditures
GROUP BY "Entity Name", "Fiscal Year";

-- Query 2: Combined revenue + expenditure view
CREATE VIEW county_finances_combined AS
SELECT 
    r.county,
    r.fiscal_year,
    r.population,
    r.total_revenue,
    e.total_expenditure,
    r.total_revenue - e.total_expenditure AS net_total,
    ROUND(CAST(r.total_revenue AS FLOAT) / r.population, 2) AS revenue_per_capita,
    ROUND(CAST(e.total_expenditure AS FLOAT) / r.population, 2) AS expenditure_per_capita
FROM revenue_by_county_year r
JOIN expenditure_by_county_year e
    ON r.county = e.county AND r.fiscal_year = e.fiscal_year;

-- Query 3: Year-over-year change per county (reference only, not saved as view)
-- SELECT 
--     county, fiscal_year, net_total,
--     LAG(net_total) OVER (PARTITION BY county ORDER BY fiscal_year) AS prior_year_net,
--     net_total - LAG(net_total) OVER (PARTITION BY county ORDER BY fiscal_year) AS yoy_change
-- FROM county_finances_combined
-- ORDER BY county, fiscal_year;

-- Query 4 FINAL: Per-capita trend ranking with volatility + reliability ratio
-- This is the core output to export for Tableau
WITH yoy_trends AS (
    SELECT 
        county,
        fiscal_year,
        net_total,
        population,
        net_total - LAG(net_total) OVER (PARTITION BY county ORDER BY fiscal_year) AS yoy_change
    FROM county_finances_combined
),
yoy_trends_per_capita AS (
    SELECT 
        county,
        fiscal_year,
        ROUND(CAST(yoy_change AS FLOAT) / population, 2) AS yoy_change_per_capita
    FROM yoy_trends
    WHERE yoy_change IS NOT NULL
),
avg_trend AS (
    SELECT 
        county,
        AVG(yoy_change_per_capita) AS avg_yearly_change_per_capita,
        SQRT(
            AVG(yoy_change_per_capita * yoy_change_per_capita) 
            - AVG(yoy_change_per_capita) * AVG(yoy_change_per_capita)
        ) AS volatility,
        COUNT(*) AS years_counted
    FROM yoy_trends_per_capita
    GROUP BY county
)
SELECT 
    county,
    ROUND(avg_yearly_change_per_capita, 2) AS avg_change,
    ROUND(volatility, 2) AS volatility,
    ROUND(avg_yearly_change_per_capita / volatility, 3) AS reliability_ratio,
    years_counted,
    RANK() OVER (ORDER BY avg_yearly_change_per_capita DESC) AS naive_rank,
    RANK() OVER (ORDER BY avg_yearly_change_per_capita / volatility DESC) AS reliability_rank
FROM avg_trend
ORDER BY reliability_rank;