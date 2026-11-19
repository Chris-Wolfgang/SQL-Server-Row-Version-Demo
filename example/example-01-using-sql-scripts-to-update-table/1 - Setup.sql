USE AdventureWorks2022;
GO

CREATE SCHEMA Demo

GO

SELECT * INTO Demo.Source FROM Person.Person;

ALTER TABLE Demo.Source ADD Version RowVersion NOT NULL;

CREATE INDEX IX_Person_Source_RowVersion ON Demo.Source (Version);


SELECT * INTO Demo.Destination FROM Person.Person WHERE 1 <> 1;

ALTER TABLE Demo.Destination ADD SourceVersion BINARY(8) NOT NULL

CREATE INDEX IX_PersonDestination_RowVersion ON Demo.Destination (SourceVersion);


