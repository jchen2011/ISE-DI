-- 1.
CREATE table Product (
	ProductCode int NOT NULL,
	ProductName varchar(40) NOT NULL,
	ProductPrice money NOT NULL,
	ProductsInStock smallint NOT NULL
	PRIMARY KEY (ProductCode)
)

ALTER TABLE Product
ADD CONSTRAINT CHK_ProductName_ProductPrice CHECK 
(ProductName != 'TELEVISION' OR ProductPrice > 200)

-- 2.
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Person' AND TABLE_TYPE = 'BASE TABLE')
DROP TABLE Person
GO
CREATE TABLE Person
(ID		INT IDENTITY 	NOT NULL,
 Name		VARCHAR(30) 	NOT NULL,
 Prefix		VARCHAR(10) 	NULL,
 NamePartner	VARCHAR(30) 	NULL,
 PrefixPartner	VARCHAR(10) 	NULL,
 Presentation	INT 		NOT NULL,-- 1 = Name, 2 = Name + Partner, 3 = Partner  + Name, 4 = Partner
Sex		CHAR(1) NOT NULL,	-- M = Male, F = Female
 Initials		VARCHAR(10) NOT NULL,
 CONSTRAINT PK_Person PRIMARY KEY (ID)
)

GO

ALTER TABLE Person
ADD CONSTRAINT CHK_Presentation_NamePartner CHECK
(Presentation = 1 OR NamePartner IS NOT NULL)


