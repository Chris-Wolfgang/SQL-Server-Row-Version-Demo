USE AdventureWorks2022

-- Get the newest version from the destination table
DECLARE @CurrentMaxVersion BINARY(8)
SELECT @CurrentMaxVersion = MAX(SourceVersion) FROM [AdventureWorks2022].[Demo].[Destination];



-- Delete any records from destination that have been updated in the source

Print 'deleting records updated in source from destination';

WITH UpdatedRecords AS
(
SELECT rowguid FROM  [AdventureWorks2022].[Demo].[Source] WHERE version > @CurrentMaxVersion
)
DELETE FROM Demo.Destination WHERE rowguid IN (SELECT rowguid FROM UpdatedRecords)



-- Add missing records (new and updated records which were just deleted)
Print 'Adding new and updated records to destination' 

INSERT INTO [AdventureWorks2022].[Demo].[Destination]

SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[AdditionalContactInfo]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
	  ,Version
	FROM [AdventureWorks2022].[Demo].[Source]
	WHERE rowguid NOT IN (SELECT [rowguid] FROM Demo.Destination)
