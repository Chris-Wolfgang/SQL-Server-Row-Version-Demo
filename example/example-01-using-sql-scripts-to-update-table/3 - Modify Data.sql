--SELECT TOP 10 * FROM Person.Person ORDER BY BusinessEntityID DESC



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
	  ,RowGuid
)
VALUES
(
	30001
	,'EM'
	, 0
	, 'Ms'
	, 'Jane'
	, 'T'
	, 'Doe'
	, ''
	, 2
	, null
	, null
	, Getdate()
	, NEWID()
)

UPDATE [AdventureWorks2022].[Demo].[Source]
	SET Title = 'Ms.' 
	WHERE Title IS NULL AND FirstName = 'Crystal'