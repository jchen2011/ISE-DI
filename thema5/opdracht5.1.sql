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