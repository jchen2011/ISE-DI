-- 3.
DROP TRIGGER IF EXISTS trgCustomer_AfterDelete
GO
CREATE TRIGGER trgCustomer_AfterDelete
ON dbo.CUSTOMER
AFTER DELETE AS
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON
    BEGIN TRY
        IF EXISTS (SELECT o.CustomerId FROM Orders o
		INNER JOIN deleted d
		ON o.customerId = d.customerId)
        BEGIN
            ;THROW 50000, 'Customers kunnen niet verwijderd worden als ze nog een order open hebben staan', 1
        END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

DELETE FROM Customer WHERE CustomerId = 1

-- 4 
DROP TRIGGER IF EXISTS trgOrders_AfterInsert
GO
CREATE TRIGGER trgOrders_AfterInsert --IUD
ON dbo.ORDERS
AFTER INSERT AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
        IF (SELECT COUNT(*) FROM Customer C
		INNER JOIN inserted i
		ON c.CUSTOMERID = i.CUSTOMERID) != (SELECT COUNT(*) FROM INSERTED) 
        BEGIN
            ;THROW 50001, 'Voor deze order bestaat geen customer', 1
			ROLLBACK TRANSACTION
        END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

SELECT * FROM Orders
SELECT * FROM Customer

-- GOED
BEGIN TRANSACTION
ALTER TABLE ORDERS
DROP CONSTRAINT FK_ORDERS_RELATIONS_CUSTOMER

SET IDENTITY_INSERT ORDERS ON
INSERT INTO Orders (ORDERNR, CUSTOMERID, ORDERDATE, ORDERSTATUS)
VALUES (3, 1, '2023-02-28 19:00:07.937', 'Ready'), (4, 1, '2023-02-28 19:00:07.937', 'Ready')
SET IDENTITY_INSERT ORDERS OFF
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
ALTER TABLE ORDERS
DROP CONSTRAINT FK_ORDERS_RELATIONS_CUSTOMER

SET IDENTITY_INSERT ORDERS ON
INSERT INTO Orders (ORDERNR, CUSTOMERID, ORDERDATE, ORDERSTATUS)
VALUES (3, 1, '2023-02-28 19:00:07.937', 'Ready'), (4, 2, '2023-02-28 19:00:07.937', 'Ready')
SET IDENTITY_INSERT ORDERS OFF
ROLLBACK TRANSACTION


-- 5.
/*
			Registrated Shipping    Ready
Registrated ja          ja          nee
Shipping    nee         ja          ja
Ready       nee         nee         ja
*/
CREATE TABLE FORBIDDEN_TRANSITIE
(
  ID int PRIMARY KEY,
  FROMSTATE VARCHAR(15) NOT NULL,
  TOSTATE VARCHAR(15) NOT NULL) 

INSERT INTO FORBIDDEN_TRANSITIE VALUES(1, 'Registrated', 'Ready')
INSERT INTO FORBIDDEN_TRANSITIE VALUES(2, 'Shipping', 'Registrated')
INSERT INTO FORBIDDEN_TRANSITIE VALUES(3, 'Ready', 'Registrated')
INSERT INTO FORBIDDEN_TRANSITIE VALUES(4, 'Ready', 'Shipping')


DROP TRIGGER IF EXISTS trgOrders_AfterUpdate
GO
CREATE TRIGGER trgOrders_AfterUpdate --IUD
ON dbo.ORDERS
AFTER UPDATE AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
		DECLARE @OrderNr int
		DECLARE @OldStatus varchar(12), @NewStatus varchar(12)

		SELECT *
		INTO #TempTable
		FROM inserted

		WHILE (EXISTS(SELECT ORDERNR FROM #TempTable))
		BEGIN
			SELECT TOP 1 @OrderNr = ORDERNR, @NewStatus = ORDERSTATUS
			FROM #TempTable

			SELECT @OldStatus = ORDERSTATUS
			FROM deleted
			WHERE ORDERNR = @OrderNr

			IF EXISTS (SELECT * FROM FORBIDDEN_TRANSITIE WHERE FROMSTATE = @OldStatus AND TOSTATE = @NewStatus)
				BEGIN
					;THROW 50001, 'Dit statusovergang is niet toegestaan', 1
				END
			
			DELETE FROM #TempTable WHERE OrderNr = @OrderNr
		END
    END TRY 

    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

SELECT * FROM Orders

-- FOUT
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Registered'
	WHERE ORDERSTATUS = 'Ready'
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Registered'
	WHERE OrderNr = 2
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Shipping'
	WHERE OrderNr = 2
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Ready'
	WHERE ORDERSTATUS = 'Registrated'
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Ready'
	WHERE ORDERNr = 1
ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Shipping'
	WHERE ORDERSTATUS = 'Registrated'
ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Shipping'
	WHERE ORDERNR = 1
ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Ready'
	WHERE ORDERNR = 2
ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	UPDATE ORDERS
	SET ORDERSTATUS = 'Ready'
	WHERE ORDERSTATUS = 'Ready'
ROLLBACK TRANSACTION


-- 6.
alter table ORDER_DETAIL
   add constraint FK_ORDERDET_RELATIONS_ORDERS foreign key (ORDERNR)
      references ORDERS (ORDERNR)
go
alter table ORDER_DETAIL
   add constraint FK_ORDERDET_RELATIONS_PRODUCT foreign key (PRODUCTCODE)
      references PRODUCT (PRODUCTCODE)
go
alter table ORDERS
   add constraint FK_ORDERS_RELATIONS_CUSTOMER foreign key (CUSTOMERID)
      references CUSTOMER (CUSTOMERID)
go

SELECT * FROM ORDER_DETAIL
SELECT * FROM PRODUCT

DROP TRIGGER IF EXISTS trgOrder_Detail_AfterInsert
GO
CREATE TRIGGER trgOrder_Detail_AfterInsert --IUD
ON dbo.ORDER_DETAIL
AFTER INSERT AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
        IF EXISTS (SELECT COUNT(*) FROM inserted HAVING COUNT(*) > 1)
			BEGIN
				;THROW 50001, 'Er kan maar een record ingevoerd worden', 1
			END

		DECLARE @DetailQuantity int
		SELECT @DetailQuantity = DETAILQUANTITY FROM inserted

		DECLARE @ProductCode int
		SELECT @ProductCode = PRODUCTCODE FROM inserted

		UPDATE PRODUCT
		SET PRODUCTSINSTOCK = PRODUCTSINSTOCK - @DetailQuantity
		WHERE PRODUCTCODE = @ProductCode
    END TRY 

    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

-- FOUT
BEGIN TRANSACTION
	DELETE FROM ORDER_DETAIL

	INSERT INTO ORDER_DETAIL (ORDERNR, PRODUCTCODE, DETAILQUANTITY)
	VALUES (1, 12, 4),
	(2, 12, 5)

ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	DELETE FROM ORDER_DETAIL

	INSERT INTO ORDER_DETAIL (ORDERNR, PRODUCTCODE, DETAILQUANTITY)
	VALUES (1, 12, 4)

	SELECT * FROM ORDER_DETAIL
	SELECT * FROM PRODUCT
ROLLBACK TRANSACTION

-- 7 (geen idee).

-- 8.
DROP TRIGGER IF EXISTS trgCustomer_AfterInsertUpdateDelete
GO
CREATE TRIGGER trgCustomer_AfterInsertUpdateDelete --IUD
ON dbo.CUSTOMER
AFTER INSERT, UPDATE, DELETE AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY

        IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        BEGIN
            PRINT 'UPDATE TYPE'
			RETURN
        END

		IF EXISTS (SELECT * FROM inserted)
        BEGIN
            PRINT 'INSERT TYPE'
			RETURN
        END

		IF EXISTS (SELECT * FROM deleted)
        BEGIN
            PRINT 'DELETE TYPE'
			RETURN
        END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

-- INSERT
BEGIN TRANSACTION
	INSERT INTO Customer (CUSTOMERID, CUSTOMERNAME) VALUES (2, 'Jona')
ROLLBACK TRANSACTION

-- UPDATE
BEGIN TRANSACTION
	UPDATE Customer
	SET CUSTOMERID = 1
	WHERE CUSTOMERID = 1
ROLLBACK TRANSACTION


-- DELETE

BEGIN TRANSACTION
	INSERT INTO Customer (CUSTOMERID, CUSTOMERNAME) VALUES (2, 'Jona')

	DELETE FROM Customer
	WHERE CustomerId = 2
ROLLBACK TRANSACTION

-- GEEN RIJ
BEGIN TRANSACTION
	UPDATE Customer
	SET CUSTOMERID = 3
	WHERE CUSTOMERID = 9
ROLLBACK TRANSACTION

-- 9.
DROP TRIGGER IF EXISTS trgtblBloodbankDonations_AfterInsertUpdate
GO
CREATE TRIGGER trgtblBloodbankDonations_AfterInsertUpdate --IUD
ON dbo.tblBloodbankDonations
AFTER INSERT, UPDATE AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
		DECLARE @Id int
		DECLARE @OldDate datetime, @NewDate datetime

		SELECT *
		INTO #TempTable
		FROM inserted

		WHILE(EXISTS(SELECT prs_identification FROM #TempTable))
		BEGIN
			SELECT TOP 1 @Id = prs_identification, @NewDate = don_DonationDate
			FROM #TempTable

			SELECT @OldDate = prs_FirstTimeDonorDate
			FROM tblBloodBankPersons
			WHERE prs_identification = @Id

			IF NOT EXISTS (SELECT * FROM tblBloodbankPersons
	WHERE prs_identification = @Id
AND @OldDate < @NewDate)
				BEGIN
					;THROW 50001, 'Datum ligt voor de first time donor date', 1
				END
				DELETE FROM #TempTable WHERE prs_identification = @Id
		END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

SELECT * FROM tblBloodBankPersons


-- GOED
BEGIN TRANSACTION
	INSERT INTO tblBloodbankDonations (prs_identification, don_DonationDate)
	VALUES(1, '2011-02-20 00:00:00.000')
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	INSERT INTO tblBloodbankDonations (prs_identification, don_DonationDate)
	VALUES(1, '2011-02-18 00:00:00.000')
ROLLBACK TRANSACTION

-- GOED
BEGIN TRANSACTION
	INSERT INTO tblBloodbankDonations (prs_identification, don_DonationDate)
	VALUES(1, '2011-02-20 00:00:00.000'),
	(1, '2011-02-22 00:00:00.000')
ROLLBACK TRANSACTION

-- FOUT
BEGIN TRANSACTION
	INSERT INTO tblBloodbankDonations (prs_identification, don_DonationDate)
	VALUES(1, '2011-02-20 00:00:00.000'),
	(1, '2011-02-15 00:00:00.000')
ROLLBACK TRANSACTION

-- 10.
DROP TRIGGER IF EXISTS trgCustomer1_AfterInsertUpdate
GO
CREATE TRIGGER trgCustomer1_AfterInsertUpdate --IUD
ON dbo.CUSTOMER
AFTER INSERT, UPDATE AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
        IF UPDATE(CUSTOMERNAME)
			BEGIN
				PRINT 'You have modified the CustomerName column'
			END
		ELSE 
			BEGIN
				PRINT 'You have NOT modified the CustomerName column'
			END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

-- MODIFIED
BEGIN TRANSACTION
	INSERT INTO CUSTOMER (CUSTOMERID, CUSTOMERNAME) VALUES (2, 'Hoeneveld')
ROLLBACK TRANSACTION

-- MODIFIED
BEGIN TRANSACTION
	UPDATE CUSTOMER SET CUSTOMERNAME = 'Nabben' WHERE CUSTOMERID = 1
ROLLBACK TRANSACTION

-- 11.

-- Het heeft sowieso geen zin, omdat er al een error komt als je een null waarde invult. Dus de trigger heeft helemaal geen zin.
DROP TRIGGER IF EXISTS trgProduct_AfterInsert
GO
CREATE TRIGGER trgProduct_AfterInsert --IUD
ON dbo.PRODUCT
AFTER INSERT AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
		DECLARE @ProductCode int
		DECLARE @ProductName varchar(40)
		DECLARE @ProductPrice money
		DECLARE @ProductsInStock smallint

		SELECT *
		INTO #TempTable
		FROM inserted

		WHILE(EXISTS(SELECT ProductCode FROM #TempTable))
		BEGIN
			SELECT TOP 1 @ProductCode = ProductCode, @ProductName = PRODUCTNAME, @ProductPrice = PRODUCTPRICE, @ProductsInStock = PRODUCTSINSTOCK
			FROM #TempTable

			IF	(@ProductCode IS NULL) OR
				(@ProductName IS NULL) OR
				(@ProductPrice IS NULL) OR
				(@ProductsInStock IS NULL)
				BEGIN
					;THROW 50001, 'Er is een kolom met waarde NULL', 1
				END
			DELETE FROM #TempTable WHERE PRODUCTCODE = @ProductCode
		END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO

-- 12.
DROP TRIGGER IF EXISTS trgFactuurRegel_AfterInsert
GO
CREATE TRIGGER trgFactuurRegel_AfterInsert --IUD
ON dbo.FACTUURREGEL
AFTER INSERT AS --<ACTIONs> INSERT, UPDATE, DELETE
BEGIN
    IF @@ROWCOUNT = 0
        RETURN 
    SET NOCOUNT ON -- optimalisatie
    BEGIN TRY
		DECLARE @ProductId int, @productPrijs money
		DECLARE @factuurNr int, @factRegelNr int, @factRegelHoeveelheid int, @factRegelKorting int, @factregelPrijs money

		SELECT *
		INTO #TempTable
		FROM inserted

		WHILE (EXISTS(SELECT factuurNr FROM #TempTable))
		BEGIN
			SELECT TOP 1 @factuurNr = FACTUURNR, @factRegelNr = FACTREGELNR, @ProductId = PRODUCTID, @factRegelHoeveelheid = FACTREGELHOEVEELHEID, @factRegelKorting = FACTREGELKORTING
			FROM #TempTable

			SELECT @productPrijs = PRODUCTPRIJS
			FROM Product
			WHERE productId = @ProductId
			
			DECLARE @percentage numeric(4, 2)
			SET @percentage = (100.0 - @factRegelKorting) / 100.0
			SET @factregelPrijs = ((@factRegelHoeveelheid * @productPrijs) * (@percentage))


			UPDATE FactuurRegel
			SET factRegelPrijs = @factRegelPrijs
			WHERE factuurNr = @factuurNr

			DELETE FROM #TempTable WHERE FactuurNr = @factuurNr
		END
    END TRY 
    BEGIN CATCH
        ;THROW  
    END CATCH
END
GO


-- TESTCASE 1
BEGIN TRANSACTION
	INSERT INTO Factuur (factuurNr, factuurDatum) 
	VALUES (1, '2023-02-28 19:00:07.937')

	INSERT INTO Product (productId, productPrijs, productbeschrijving) 
	VALUES (1, 10, 'T-shirt')

	INSERT INTO FactuurRegel (factuurNr, factRegelNr, productId, factRegelHoeveelheid, factRegelKorting)
	VALUES (1, 2, 1, 10, 70)

	SELECT * FROM FactuurRegel
ROLLBACK TRANSACTION

CREATE PROCEDURE spReadyOrders
AS
BEGIN
	SELECT o.CUSTOMERID, c.CUSTOMERNAME, o.ORDERNR, o.ORDERSTATUS
	FROM Orders  o
	INNER JOIN Customer c
	ON o.CUSTOMERID = c.CUSTOMERID
	WHERE OrderStatus = 'Ready'
END

SELECT * FROM Orders;
	

