-- 1.
WITH oudste_stuk AS (
select s2.stuknr, s2.titel, s2.jaartal
from stuk s2
where exists(
    select count(*) from stuk s
    where s.jaartal < s2.jaartal
    having count(*) < 1)
),

meeste_bezettingsregels AS (
select o.stuknr, o.titel, o.jaartal, SUM(b.aantal) as aantal
FROM oudste_stuk o
INNER JOIN Bezettingsregel b
ON o.stuknr = b.stuknr
GROUP BY o.stuknr, o.titel, o.jaartal
)

SELECT * FROM meeste_bezettingsregels

