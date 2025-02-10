/* 
 * QUESTION n. 1 - What is the trend of salaries across given industries?
 */

/*
 * Step 1: query for calculating percentual change over given time period 2008 - 2018
 */

SELECT
	*,
	ROUND(((value / LAG(value) OVER (PARTITION BY name, code ORDER BY year)) - 1) * 100, 2) AS percent_change
FROM
	t_premysl_pleva_project_SQL_primary 
WHERE
	LENGTH(code) = 1
ORDER BY
	code, year;



/*
 * Step 2: utilize the previous query for calculating average percentual change over the whole time period for each industry
 */


WITH avg_percent_change AS(
	SELECT 
		*,
		ROUND(((value / LAG(value) OVER (PARTITION BY name, code ORDER BY year)) - 1) * 100, 2) AS percent_change
	FROM
		t_premysl_pleva_project_SQL_primary 
	WHERE
		LENGTH(code) = 1
	ORDER BY
		code, year
)
SELECT
	name,
	ROUND(AVG(percent_change), 2) AS avg_percent_change
FROM
	avg_percent_change
GROUP BY
	name;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------------------

/*
 * This is just an attempt at normalizing the data and calculating the slope of a line representing the trend of each industry (least square method)
 */

WITH stats AS (
    SELECT
    	name, code,
        AVG(year) AS avg_year,
        STDDEV(year) AS stddev_year,
        AVG(value) AS avg_value,
        STDDEV(value) AS stddev_value
    FROM
        t_premysl_pleva_project_SQL_primary
    GROUP BY
        name, code
),
normalized_data AS (
    SELECT
    	pp.name, pp.code,
        (year - stats.avg_year) / stats.stddev_year AS norm_year,
        (value - stats.avg_value) / stats.stddev_value AS norm_value
    FROM
        t_premysl_pleva_project_SQL_primary pp, stats
    GROUP BY
        name, code
),
slope_calc AS (
    SELECT
    	name, code,
        SUM(norm_year * norm_value) / SUM(norm_year * norm_year) AS slope
    FROM
        normalized_data
    GROUP BY
        name, code
)
SELECT
    code, name, slope
FROM
    slope_calc
ORDER BY
	code;