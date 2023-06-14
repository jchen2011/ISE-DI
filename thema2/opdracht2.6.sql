-- 1.
WITH oudste_stukken
         AS
         (
             SELECT stuknr
             FROM Stuk
             WHERE jaartal = (SELECT MIN(jaartal) FROM Stuk)
         )
SELECT TOP 1 o.stuknr, SUM(b.aantal)
FROM oudste_stukken o
         INNER JOIN Bezettingsregel b
                    ON o.stuknr = b.stuknr
GROUP BY o.stuknr
ORDER BY SUM(aantal) DESC

-- 2.
    WITH oudste_stukken
AS
(
SELECT stuknr
FROM Stuk
WHERE jaartal = (SELECT MIN(jaartal) FROM Stuk)
), oudste_stukken_en_meeste_bezettingsregels AS	(
SELECT TOP 1 o.stuknr, SUM(b.aantal) AS total_aantal
FROM oudste_stukken o
INNER JOIN Bezettingsregel b
ON o.stuknr = b.stuknr
GROUP BY o.stuknr
ORDER BY SUM(aantal) DESC
)
SELECT b.stuknr, osemb.total_aantal, SUM(b.aantal) AS total_aantal
FROM oudste_stukken_en_meeste_bezettingsregels osemb
         INNER JOIN Bezettingsregel b
                    ON osemb.stuknr != b.stuknr
GROUP BY b.stuknr, osemb.total_aantal
HAVING SUM(b.aantal) = osemb.total_aantal


