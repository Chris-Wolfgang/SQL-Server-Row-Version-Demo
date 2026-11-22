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

- `rowversion` is an 8-byte binary value that SQL Server assigns automatically. Each database has a
  single counter for it, shared by every table in that database that has a `rowversion` column.

- Whenever a row in such a table is inserted or updated, it is stamped with the database's next counter
  value. An `UPDATE` stamps the row even when it writes the same values back, so a new version means
  "this row was written", not necessarily "this row's data changed".

- Because the counter is database-wide, the values in one table are increasing but not consecutive and
  do not start at 1: writes to other tables use up values in between.

- Example (one table, with other tables in the database also being written to):
  - The first record is inserted and gets version `0x...07D1`.

  - The next record is inserted and gets a higher version, say `0x...07D4` (other tables used `07D2`
    and `07D3`).

  - The first record is updated and gets a higher version again, say `0x...07D9`.

  - So "which rows have a version above the last one I copied?" finds exactly the rows inserted or
    updated since then, whatever their order in the table. It cannot find deleted rows, which have no
    version left to compare.

- `@@DBTS` returns the last version used in the current database; `MIN_ACTIVE_ROWVERSION()` returns the
  lowest version that may still belong to an open transaction.

## How to Use

1. Open SQL Server Management Studio (SSMS) and connect to your SQL Server instance.

2. Open a new query window and execute the scripts in the following order:

### 1 - Setup.sql

This script sets up the database for the demo. It:
1. Creates a schema called `demo`.

2. Creates a table called `demo.Source` that is a copy of the `Person.Person` table in the `AdventureWorks` database and copies the `Person.Person` data to it.

3. Adds a primary key on `rowguid` to `demo.Source`. `SELECT ... INTO` copies the columns and data but no keys or indexes, and `rowguid` is the column the update script uses to match a source row with its copy in the destination.

4. Adds a column called `Version` of type `rowversion` to the `demo.Source` table to track changes made in the source table.

5. Creates an index on the `Version` column to optimize queries that filter or sort by this column. This isn't needed on small tables, but for larger production tables it does improve read performance.

6. Creates a table called `demo.Destination` that is a copy of the `Person.Person` table in the `AdventureWorks` database and leaves it empty.

7. Adds a primary key on `rowguid` to `demo.Destination`, so each source row can have only one copy there.

8. Adds a column called `SourceVersion` of type `BINARY(8)` to the `demo.Destination` table to store the version of the record from the source table.

9. Creates an index on the `SourceVersion` column to optimize queries that filter or sort by this column. This isn't needed on small tables, but for larger production tables it does improve read performance.

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

2. Finds any records in the `demo.Source` table that have a `rowversion` greater than `@CurrentMaxVersion` and deletes the corresponding records from `demo.Destination`, matching them on the tables' primary key (`rowguid`).

3. Inserts any rows from `demo.Source` that are missing from the `demo.Destination` table.

By getting the current maximum version number in `demo.Destination`, you can identify which records have been added or updated in `demo.Source` since the last time you checked. By deleting these records, you are removing the old versions of the records from `demo.Destination` and allowing the next step to insert the new versions of the records.

Finally, select all the records from `demo.Source` that are missing from `demo.Destination` and insert them into `demo.Destination`. This gives all the new and updated records from `demo.Source`.

### 3 - Modify Data.sql

This script simulates changes in the source table: it inserts a new person (Jane Doe, with the next free `BusinessEntityID`) and updates every person named Crystal (sets the title to `Ms.` and stamps `ModifiedDate`). Each run makes a new change, so you can run the script multiple times to see how the data changes in the source table.  You can also experiment with different types of changes, such as inserting new records, updating existing records, or deleting records.

Once you are done making changes to the source table, rerun the script `2 - Update Table.sql` to see how the changes are reflected in the target table.

### 4 - Run Update Table Again.sql

This is just a placeholder script to remind you to run the `2 - Update Table.sql` script again after making changes to the source table.

### 5 - Teardown.sql

This script cleans up the database by:

1. Dropping the indexes on both `demo.Source` and `demo.Destination` tables.
2. Dropping `demo.Source` and `demo.Destination` tables.
3. Dropping the `demo` schema.

