-- 1.
SELECT stuknr, ISNULL(speelduur, 0)
FROM Stuk

-- 2.
SELECT stuknr, speelduur
FROM Stuk
ORDER BY -speelduur

