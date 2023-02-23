-- 1.
SELECT CAST(stuknr AS nvarchar) + ' - ' + titel AS StukTitel
FROM Stuk

-- 1. Optional
SELECT CAST(FORMAT(stuknr, '00') AS nvarchar) + ' - ' + titel AS StukTitel
FROM Stuk

-- 2.
SELECT stuknr
FROM Stuk
WHERE stuknr LIKE '%1%';

-- 3.
SELECT CONVERT(nvarchar, GETDATE(), 104) as 'German date notation'