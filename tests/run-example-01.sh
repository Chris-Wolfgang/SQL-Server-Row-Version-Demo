#!/usr/bin/env bash
# Runs example 01's scripts in order against a SQL Server instance and checks that the
# rowversion-based update keeps Demo.Destination in step with Demo.Source.
#
# Usage: tests/run-example-01.sh            (needs SQLCMD and SA_PASSWORD in the environment)
#   SQLCMD       path to sqlcmd (e.g. /opt/mssql-tools18/bin/sqlcmd)
#   SQL_SERVER   server to connect to (default localhost)
#   SA_PASSWORD  sa password of that throwaway instance
set -euo pipefail

example="example/example-01-using-sql-scipts-to-update-table"
server="${SQL_SERVER:-localhost}"

sql() { "$SQLCMD" -C -b -S "$server" -U sa -P "$SA_PASSWORD" "$@"; }
scalar() { sql -h -1 -W -Q "SET NOCOUNT ON; $1" | tr -d '\r' | head -n 1; }

expect() {
    local what="$1" expected="$2" actual="$3"
    if [[ "$actual" != "$expected" ]]; then
        echo "FAIL: $what: expected '$expected', got '$actual'" >&2
        exit 1
    fi
    echo "ok: $what = $actual"
}

source_count="SELECT COUNT(*) FROM AdventureWorks2022.Demo.Source"
dest_count="SELECT COUNT(*) FROM AdventureWorks2022.Demo.Destination"
# Rows whose content differs between the two tables, counted from both sides, ignoring the version
# columns. After step 3 that is 5: Source has the new row plus the two retitled Crystal rows, and
# Destination still has the two old Crystal rows.
diff_count="SELECT COUNT(*) FROM (
    (SELECT BusinessEntityID, Title, FirstName, LastName, rowguid FROM AdventureWorks2022.Demo.Source
     EXCEPT
     SELECT BusinessEntityID, Title, FirstName, LastName, rowguid FROM AdventureWorks2022.Demo.Destination)
    UNION ALL
    (SELECT BusinessEntityID, Title, FirstName, LastName, rowguid FROM AdventureWorks2022.Demo.Destination
     EXCEPT
     SELECT BusinessEntityID, Title, FirstName, LastName, rowguid FROM AdventureWorks2022.Demo.Source)
) AS d"

sql -i tests/stub-adventureworks.sql

sql -i "$example/1 - Setup.sql"
expect "destination rows after setup" 0 "$(scalar "$dest_count")"

sql -i "$example/2 - Update Table.sql"
expect "destination rows after the first update" "$(scalar "$source_count")" "$(scalar "$dest_count")"
expect "rows that differ after the first update" 0 "$(scalar "$diff_count")"

sql -i "$example/3 - Modify Data.sql"
expect "rows that differ after modifying the source" 5 "$(scalar "$diff_count")"

# Step 4 tells the reader to run step 2 again.
sql -i "$example/2 - Update Table.sql"
expect "destination rows after the second update" "$(scalar "$source_count")" "$(scalar "$dest_count")"
expect "rows that differ after the second update" 0 "$(scalar "$diff_count")"
expect "Crystal rows still without a title" 0 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.Demo.Destination WHERE FirstName = 'Crystal' AND Title IS NULL")"

sql -i "$example/5 - Teardown.sql"
expect "Demo schema after teardown" 0 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.sys.schemas WHERE name = 'Demo'")"

echo "example 01: all checks passed"
