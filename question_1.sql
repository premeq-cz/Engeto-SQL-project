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
	t_premysl_pleva_project_SQL_primary _final
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
		t_premysl_pleva_project_SQL_primary_final 
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
/*
 * Average year to year percentual increase across all industries
 */
WITH avg_percent_change AS(
	SELECT 
		*,
		ROUND(((value / LAG(value) OVER (PARTITION BY name, code ORDER BY year)) - 1) * 100, 2) AS percent_change
	FROM
		t_premysl_pleva_project_SQL_primary_final 
	WHERE
		LENGTH(code) = 1
	ORDER BY
		code, year
)
SELECT AVG(percent_change)
FROM avg_percent_change apc;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------

/*
 * Average year to year percentual increase in each industry,
 * with assigned "power" as -1 for weaker industries, 1 for strong industries, and 0 fo others
 */
WITH avg_percent_change AS(
	SELECT 
		*,
		ROUND(((value / LAG(value) OVER (PARTITION BY name, code ORDER BY year)) - 1) * 100, 2) AS percent_change
	FROM
		t_premysl_pleva_project_SQL_primary_final 
	WHERE
		LENGTH(code) = 1
	ORDER BY
		code, year
)
SELECT
	name,
	ROUND(AVG(percent_change), 2) AS avg_percent_change,
	CASE
		WHEN ROUND(AVG(percent_change), 2) < 3.1 THEN '-1'
		WHEN ROUND(AVG(percent_change), 2) > 4 THEN '1'
		ELSE '0'
	END AS power
FROM avg_percent_change apc
GROUP BY
	name
ORDER BY
	power, avg_percent_change;