USE AdventureWorks2022;

-- Each run makes a new change, so you can run this script as many times as you like and
-- then run "2 - Update Table.sql" to copy the changes to Demo.Destination.

-- Insert a new person. The id is the next one free in Demo.Source, so every run adds a
-- distinct person rather than a duplicate of the last one.
INSERT INTO [AdventureWorks2022].[Demo].[Source]
(
       [BusinessEntityID]
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
      ,[ModifiedDate]
      ,[rowguid]
)
SELECT
       MAX([BusinessEntityID]) + 1
      ,'EM'
      ,0
      ,'Ms.'
      ,'Jane'
      ,'T'
      ,'Doe'
      ,NULL
      ,2
      ,NULL
      ,NULL
      ,GETDATE()
      ,NEWID()
FROM [AdventureWorks2022].[Demo].[Source];

-- Update the people named Crystal: give them a title and stamp the modified date. The
-- date changes on every run, so every run is a real update that gives these rows a new
-- rowversion.
UPDATE [AdventureWorks2022].[Demo].[Source]
    SET Title = 'Ms.'
       ,ModifiedDate = GETDATE()
    WHERE FirstName = 'Crystal';
