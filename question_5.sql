/*
 * QUESTION n. 5: Does the level of GDP affect changes in wages and food prices?
 * In other words, if GDP increases more significantly in one year, will this be reflected
 * in a more significant increase in food prices or wages in the same or the following year?
 */


/*
 * Step 1: From table "economies" filter out CZ for years between 2006 and 2018 and calculate percentual change in GDP
 */
SELECT
	year,
	GDP,
	ROUND(((GDP / LAG(GDP) OVER (ORDER BY year)) - 1) * 100, 2) AS perc_change_GDP
FROM 
	economies e 
WHERE 
	year BETWEEN 2006 and 2018
	AND country = 'Czech Republic'
;



/*
 * Step 2: Join together data about percentual change in food and salaires with percentual change in GDP
 */
CREATE OR REPLACE TABLE t_premysl_pleva_perc_change_food_salary_GDP AS
SELECT
	vpppc.*,
	ROUND(((e.GDP / LAG(e.GDP) OVER (ORDER BY e.year)) - 1) * 100, 2) AS perc_change_GDP
FROM 
	economies e
JOIN
	v_premysl_pleva_perc_change vpppc
	ON e.year = vpppc.year
WHERE 
	e.year BETWEEN 2006 and 2018
	AND e.country = 'Czech Republic';


/*
 * Step 3: Identify years where GDP had significant increase, i.e. higher then/equal to 5%
 */
SELECT 
	year,
	perc_change_GDP 
FROM 
	t_premysl_pleva_perc_change_food_salary_GDP
WHERE 
	perc_change_GDP >= 5;

/*
 * Step 4a: Average food and salay change in significant years (GDP-wise)
 */
SELECT 
	ROUND(AVG(avg_perc_change_food), 2) AS avg_perc_change_food_significant_GDP,
	ROUND(AVG(avg_perc_change_salary), 2) AS avg_perc_change_salary_significant_GDP 
FROM 
	t_premysl_pleva_perc_change_food_salary_GDP pp
WHERE year IN 
	(SELECT year FROM t_premysl_pleva_perc_change_food_salary_GDP WHERE perc_change_GDP >= 5);


/*
 * Step 4b: Average food and salay change in non-significant years (GDP-wise)
 */
SELECT 
	ROUND(AVG(avg_perc_change_food), 2) AS avg_perc_change_food_non_significant_GDP,
	ROUND(AVG(avg_perc_change_salary), 2) AS avg_perc_change_salary_non_significant_GDP 
FROM 
	t_premysl_pleva_perc_change_food_salary_GDP pp
WHERE year NOT IN 
	(SELECT year FROM t_premysl_pleva_perc_change_food_salary_GDP WHERE perc_change_GDP >= 5);


/*
 * Step 5a: Now comparing average percentual change in years after a significant years for GDP
 */
SELECT 
	ROUND(AVG(gdp2.avg_perc_change_food), 2) AS avg_perc_change_food_after_sig_GDP,
	ROUND(AVG(gdp2.avg_perc_change_salary), 2) AS avg_perc_change_salary_after_sig_GDP 
FROM
	t_premysl_pleva_perc_change_food_salary_GDP gdp1 
JOIN
	t_premysl_pleva_perc_change_food_salary_GDP gdp2 
	ON gdp1.year = gdp2.year - 1
WHERE gdp1.perc_change_GDP >= 5;


/*
 * Step 5b: Now comparing average percentual change in years after a non-significant year for GDP
 */
SELECT 
	ROUND(AVG(gdp2.avg_perc_change_food), 2) AS avg_perc_change_food_after_non_sig_GDP,
	ROUND(AVG(gdp2.avg_perc_change_salary), 2) AS avg_perc_change_salary_after_non_sig_GDP 
FROM
	t_premysl_pleva_perc_change_food_salary_GDP gdp1 
JOIN
	t_premysl_pleva_perc_change_food_salary_GDP gdp2 
	ON gdp1.year = gdp2.year - 1
WHERE gdp1.perc_change_GDP < 5;