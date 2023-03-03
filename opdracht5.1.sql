SELECT * FROM Product
SELECT * FROM Customer
SELECT * FROM Orders
SELECT * FROM Order_Detail


-- 3.
CREATE PROCEDURE spReadyOrders
AS
BEGIN
	SELECT o.CUSTOMERID, c.CUSTOMERNAME, o.ORDERNR, o.ORDERSTATUS
	FROM Orders  o
	INNER JOIN Customer c
	ON o.CUSTOMERID = c.CUSTOMERID
	WHERE OrderStatus = 'Ready'
END

EXEC spReadyOrders

-- 4.
CREATE PROCEDURE spOrders
	@OrderStatus nvarchar(20)
AS
BEGIN
 SELECT o.CUSTOMERID, c.CUSTOMERNAME, o.ORDERNR, o.ORDERSTATUS
	FROM Orders  o
	INNER JOIN Customer c
	ON o.CUSTOMERID = c.CUSTOMERID
	WHERE OrderStatus = @OrderStatus
END

EXEC spOrders 'Registrated'

-- 5.
CREATE PROCEDURE spAmountOrders 
	@CustomerName nvarchar(20),
	@OrderStatus nvarchar(20),
	@AmountOrders int output
AS
BEGIN
	SELECT @AmountOrders = count(o.ORDERNR)
	FROM Orders o
	INNER JOIN Customer c
	on o.CUSTOMERID = c.CUSTOMERID
	WHERE c.CUSTOMERNAME = @CustomerName AND o.ORDERSTATUS = @OrderStatus
END

DECLARE @AmountOrders int
EXEC spAmountOrders 'Nabben', 'Ready', @AmountOrders output
PRINT @AmountOrders

-- 6. (WRONG answer)

CREATE PROCEDURE spCheckNullValues
	@column nvarchar(50),
	@table nvarchar(20)
AS
BEGIN
	return (SELECT *
	FROM  @table
	WHERE @column IS NOT NULL)
END

-- 7.

CREATE PROCEDURE spSort
	@sortParameter varchar(50)
AS
BEGIN
	IF @sortParameter = 'OrderDate'
	BEGIN
		SELECT * FROM ORDERS ORDER BY ORDERDATE
	END
	ELSE
	BEGIN
		IF @sortParameter = 'OrderStatus'
		BEGIN
			SELECT * FROM ORDERS ORDER BY ORDERSTATUS
		END
		ELSE
		BEGIN
			THROW 50000, 'Error. Voer de juiste waarde in voor de parameter', 1;
		END
	END
END

EXEC spSort 'OrderDate'
EXEC spSort 'OrderStatus'
EXEC spSort 'Haha'