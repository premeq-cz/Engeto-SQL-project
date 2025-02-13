/* 
 * QUESTION . 2: How many litres of milk and kilograms of bread can you purchase in the first and last comparable period?
 */


/*
 * Step 1: create a view that compares wages and purchasing power in the years 2006 and 2018
 */

CREATE OR REPLACE VIEW milk_bread_prep AS 
SELECT
	pp2006.name,
	pp2006.value AS wage_2006,
	pp2018.value AS wage_2018,
	ROUND(pp2006.value / 14.44, 2) AS litres_of_milk_2006,
	ROUND(pp2018.value / 19.82, 2) AS litres_of_milk_2018,
	ROUND(pp2006.value / 16.12, 2) AS kgs_of_bread_2006,
	ROUND(pp2018.value / 24.24, 2) AS kgs_of_bread_2018
FROM
	t_premysl_pleva_project_SQL_primary_final pp2006
JOIN
	t_premysl_pleva_project_SQL_primary_final pp2018
ON
	pp2006.name = pp2018.name
WHERE 
	LENGTH(pp2006.code) = 1
	AND LENGTH(pp2018.code) = 1
	AND pp2006.year = 2006
	AND pp2018.year = 2018;

/*
 * Step 2: Calculate average quantity of milk and bread that could be purchased for average salary in the years 2006 and 2018
 */
SELECT 
	AVG(wage_2006) AS avg_wage_2006,
	AVG(wage_2018) AS avg_wage_2018,
	AVG(litres_of_milk_2006) AS avg_milk_2006,
	AVG(litres_of_milk_2018) AS avg_milk_2018,
	AVG(kgs_of_bread_2006) AS avg_bread_2006,
	AVG(kgs_of_bread_2018) AS avg_bread_2018 
FROM milk_bread_prep
;


/*
 * Calculate average percentual increase of wages across all industries and
 * calculating percentual increase of purchasing power of milk and bread between 2006 and 2018
 */
WITH avg_perc_milk_bread AS (
SELECT 
	AVG(wage_2006) AS avg_wage_2006,
	AVG(wage_2018) AS avg_wage_2018,
	AVG(litres_of_milk_2006) AS avg_milk_2006,
	AVG(litres_of_milk_2018) AS avg_milk_2018,
	AVG(kgs_of_bread_2006) AS avg_bread_2006,
	AVG(kgs_of_bread_2018) AS avg_bread_2018 
FROM milk_bread_prep
)
SELECT
	ROUND(((avg_wage_2018 / avg_wage_2006) - 1) * 100, 2) AS avg_wage_increase_perc, 
	ROUND(((avg_milk_2018 / avg_milk_2006) - 1) * 100, 2) AS avg_milk_increase_perc,
	ROUND(((avg_bread_2018 / avg_bread_2006) - 1) * 100, 2) AS avg_bread_increase_perc
FROM
	avg_perc_milk_bread;


/*
 * Step 3: calculate percentual change between 2006 and 2018 of purchasing power of milk and bread in each industry
 */

SELECT
	name,
	ROUND(((litres_of_milk_2018 / litres_of_milk_2006) - 1) * 100, 2) AS change_in_milk,
	ROUND(((kgs_of_bread_2018 / kgs_of_bread_2006) -1) * 100, 2) AS change_in_bread 
FROM
	milk_bread_prep
ORDER BY
	change_in_milk DESC,
	change_in_bread;