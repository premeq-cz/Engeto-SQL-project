CREATE OR REPLACE TABLE t_premysl_pleva_project_SQL_secondary_final AS
SELECT 
	e.`year`,
	c.country,
	e.GDP,
	e.gini 
FROM countries c 
LEFT JOIN economies e ON c.country = e.country 
WHERE 
	c.region_in_world LIKE "% Europe%"
	AND e.`year` BETWEEN 2006 AND 2018
ORDER BY 
	e.year, e.GDP 
;


SELECT *
FROM t_premysl_pleva_project_SQL_secondary_final tpppssf ;