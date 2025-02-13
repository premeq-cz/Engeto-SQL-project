/*
 * QUESTION n. 4: Does exist a year when year to year increase in groceries prices was higher than in salaries?
 */



/*
 * Step 1: filter out salaries and calculate year to year percentual change
 */
SELECT
	name AS industry_name,
	ROUND(((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100), 2) AS perc_change_salary,
	year
FROM 
	t_premysl_pleva_project_SQL_primary_final pp
WHERE LENGTH(code) = 1
ORDER BY code, year;


/*
 * Step 2: filter out food and calculate year to year percentual change
 */
SELECT
	name AS food_name,
	ROUND(((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100), 2) AS perc_change_food,
	year
FROM 
	t_premysl_pleva_project_SQL_primary_final pp
WHERE LENGTH(code) != 1
ORDER BY code, year;


/*
 * Step 3: Utilize previous filters to calculate average percentual change in both categories, food and salaries,
 * and make into a VIEW
 */
CREATE OR REPLACE VIEW v_premysl_pleva_perc_change AS
WITH
	food AS(
		SELECT 
			year,
			ROUND(AVG(value), 2) AS avg_food 
		FROM 
			t_premysl_pleva_project_SQL_primary_final pp
		WHERE 
			LENGTH(code) != 1
		GROUP BY 
			year
	),
	salary AS(
		SELECT 
			year,
			ROUND(AVG(value)) AS avg_salary 
		FROM 
			t_premysl_pleva_project_SQL_primary_final pp
		WHERE 
			LENGTH(code) = 1
		GROUP BY 
			year
	)
SELECT
	food.year,
	ROUND(((food.avg_food / LAG(food.avg_food) OVER (ORDER BY year)) - 1) * 100, 2) AS avg_perc_change_food,
	ROUND(((salary.avg_salary / LAG(salary.avg_salary) OVER (ORDER BY year)) - 1) * 100, 2) AS avg_perc_change_salary 
FROM
	food
JOIN
	salary ON food.year = salary.year
;


/*
 * Step 4: Finding a year when insrease in food was significantly higher then increase in salaries (at least 10%)
 */
SELECT
	*
FROM
	v_premysl_pleva_perc_change vpppc
WHERE 
	avg_perc_change_food > 10
	AND avg_perc_change_food > avg_perc_change_salary ;



/*
 * Step 5: No results in Step 4, so let's take a look at the VIEW
 */
SELECT
	*,
	avg_perc_change_food - avg_perc_change_salary AS diff
FROM
	v_premysl_pleva_perc_change vpppc
WHERE 
	avg_perc_change_food > avg_perc_change_salary;