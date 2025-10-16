/*------------------------------------------------------------------------------------------------------------------------------------------

Výběr období(roky) pro tabulky

Z tabulek, které budu používat jsou roky pouze v tabulce czechia payroll, czechia_price a countries. V countries je na rozdíl od 
druhých dvou tabulek obrovské rozpětí let, proto budu omezovat zkoumané období tabulkama czechia payroll, czechia_price, kde musím 
zjistit období během kterého byly pořizovány záznamy. 

Zjišťování rozpětí v tabulce czechia_payroll

SELECT payroll_year
FROM czechia_payroll cp
ORDER BY payroll_year DESC - 
LIMIT 1;
 
Výsledek jsou roky 2000 - 2021.

Zjišťování rozpětí v tabulce czechia_price

SELECT date_from
FROM czechia_price cp
ORDER BY date_from DESC 
LIMIT 1; 
 
Výsledek jsou roky 2006 - 2018. Společné roky pro všechny tabulky, které budou předmětem zkoumání, jsou tedy 2006 - 2018.

--------------------------------------------------------------------------------------------------------------------------------------------


--GDP v ČR a EU za roky 2006 - 2018
 
SELECT gdp, country, year
FROM economies e
WHERE country IN('Czech Republic','European Union') AND  YEAR BETWEEN 2006 AND 2018
ORDER  BY YEAR ;                    

--GDP v ČR v letech 2006 - 2018

SELECT gdp, year
FROM economies e
WHERE country = 'Czech Republic' AND YEAR BETWEEN 2006 AND 2018
ORDER BY year; */

----------------------------------------------------------------------------------------------------------------------------------------------

/*Tabulka č. 1 - vytvoření primární tabulky t_luc_medvecka_project_sql_primary_final, kerá spojuje gdp pro ČR, průměrné mzdy v 
různých odvětvích a průměrné ceny v letech 2006 - 2018*/


CREATE TABLE t_luc_medvecka_project_sql_primary_final AS
SELECT g.YEAR, g.gdp, w.name AS branch, w.average_wages, p.name AS product, p.average_value, p.price_value, p.price_unit
FROM(--GDP
	SELECT gdp, YEAR 
	FROM economies e
	WHERE country = 'Czech Republic' AND YEAR BETWEEN 2006 AND 2018
	ORDER BY YEAR
) g 
LEFT JOIN (--WAGES
	SELECT acp.average_wages, acp.payroll_year, cpib.name
	FROM (SELECT round(avg(value)::NUMERIC) AS average_wages, payroll_year, industry_branch_code
		FROM czechia_payroll cp
		WHERE value_type_code != 316 AND payroll_year BETWEEN 2006 AND 2018 AND industry_branch_code IS NOT NULL
		GROUP BY payroll_year, industry_branch_code
		ORDER BY payroll_year, industry_branch_code) AS acp
	JOIN czechia_payroll_industry_branch cpib ON code = acp.industry_branch_code
) w ON g.YEAR = w.payroll_year
LEFT JOIN (--Price
	SELECT gcp.category_code, gcp.year, gcp.average_value, cpc.name, cpc.price_value, cpc.price_unit
	FROM (SELECT cp.category_code, date_part('year', cp.date_from)::int AS year, round(avg(cp.value)::NUMERIC,2) AS average_value
		FROM czechia_price cp
		GROUP BY cp.category_code, date_part('year', cp.date_from)::int
		ORDER BY cp.category_code, date_part('year', cp.date_from)::int) AS gcp
	LEFT JOIN czechia_price_category cpc ON cpc.code = gcp.category_code
	WHERE gcp.YEAR BETWEEN 2006 AND 2018 
	ORDER BY gcp.category_code
) p ON g.YEAR = p.year;
  
/*
VÝZKUMNÉ OTÁZKY:

1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách 
ve stejném nebo následujícím roce výraznějším růstem?
------------------------------------------------------------------------------------------------------------------------------------------------*/

--Výzkumná otázka č. 1 - Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT wft.year, wft.branch
FROM (SELECT branch, YEAR, average_wages, LAG(average_wages) OVER(PARTITION BY branch ORDER BY year) AS previous_avg_wages
	FROM t_luc_medvecka_project_sql_primary_final tlmp
	) wft
WHERE average_wages < previous_avg_wages
ORDER BY YEAR, branch;

--Výzkumná otázka č. 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

 /*Průměrné mzdy v prvním a posledním období našeho výběru(ne podle odvětví)

SELECT "year", round(avg(average_wages)::NUMERIC) AS avg_wages
FROM t_luc_medvecka_project_sql_primary_final tlmpspf
WHERE year IN (2006, 2018)
GROUP BY YEAR 
ORDER BY YEAR;

--Ceny mléka a chleba v roce 2006 a 2018(litru mléka a kg chleba)

SELECT YEAR, product, average_value
FROM t_luc_medvecka_project_sql_primary_final tlmpspf
WHERE product = 'Mléko polotučné pasterované' AND YEAR IN (2006, 2018) OR product = 'Chléb konzumní kmínový' AND YEAR IN (2006, 2018)
GROUP BY YEAR, product, average_value 
ORDER BY product, "year"; */


WITH cte_mzdy_vybrane_roky AS (
	SELECT year, round(avg(average_wages)::NUMERIC) AS avg_wages
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf
	WHERE year IN (2006, 2018)
	GROUP BY YEAR 
	), cte_ceny_mleka_chleba AS (
	SELECT YEAR, product, average_value
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf
	WHERE product = 'Mléko polotučné pasterované' AND YEAR IN (2006, 2018) OR product = 'Chléb konzumní kmínový' AND YEAR IN (2006, 2018)
	GROUP BY YEAR, product, average_value 
	), cte_mleko_chleba_mzda AS(
	SELECT cmvr.YEAR, ccmc.product, cmvr.avg_wages/ccmc.average_value AS amount_products
	FROM cte_mzdy_vybrane_roky cmvr
	JOIN cte_ceny_mleka_chleba ccmc ON cmvr.YEAR = ccmc.YEAR
	)
SELECT YEAR, product, round((amount_products)::NUMERIC,1)
FROM cte_mleko_chleba_mzda 
ORDER BY product, year;


--Výzkumná otázka č. 3 - Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?  */

 WITH cte_average_value AS (
	SELECT YEAR, product, AVG(average_value) AS average_value
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf
	GROUP BY YEAR, product, average_value
	ORDER BY product, YEAR
), cte_last_year_average_value AS(
	SELECT YEAR, product, average_value, LAG(average_value) OVER(PARTITION BY product ORDER BY year) AS previous_avg_value
	FROM cte_average_value
	ORDER BY product, year
), cte_aprox_percentage_increase_average_value AS (
	SELECT product, round((sum((average_value - previous_avg_value) * 100 / previous_avg_value) / 12)::NUMERIC, 2) AS percentage_increase
	FROM cte_last_year_average_value
	GROUP BY product
	ORDER BY percentage_increase
)
SELECT cap.product, cap.percentage_increase
FROM cte_aprox_percentage_increase_average_value cap
LEFT JOIN cte_last_year_average_value cly ON cly.product = cap.product
WHERE cly.previous_avg_value IS NOT NULL
ORDER BY cap.percentage_increase
LIMIT 1;


--Výzkumná otázka č.4 - Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


WITH cte_number_of_product AS (
	SELECT YEAR, count(DISTINCT product) AS number_of_product
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf
	GROUP BY YEAR
                                    --mezi roky 2006(nepočítá se, protože není předcházející hodnota) až 2014(8 roků)je počet productů 26 a mezi roky 2015 až 2018(4 roky) je počet produktů 27.
), cte_avg_value AS ( 
	SELECT YEAR, product, avg(average_value) AS avg_value
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf
	GROUP BY YEAR, product
), cte_previous_average_value AS (
	SELECT YEAR, avg_value, LAG(avg_value) OVER (PARTITION BY product ORDER BY year) AS previous_avg_value
	FROM cte_avg_value
), cte_clean_prev_avg_value AS (
	SELECT * 
	FROM cte_previous_average_value
	WHERE previous_avg_value IS NOT NULL 
), cte_sum_year_percentage_increase_value AS (
	SELECT YEAR, round(sum((avg_value - previous_avg_value) * 100 / previous_avg_value)::NUMERIC, 2) AS sum_year_perc_value
	FROM  cte_clean_prev_avg_value --year_percentage_increase_value
	GROUP BY YEAR
), cte_avg_year_percentage_increase_value AS (  
	SELECT syp.YEAR, (syp.sum_year_perc_value / np.number_of_product) AS avg_percentage_year_increase_value
	FROM cte_sum_year_percentage_increase_value syp
	LEFT JOIN cte_number_of_product np ON syp.YEAR = np.YEAR
) 
SELECT YEAR, avg_percentage_year_increase_value
FROM cte_avg_year_percentage_increase_value
WHERE avg_percentage_year_increase_value > 10
ORDER BY year;


 --Výzkumná otázka č.5 - Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

 WITH cte_number_of_branch AS ( 
	 SELECT YEAR, count(DISTINCT branch) AS number_of_branch 
	 FROM t_luc_medvecka_project_sql_primary_final tlmpspf GROUP BY year 
), cte_average_wages AS ( 
	SELECT YEAR, branch, AVG(average_wages) AS average_wages 
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf 
	GROUP BY YEAR, branch 
), cte_previous_average_wages AS ( 
	SELECT YEAR, branch, average_wages, LAG(average_wages) OVER (PARTITION BY branch ORDER BY year) AS previous_avg_wages 
	FROM cte_average_wages 
), cte_clean_prev_avg_wages AS ( 
	SELECT * 
	FROM cte_previous_average_wages 
	WHERE previous_avg_wages IS NOT NULL
), cte_sum_percentage_increase_avg_wages AS( 
	SELECT YEAR, round(sum((average_wages - previous_avg_wages) * 100 / previous_avg_wages)::NUMERIC, 2) AS sum_year_perc_avg_wages 
	FROM cte_clean_prev_avg_wages 
	GROUP BY year
), cte_avg_year_percentage_increase_wages AS (
	 SELECT spi.YEAR,round((spi.sum_year_perc_avg_wages / nb.number_of_branch), 2) AS avg_percentage_year_incr_wages 
	 FROM cte_sum_percentage_increase_avg_wages spi 
	 LEFT JOIN cte_number_of_branch nb ON spi.YEAR = nb.YEAR 
), cte_year_avg_perc_incr_wages AS (                         --meziroční průměrné procentní přírustky mezd 
	SELECT cypi.YEAR, cypi.avg_percentage_year_incr_wages 
	FROM cte_clean_prev_avg_wages cpaw 
	LEFT JOIN cte_avg_year_percentage_increase_wages cypi ON cypi.YEAR = cpaw.year 
	WHERE cpaw.previous_avg_wages IS NOT NULL AND cypi.avg_percentage_year_incr_wages IS NOT NULL 
	GROUP BY cypi.YEAR, cypi.avg_percentage_year_incr_wages 
), cte_number_of_product AS (
	SELECT YEAR, count(DISTINCT product) AS number_of_product 
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf 
	GROUP BY YEAR         --mezi roky 2006(nepočítá se, protože není předcházející hodnota) až 2014(8 roků)je počet productů 26 a mezi roky 2015 až 2018(4 roky) je počet produktů 27. 	), cte_avg_value AS ( 
	SELECT YEAR, product, avg(average_value) AS avg_value 
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf 
	GROUP BY YEAR, product 
), cte_previous_average_value AS ( 
	SELECT YEAR, avg_value, LAG(avg_value) OVER (PARTITION BY product ORDER BY year) AS previous_avg_value 
	FROM cte_avg_value 
), cte_clean_prev_avg_value AS ( 
	SELECT * 
	FROM cte_previous_average_value 
	WHERE previous_avg_value IS NOT NULL 
), cte_sum_year_percentage_increase_value AS ( 
	SELECT YEAR, round(sum((avg_value - previous_avg_value) * 100 / previous_avg_value)::NUMERIC, 2) AS sum_year_perc_value
	FROM cte_clean_prev_avg_value 
	GROUP BY YEAR 
), cte_avg_year_percentage_increase_value AS ( 
	SELECT syp.YEAR, round((syp.sum_year_perc_value / np.number_of_product), 2) AS avg_percentage_year_increase_value 
	FROM cte_sum_year_percentage_increase_value syp 
	LEFT JOIN cte_number_of_product np ON syp.YEAR = np.YEAR 
), cte_year_avg_perc_incr_value AS (          --meziroční průměrné nárusty cen potravin 
	SELECT YEAR, avg_percentage_year_increase_value 
	FROM cte_avg_year_percentage_increase_value 
), cte_gdp_cr AS (                             --meziroční procentuální nárůsty GDP v ČR 
	SELECT YEAR, round(avg(gdp)::NUMERIC, 3) AS gdp 
	FROM t_luc_medvecka_project_sql_primary_final tlmpspf 
	GROUP BY YEAR 
), cte_year_perc_avg_incr_gdp AS ( 
	SELECT YEAR, gdp, LAG(gdp) OVER (ORDER BY year) AS previous_gdp, round(((gdp - LAG(gdp) OVER (ORDER BY year)) * 100 / LAG(gdp) OVER (ORDER BY year))::NUMERIC, 2) AS year_perc_avg_incr_gdp
	FROM cte_gdp_cr 
), cte_cl_year_perc_avg_incr_gdp AS (
	 SELECT YEAR, year_perc_avg_incr_gdp 
	 FROM cte_year_perc_avg_incr_gdp 
	 WHERE year_perc_avg_incr_gdp IS NOT NULL 
) 
SELECT gc.YEAR, gc.year_perc_avg_incr_gdp, yap.avg_percentage_year_increase_value, yapi.avg_percentage_year_incr_wages 
FROM cte_cl_year_perc_avg_incr_gdp gc 
JOIN cte_year_avg_perc_incr_value yap ON gc.YEAR = yap.YEAR 
JOIN cte_year_avg_perc_incr_wages yapi ON yapi.YEAR = yap.YEAR 
ORDER BY gc.YEAR;
