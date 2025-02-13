/*
 * QUESTION n. 3: Which food category has the slowest increase in price?
 */

SELECT *
FROM t_premysl_pleva_project_SQL_primary_final pp
WHERE LENGTH(code) != 1;


/*
 * Step 1: calculate percentual difference between consecutive years
 */
SELECT
	code,
	name,
	ROUND((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100, 2) AS percentual_difference, 
	year
FROM 
	t_premysl_pleva_project_SQL_primary_final pp
WHERE 
	LENGTH(code) != 1;

/*
 * Step 2: Utilize previous query to find out average percentual increase in price for the whole period
 */
WITH perc_diff AS(
	SELECT
		code,
		name,
		ROUND((value / LAG(value) OVER (PARTITION BY code ORDER BY year) - 1) * 100, 2) AS percentual_difference, 
		year
	FROM 
		t_premysl_pleva_project_SQL_primary_final pp
	WHERE 
		LENGTH(code) != 1
)
SELECT 
	name,
	ROUND(AVG(percentual_difference), 2) AS avg_perc_diff
FROM
	perc_diff
GROUP BY
	name
ORDER BY
	avg_perc_diff;
	