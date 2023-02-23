-- 1.

SELECT stuknr, titel
FROM Stuk s
WHERE EXISTS (
SELECT stuknr
FROM Bezettingsregel
WHERE s.stuknr = stuknr
AND instrumentnaam = 'piano')

-- 2.
SELECT stuknr, titel
FROM Stuk s
WHERE NOT EXISTS (
SELECT stuknr
FROM Bezettingsregel
WHERE s.stuknr = stuknr
AND instrumentnaam = 'piano')

-- 3.
SELECT instrumentnaam, toonhoogte
FROM Instrument i
WHERE NOT EXISTS (
SELECT instrumentnaam, toonhoogte
FROM Bezettingsregel
WHERE i.instrumentnaam = instrumentnaam
AND i.toonhoogte = toonhoogte)

-- 4.
SELECT c.naam, c.componistid
FROM Componist C
WHERE exists (
    SELECT componistId
    FROM Stuk s
    WHERE s.componistId = c.componistId
    GROUP BY componistId
    HAVING count(stuknr) > 1)

-- 5.

-- 6.

SELECT jaartal
FROM Stuk

SELECT jaartal
FROM Stuk

select s2.stuknr, s2.jaartal
from stuk s2
where exists(
    select count(*) from stuk s
    where s.jaartal < s2.jaartal
    having count(*) < 3);


select s2.stuknr, s2.jaartal, (
select count(*) from stuk s
where s.jaartal < s2.jaartal) as aantal_ouder_dan
from stuk s2
where (
    select count(*) from stuk s
    where s.jaartal < s2.jaartal) < 3
order by aantal_ouder_dan


-- 7.
SELECT s.stuknr 
FROM Stuk s
WHERE EXISTS (
	SELECT stuknr
	FROM Bezettingsregel 


