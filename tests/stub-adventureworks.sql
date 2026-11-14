-- Minimal stand-in for AdventureWorks2022, used only by CI (tests/run-example-01.sh).
-- It holds just what example 01 touches: the Person.Person table (same columns, same
-- order, same alias types) with a handful of rows. Readers of the examples restore the
-- real AdventureWorks2022 backup instead, as README.md describes.
CREATE DATABASE AdventureWorks2022;
GO

USE AdventureWorks2022;
GO

CREATE TYPE dbo.NameStyle FROM bit NOT NULL;
CREATE TYPE dbo.Name FROM nvarchar(50) NULL;
GO

CREATE SCHEMA Person;
GO

CREATE TABLE Person.Person
(
    BusinessEntityID      int              NOT NULL PRIMARY KEY,
    PersonType            nchar(2)         NOT NULL,
    NameStyle             dbo.NameStyle    NOT NULL DEFAULT 0,
    Title                 nvarchar(8)      NULL,
    FirstName             dbo.Name         NOT NULL,
    MiddleName            dbo.Name         NULL,
    LastName              dbo.Name         NOT NULL,
    Suffix                nvarchar(10)     NULL,
    EmailPromotion        int              NOT NULL DEFAULT 0,
    AdditionalContactInfo xml              NULL,
    Demographics          xml              NULL,
    rowguid               uniqueidentifier NOT NULL DEFAULT NEWID(),
    ModifiedDate          datetime         NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO Person.Person (BusinessEntityID, PersonType, Title, FirstName, MiddleName, LastName, EmailPromotion)
VALUES
    (1, 'EM', NULL,  'Ken',     'J', 'Sanchez',  0),
    (2, 'EM', NULL,  'Terri',   'Lee', 'Duffy',  1),
    (3, 'IN', 'Mr.', 'Roberto', NULL, 'Tamburello', 0),
    (4, 'IN', NULL,  'Crystal', NULL, 'Wu',       2),
    (5, 'IN', NULL,  'Crystal', 'S', 'Ross',     0);
GO
