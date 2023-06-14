-- 1.
SELECT stuknr, speelduur,
CASE 
	WHEN speelduur BETWEEN 0 AND 3 THEN 'Kort'
	WHEN speelduur BETWEEN 3 AND 5 THEN 'Gemiddeld'
	WHEN speelduur > 5 THEN 'Lang'
	ELSE 'n.v.t'
END AS SpeelduurCategorie
FROM Stuk

-- 2.
WITH speelduur AS (
SELECT stuknr, speelduur,
CASE
	WHEN speelduur BETWEEN 0 AND 3 THEN 'Kort'
	WHEN speelduur BETWEEN 3 AND 5 THEN 'Gemiddeld'
	WHEN speelduur > 5 THEN 'Lang'
	ELSE 'n.v.t'
END AS speelduurCategorie
FROM Stuk s)

SELECT speelduurCategorie, COUNT(speelduurCategorie) AS aantal
FROM speelduur
GROUP BY speelduurCategorie

-- 3.
SELECT
    CASE 
        WHEN DATEPART(WEEKDAY, GETDATE()) = 1 THEN 'Zondag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 2 THEN 'Maandag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 3 THEN 'Dinsdag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 4 THEN 'Woensdag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 5 THEN 'Donderdag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 6 THEN 'Vrijdag'
        WHEN DATEPART(WEEKDAY, GETDATE()) = 7 THEN 'Zaterdag'
    END AS 'Dag_van_de_week'
