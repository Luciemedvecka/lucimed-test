# Průvodní listina k projektu SQL

**Autor:** Lucie Medvecka  
**Název souborů:** `Primary_table_vyzkumne_otazky.sql` a `Secondary_table.sql`  
**Období zpracování:** 2006–2018

---

## Úvod

Tato práce se zabývá analýzou vývoje vybraných ekonomických a sociálních ukazatelů v České republice a Evropě v období let **2006 až 2018**. Výchozími datovými zdroji byly předem zadané tabulky:

- `economies`
- `countries`
- `czechia_payroll`
- `czechia_price`
- `czechia_price_category`
- `czechia_payroll_industry_branch`

Zvolený časový úsek vychází z průniku dostupnosti dat napříč tabulkami a pokrývá roky 2006–2018.

---

## Cíle práce

Cílem bylo:

- sjednotit data z různých zdrojů do dvou výstupních tabulek (primární a sekundární),
- zodpovědět předem definované **výzkumné otázky** pomocí SQL dotazů.

---

## Vytvořené výstupní tabulky

### 1. `t_luc_medvecka_project_sql_primary_final`

Tato tabulka slouží jako hlavní zdroj dat pro analýzy vztahující se k České republice. Obsahuje:

- HDP (GDP) v ČR podle roku,
- průměrné mzdy v jednotlivých odvětvích a jejich názvy,
- průměrné roční ceny vybraných potravin a názvy těchto potravin,
- měřené množství a měrné jednotky k cenám.

### 2. `t_luc_medvecka_project_sql_secondary_final`

Sekundární tabulka obsahuje socioekonomické ukazatele pro **všechny evropské země**:

- HDP(GDP),
- populaci,
- koeficient Gini.

Tabulka slouží zejména pro srovnání mezi státy a pro doplňující analýzy evropského kontextu.

**Poznámka ke kvalitě dat:**

- Ve sloupci *populace* jsou údaje kompletní.
- Ve sloupci *GDP* chybí data pro: Faroe Islands, Gibraltar, Lichtenštejnsko.
- Ve sloupci *gini* chybí data pro:
  - všechny roky: San Marino, Monako, Gibraltar, Andorra,
  - některé roky: Albánie, Bosna a Hercegovina, Chorvatsko, Německo, Island, Irsko, Černá Hora, Severní Makedonie, Srbsko, Slovensko, Velká Británie.

---

## Výzkumné otázky

### 1. Rostou v průběhu let mzdy ve všech odvětvích?

Ne. V některých letech a odvětvích došlo k meziročnímu poklesu mezd. Nejčastěji v roce **2013**, a to až v 11 odvětvích.

**Roky a odvětví s poklesem:**

2009	Těžba a dobývání
2009	Ubytování, stravování a pohostinství
2009	Zemědělství, lesnictví, rybářství
2010	Profesní, vědecké a technické činnosti
2010	Veřejná správa a obrana; povinné sociální zabezpečení
2010	Vzdělávání
2011	Kulturní, zábavní a rekreační činnosti
2011	Ubytování, stravování a pohostinství
2011	Veřejná správa a obrana; povinné sociální zabezpečení
2013	Administrativní a podpůrné činnosti
2013	Informační a komunikační činnosti
2013	Kulturní, zábavní a rekreační činnosti
2013	Peněžnictví a pojišťovnictví
2013	Profesní, vědecké a technické činnosti
2013	Stavebnictví
2013	Těžba a dobývání
2013	Velkoobchod a maloobchod; opravy a údržba motorových vozidel
2013	Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu
2013	Zásobování vodou; činnosti související s odpady a sanacemi
2013	Činnosti v oblasti nemovitostí
2014	Těžba a dobývání
2015	Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu
2016	Těžba a dobývání


---

### 2. Kolik si lze koupit litrů mléka a kilogramů chleba za průměrnou mzdu v letech 2006 a 2018?

→ V roce 2018 bylo možné koupit více mléka i chleba než v roce 2006, navzdory nárůstu cen.

| Rok  | Produkt                     | Počet jednotek za mzdu   |
|:----:|----------------------------:|-------------------------:|
| 2006 | Chléb konzumní kmínový      | 1287,5                   |
| 2018 | Chléb konzumní kmínový      | 1342,2                   |
| 2006 | Mléko polotučné pasterované | 1437,3                   |
| 2018 | Mléko polotučné pasterované | 1641,6                   |

---

### 3. Která potravina zdražovala nejpomaleji?

→ **Cukr krystalový** – měl průměrný roční *pokles* ceny **−1,92 %**.

---
### 4. Existoval rok, kdy byl nárůst cen potravin výrazně vyšší než růst mezd?

→ Ne. V žádném roce nepřekročil průměrný meziroční nárůst cen potravin 10 %.

---

### 5. Má vývoj HDP vliv na vývoj mezd a cen potravin?

→ U **mezd** existuje určitá korelace s HDP, u **cen potravin** ale nikoliv.

| Rok  | HDP (%) | Ceny (%) | Mzdy (%) |
|:----:|--------:|---------:|---------:|
| 2007 |  5,57   |  9,26    |  6,91    |
| 2008 |  2,69   |  8,92    |  7,24    |
| 2009 | -4,66   | -6,59    |  2,97    |
| 2010 |  2,43   |  1,52    |  2,17    |
| 2011 |  1,76   |  4,84    |  2,24    |
| 2012 | -0,79   |  7,47    |  2,72    |
| 2013 | -0,05   |  6,00    | -0,78    |
| 2014 |  2,26   | -0,62    |  2,52    |
| 2015 |  5,39   | -0,67    |  2,84    |
| 2016 |  2,54   | -1,40    |  3,95    |
| 2017 |  5,17   |  7,06    |  6,57    |
| 2018 |  3,20   |  2,41    |  7,78    |

Legenda:

- **HDP** – průměrný roční růst HDP v %
- **Ceny** – průměrný roční růst cen vybraných potravin
- **Mzdy** – průměrný roční růst mezd ve všech odvětvích

---

**Lucie Medvecka** 
*lucmedvecka@seznam.cz*
*7. října 2025*

