USE AdventureWorks2022

-- Run the whole update as one transaction, so a failure part-way through rolls everything
-- back instead of leaving Destination without the rows it had just deleted.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Get the newest source version already copied to the destination (NULL when it is empty)
DECLARE @CurrentMaxVersion BINARY(8)
SELECT @CurrentMaxVersion = MAX(SourceVersion) FROM [AdventureWorks2022].[Demo].[Destination];

-- Only copy changes below the lowest version that may still belong to an open transaction.
-- A rowversion is assigned when a row is written, not when its transaction commits, so a
-- transaction still in progress can hold a lower version than one that has already
-- committed. Copying the committed row would move @CurrentMaxVersion past the open one, and
-- its row would never be picked up. Rows at or above @UpperBound are left for the next run.
DECLARE @UpperBound BINARY(8) = MIN_ACTIVE_ROWVERSION();



-- Delete any records from destination that have been updated in the source

Print 'deleting records updated in source from destination';

WITH UpdatedRecords AS
(
SELECT rowguid FROM  [AdventureWorks2022].[Demo].[Source]
	WHERE version > @CurrentMaxVersion AND version < @UpperBound
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
	  AND version < @UpperBound


-- Remove records that were deleted from the source. A deleted row leaves no rowversion
-- behind, so the version check above cannot find it: compare the keys of the two tables.
Print 'Deleting records from destination that were deleted from source'

DELETE FROM [AdventureWorks2022].[Demo].[Destination]
	WHERE rowguid NOT IN (SELECT [rowguid] FROM [AdventureWorks2022].[Demo].[Source])

COMMIT TRANSACTION;
