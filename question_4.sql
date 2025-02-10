/*
 * QUESTION n. 4: Does exist a year when year to year increase in groceries prices was higher than in salaries?
 */



/*
 * Step 1: filter out salaries
 */
SELECT
	name AS industry_name,
	ROUND(((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100), 2) AS perc_change_industry,
	year
FROM 
	t_premysl_pleva_project_SQL_primary pp
WHERE LENGTH(code) = 1
ORDER BY code, year;


/*
 * Step 2: filter out food
 */
SELECT
	name AS food_name,
	ROUND(((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100), 2) AS perc_change_food,
	year
FROM 
	t_premysl_pleva_project_SQL_primary pp
WHERE LENGTH(code) != 1
ORDER BY year;


/*
 * Step 3: Utilize previous filters to calculate average percentual change in both categories, food and salaries and make in onto a VIEW
 */
CREATE OR REPLACE VIEW v_premysl_pleva_perc_change AS
WITH
	food AS(
		SELECT 
			year,
			ROUND(AVG(value), 2) AS avg_food 
		FROM 
			t_premysl_pleva_project_SQL_primary pp
		WHERE 
			LENGTH(code) != 1
		GROUP BY 
			year
	),
	industry AS(
		SELECT 
			year,
			ROUND(AVG(value)) AS avg_industry 
		FROM 
			t_premysl_pleva_project_SQL_primary pp
		WHERE 
			LENGTH(code) = 1
		GROUP BY 
			year
	)
SELECT
	food.year,
	ROUND(((food.avg_food / LAG(food.avg_food) OVER (ORDER BY year)) - 1) * 100, 2) AS perc_change_food,
	ROUND(((industry.avg_industry / LAG(industry.avg_industry) OVER (ORDER BY year)) - 1) * 100, 2) AS perc_change_industry 
FROM
	food
JOIN
	industry ON food.year = industry.year
;


/*
 * Step 4: Finding a year when insrease in food was significantly higher then increase in salaries (at least 10%)
 */
SELECT
	*
FROM
	v_premysl_pleva_perc_change vpppc
WHERE 
	perc_change_food > 10
	AND perc_change_food > perc_change_industry ;