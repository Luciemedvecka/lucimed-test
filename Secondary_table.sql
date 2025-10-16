--Tabulka č. 2 - vytvoření sekundární tabulky t_luc_medvecka_project_sql_secondary_final
    
CREATE TABLE t_luc_medvecka_project_sql_secondary_final AS
SELECT e.YEAR, e.country, e.population, e.gdp, e.gini
FROM countries c
LEFT JOIN economies e ON c.country = e.country
WHERE e.YEAR BETWEEN 2006 AND 2018 AND c.continent = 'Europe'
ORDER BY e.YEAR, e.country;  

-- Zjišťování, zda ve sloupci populace je nulová hodnota

SELECT e.YEAR, e.country, e.population, e.gdp, e.gini
FROM countries c
LEFT JOIN economies e ON c.country = e.country
WHERE e.YEAR BETWEEN 2006 AND 2018 AND c.continent = 'Europe' AND e.population IS NULL
ORDER BY e.YEAR, e.country;

-- Zjišťování, zda ve sloupci gdp je nulová hodnota

SELECT e.YEAR, e.country, e.population, e.gdp, e.gini
FROM countries c
LEFT JOIN economies e ON c.country = e.country
WHERE e.YEAR BETWEEN 2006 AND 2018 AND c.continent = 'Europe' AND e.gdp IS NULL
ORDER BY e.country;

-- Zjišťování, zda ve sloupci gini je nulová hodnota

SELECT e.YEAR, e.country, e.population, e.gdp, e.gini
FROM countries c
LEFT JOIN economies e ON c.country = e.country
WHERE e.YEAR BETWEEN 2006 AND 2018 AND c.continent = 'Europe' AND e.gini IS NULL
ORDER BY e.country;

/*Všechny údaje ve sloupci populace jsou vyplněné, ve sloupci gdp nemá vyplněné hodnoty Faroe Islands, Gibraltar a Lichtejnštejnsko 
a ve sloupci gini mimo tři již zmíněné země také San Marino, Monaco, Gibraltar, Andora během celého sledovaného období a mimoto nemají 
úplné záznamy Albánie, Bosna a Hercegovina, Chorvatsko, Německo, Island, Irsko, Černá Hora, Severní Makedonie, Srbsko, Slovensko a Velká Británie.