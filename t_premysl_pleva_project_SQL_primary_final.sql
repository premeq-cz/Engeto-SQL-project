/*
 * VIEW průměrných cen potravin včetně názvů za daný rok
 */

CREATE OR REPLACE VIEW v_premysl_cz_price AS(
	SELECT codes.name, codes.code, ROUND(AVG(cp.value), 2) AS value, cp.year
	FROM (
		(SELECT cp.value, cp.category_code, YEAR(cp.date_from) AS year
		FROM czechia_price cp) cp
		JOIN (
			SELECT cpc.code, cpc.name
			FROM czechia_price_category cpc) codes
		ON cp.category_code = codes.code)
	GROUP by codes.name, codes.code, cp.year
	ORDER BY codes.code, cp.year
);



SELECT *
FROM v_premysl_cz_price vpcp ;


/* 
 * VIEW payrollu
 */

CREATE OR REPLACE VIEW v_premysl_cz_payroll AS (
	SELECT
		cpib.name, cpib.code, ROUND(AVG(cp.value)) AS value,
		cp.payroll_year AS year
	FROM (
		SELECT
			cp.value,
			cp.payroll_year,
			cp.industry_branch_code 
		FROM
			czechia_payroll cp 
		WHERE
			cp.payroll_year >=2006 
			AND cp.payroll_year <= 2018
			AND cp.calculation_code = 200
			AND cp.value_type_code = 5958) cp
	JOIN
		czechia_payroll_industry_branch cpib
	ON cp.industry_branch_code = cpib.code
	GROUP by
		cp.payroll_year,
		cpib.code,
		cpib.name
);

SELECT *
FROM v_premysl_cz_payroll;


/*
 * Sjednocení dvou view do finální tabulky pro projekt
 */

CREATE OR REPLACE TABLE t_premysl_pleva_project_SQL_primary_final AS (
	SELECT
		*
	FROM
		v_premysl_cz_price vpcp 
	UNION
	SELECT
		*
	FROM
		v_premysl_cz_payroll
	ORDER BY
		year,
		code
);


/*
 * Příklad filtrování mezd a potravin pomocí LENGTH(code) = 1 
 */

SELECT *
FROM t_premysl_pleva_project_SQL_primary_final 
WHERE LENGTH(code) != 1;