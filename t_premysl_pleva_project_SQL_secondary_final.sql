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