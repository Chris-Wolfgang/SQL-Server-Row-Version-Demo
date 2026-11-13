# SQL Server RowVersion Demo

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Chris-Wolfgang/Sql-RowVersionDemo/badge)](https://scorecard.dev/viewer/?uri=github.com/Chris-Wolfgang/Sql-RowVersionDemo)

This repository contains examples of how to use the SQL Server RowVersion data type in productions systems

## Getting Started

There is nothing to build or install: each example is a set of numbered T-SQL scripts that you run
in order against a SQL Server instance.

1. **Prerequisites:** a SQL Server instance you can connect to, a query tool such as SQL Server
   Management Studio (SSMS) or Azure Data Studio, and the `AdventureWorks2022` sample database
   ([install guide](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure)).
   The scripts switch to `AdventureWorks2022` themselves (`USE AdventureWorks2022`) and create and
   drop their own `Demo` schema there, so run them on a development instance, not a production one.
2. **Clone** the repository:

   ```bash
   git clone https://github.com/Chris-Wolfgang/Sql-RowVersionDemo.git
   ```

3. **Open** an example folder (for example `example/example-01-using-sql-scipts-to-update-table/`).
   In SSMS you can open the `.ssmssqlproj` file to get all of the scripts in Solution Explorer.
4. **Run** the scripts in numeric order (`1 - Setup.sql`, `2 - Update Table.sql`, ...), reading the
   example's ReadMe as you go. The last script (`5 - Teardown.sql`) removes everything the example created.

### Testing

There is no automated test suite. An example is verified by running its scripts from setup to
teardown against `AdventureWorks2022` and checking that each script completes without errors and that
the rows inserted or updated by `3 - Modify Data.sql` appear in `Demo.Destination` after
`2 - Update Table.sql` is run again.

## Example 1

Demonstates how you can use `rowversion` in a table to track which records have been added or updated since the last time you checked and once identified you can then update the target table. Mode details can be found [Example 1 ReadMe](https://github.com/Chris-Wolfgang/Sql-RowVersionDemo/blob/main/example/example-01-using-sql-scipts-to-update-table/ReadMe.md)


