-- 3.
DROP PROCEDURE IF EXISTS spOrderStatusReady
	GO
CREATE PROCEDURE spOrderStatusReady
	AS
BEGIN
    SET NOCOUNT ON
BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM Orders WHERE Orderstatus = 'ready')
BEGIN
            ;THROW 50001, 'There are no orders with orderstatus (ready)', 1
END

SELECT o.CustomerId, CustomerName, OrderNr, Orderstatus
FROM Orders o
		 INNER JOIN Customer c
					ON o.customerId = c.customerId
WHERE OrderStatus = 'ready'
END TRY
BEGIN CATCH
        ;THROW
END CATCH
END
GO

EXEC spOrderStatusReady

-- 4.
DROP PROCEDURE IF EXISTS spOrderStatus
	GO
CREATE PROCEDURE spOrderStatus
	@OrderStatus varchar(12)
AS
BEGIN
    SET NOCOUNT ON -- optimalisatie
BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM Orders WHERE Orderstatus = @OrderStatus)
BEGIN
            ;THROW 50001, 'There are no orders with the given orderstatus ', 1
END

SELECT o.CustomerId, CustomerName, OrderNr, Orderstatus
FROM Orders o
		 INNER JOIN Customer c
					ON o.customerId = c.customerId
WHERE OrderStatus = @OrderStatus
END TRY
BEGIN CATCH
        ;THROW
END CATCH
END
GO
    
EXEC spOrderStatus @OrderStatus = 'ready'

-- 5.
DROP PROCEDURE IF EXISTS spAmountOfOrders
	GO
CREATE PROCEDURE spAmountOfOrders
	@CustomerName varchar(40),
	@OrderStatus varchar(12),
	@AmountOfOrders int OUTPUT
AS
BEGIN
    SET NOCOUNT ON -- optimalisatie
BEGIN TRY

IF NOT EXISTS (SELECT 1
						FROM ORDERS o
						INNER JOIN Customer C
						ON o.customerId = c.customerId
						WHERE ORDERSTATUS = @OrderStatus
						AND CustomerName = @CustomerName)
BEGIN
			;THROW 50001, 'There are no order with this customer name and order status', 1
END

SELECT @AmountOfOrders = COUNT(o.ordernr)
FROM ORDERS o
		 INNER JOIN Customer C
					ON o.customerId = c.customerId
WHERE ORDERSTATUS = @OrderStatus
  AND CustomerName = @CustomerName
END TRY
BEGIN CATCH
        ;THROW
END CATCH
END
GO

DECLARE @AmountOfOrders int
EXEC spAmountOfOrders @CustomerName = 'Nabben', @OrderStatus = 'ready', @AmountOfOrders = @AmountOfOrders OUTPUT
PRINT @AmountOfOrders

-- 6.
--GEEN IDEE

-- 7.
DROP PROCEDURE IF EXISTS spSortParameter
	GO
CREATE PROCEDURE spSortParameter
	@sortParameter varchar(20)
AS
BEGIN
    SET NOCOUNT ON -- optimalisatie
BEGIN TRY

IF (@sortParameter = 'OrderDate')
BEGIN
SELECT *
FROM Orders
ORDER BY OrderDate
END
ELSE IF (@sortParameter = 'OrderStatus')
BEGIN
SELECT *
FROM Orders
ORDER BY OrderStatus
END
ELSE
BEGIN
				;THROW 50001, 'Given parameter does not exists', 1
END
END TRY
BEGIN CATCH
        ;THROW
END CATCH
END
GO

EXEC spSortParameter @sortParameter = 'OrderStatus'