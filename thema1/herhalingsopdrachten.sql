-- 1.
SELECT s.stuknr, s.titel, c.naam FROM Stuk s 
INNER JOIN Componist c ON s.componistId = c.componistId
WHERE genrenaam = 'klassiek'

-- 2.
SELECT s.stuknr, s.titel, c.naam, m.naam FROM Stuk s
INNER JOIN Componist c
ON s.componistId = c.componistId
INNER JOIN Muziekschool m
ON c.schoolId = m.schoolId
WHERE c.schoolId IS NOT NULL

-- 3. 
SELECT stuknr, titel FROM Stuk
WHERE stuknr IN (SELECT stuknr FROM Bezettingsregel WHERE instrumentnaam = 'saxofoon')

-- 4.
SELECT DISTINCT s.stuknr
FROM Stuk s
INNER JOIN Bezettingsregel b
ON s.stuknr = b.stuknr
WHERE instrumentnaam != 'saxofoon'

-- 5. 
SELECT b.stuknr, COUNT(b.instrumentnaam)
FROM Stuk s
INNER JOIN Bezettingsregel b
ON s.stuknr = b.stuknr
WHERE genrenaam = 'jazz' 
GROUP BY b.stuknr

-- 7.
SELECT n.niveaucode, n.omschrijving, COUNT(s.stuknr)
FROM Niveau n
LEFT JOIN Stuk s
ON n.niveaucode = s.niveaucode AND s.genrenaam = 'klassiek'
GROUP BY n.niveaucode, n.omschrijving

-- 9.
Voorspelling: 4
SELECT	*
	FROM	Componist, Muziekschool;

-- 10.
SELECT naam, count(naam)
FROM Componist
GROUP BY naam
HAVING count(naam) >= 2

-- 11.

BEGIN TRANSACTION
	UPDATE Componist
	SET schoolId = 1
	WHERE componistId = 1

	UPDATE Stuk
	SET niveaucode = 'C'
	FROM Stuk s
	INNER JOIN Componist c
	on s.componistId = c.componistId
	INNER JOIN Muziekschool m
	on c.schoolId = m.schoolId
	WHERE s.niveaucode IS NULL
	AND m.naam = 'Muziekschool Amsterdam'

	SELECT niveaucode from Stuk WHERE stuknr = 1
ROLLBACK TRANSACTION

-- 12.
BEGIN TRANSACTION
	DELETE Bezettingsregel
	FROM Bezettingsregel b
	INNER JOIN Stuk s
	on b.stuknr = s.stuknr
	INNER JOIN Componist c
	on c.componistId = s.componistId
	INNER JOIN Muziekschool m
	on c.schoolId = m.schoolId
	WHERE m.naam = 'Muziekschool Amsterdam'

	SELECT * FROM Bezettingsregel
ROLLBACK TRANSACTION


