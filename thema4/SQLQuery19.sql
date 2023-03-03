-- 1.
DECLARE @banknumber varchar(9) = 453423574
DECLARE @index int = 9
DECLARE @sum int = 0
DECLARE @substringCounter INT = 1;

WHILE (@index > 0)
BEGIN
	IF @index = 0
	BEGIN
	 SET @index = 9
	 SET @substringCounter = 0
	END
	
	SET @sum = @sum + @index * SUBSTRING(@banknumber, @subStringCounter, 1)

	SET @substringCounter = @substringCounter + 1
	SET @index = @index - 1
END

IF @sum % 11 = 0
	BEGIN
		PRINT @banknumber + ' is GELDIG'
	END
ELSE
	BEGIN
		PRINT @banknumber + ' is NIET geldig'
	END

-- 2.