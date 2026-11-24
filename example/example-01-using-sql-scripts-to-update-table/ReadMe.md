# Example 1

This project demonstrates how to identify new and updated records in a source table and upsert them into a target table using SQL Server, T-SQL scripts, and SQL Server's `rowversion` column type.

## Prerequisites

- Basic understanding of SQL and T-SQL.
- SQL Server installed on your machine or access to a SQL Server instance.
- AdventureWorks database installed in your SQL Server instance. If you don't, you can:
  - Download the AdventureWorks database from [Microsoft's website](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16).
  - Use another sample database of your choice. Just make sure to change the table names in the scripts below.

## Disclaimer

This is a simplified example for educational purposes only. In a production 
environment, you would need to consider additional factors such as error 
handling, logging, performance optimization, and data validation.

While these scripts are designed to be used on Microsoft SQL Server, you may be able to use them on other SQL databases with minor modifications. Please refer to the documentation of your database system for compatibility details.

## How does the `rowversion` column work?

- `rowversion` is a binary data type that gets incremented whenever there is a change to the table.

- When a record is inserted, it gets the next version number. When a row is updated, it gets the next version number.

- Example:
  - When the first record is inserted, it gets version 1.

  - When the next record is inserted, it gets version 2.

  - When the first record is updated, it gets version 3.

  - When a new record is inserted, it gets version 4.

  - When the second record is updated, it gets version 5.
  - And so on.


## How to Use

1. Open SQL Server Management Studio (SSMS) and connect to your SQL Server instance.

2. Open a new query window and execute the scripts in the following order:

### 1 - Setup.sql

This script sets up the database for the demo. It:
1. Creates a schema called `demo`.

2. Creates a table called `demo.Source` that is a copy of the `Person.Person` table in the `AdventureWorks` database and copies the `Person.Person` data to it.

3. Adds a column called `Version` of type `rowversion` to the `demo.Source` table to track changes made in the source table.

4. Creates an index on the `Version` column to optimize queries that filter or sort by this column. This isn't needed on small tables, but for larger production tables it does improve read performance.

5. Creates a table called `demo.Destination` that is a copy of the `Person.Person` table in the `AdventureWorks` database and leaves it empty.

6. Adds a column called `SourceVersion` of type `BINARY(8)` to the `demo.Destination` table to store the version of the record from the source table.

7. Creates an index on the `SourceVersion` column to optimize queries that filter or sort by this column. This isn't needed on small tables, but for larger production tables it does improve read performance.

By adding a `rowversion` column to the source table, you can easily track 
which records have been added or updated since the last time you checked. 
This allows you to efficiently identify new and updated records for upserting 
into the target table.

The `SourceVersion` column in the target table stores the 
version of the record from the source table. This allows you to compare 
the version of the record in the source table with the version stored 
in the target table to determine if a record has been updated.

You can't use the `rowversion` column directly in the target table because
it is automatically updated by SQL Server whenever a record is modified. 
If you used it directly, it would always be different from the source table, 
even if the record hasn't changed. By storing the source version in a 
separate column, you can accurately track changes and perform upserts 
on the actual data changes.

### 2 - Update Table.sql

This script synchronizes the destination table with new or updated records from the source table by performing the following actions:

1. Gets the current maximum version number from the `demo.Destination` table and stores it in a variable called `@CurrentMaxVersion`.

2. Finds any records in the `demo.Source` table that have a `rowversion` greater than `@CurrentMaxVersion` and deletes the corresponding records from `demo.Destination` using the table's primary key (`rowguid`).

3. Inserts any rows from `demo.Source` that are missing from the `demo.Destination` table.

By getting the current maximum version number in `demo.Destination`, you can identify which records have been added or updated in `demo.Source` since the last time you checked. By deleting these records, you are removing the old versions of the records from `demo.Destination` and allowing the next step to insert the new versions of the records.

Finally, select all the records from `demo.Source` that are missing from `demo.Destination` and insert them into `demo.Destination`. This gives all the new and updated records from `demo.Source`.

### 3 - Modify Data.sql

This script simulates changes in the source table. You can run the script multiple times to see how the data changes in the source table.  You can also experiment with different types of changes, such as inserting new records, updating existing records, or deleting records.

Once you are done making changes to the source table, rerun the script `2 - Update Table.sql` to see how the changes are reflected in the target table.

### 4 - Run Update Table Again.sql

This is just a placeholder script to remind you to run the `2 - Update Table.sql` script again after making changes to the source table.

### 5 - Teardown.sql

This script cleans up the database by:

1. Dropping the indexes on both `demo.Source` and `demo.Destination` tables.
2. Dropping `demo.Source` and `demo.Destination` tables.
3. Dropping the `demo` schema.

