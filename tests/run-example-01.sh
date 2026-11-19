#!/usr/bin/env bash
# Runs example 01's scripts in order against a SQL Server instance and checks that the
# rowversion-based update keeps Demo.Destination in step with Demo.Source.
#
# Usage: tests/run-example-01.sh            (needs SQLCMD and SA_PASSWORD in the environment)
#   SQLCMD       path to sqlcmd (e.g. /opt/mssql-tools18/bin/sqlcmd)
#   SQL_SERVER   server to connect to (default localhost)
#   SA_PASSWORD  sa password of that throwaway instance
#
# Point it only at a throwaway instance: it drops and recreates the AdventureWorks2022
# database there (tests/stub-adventureworks.sql), so it can be run again on the same instance.
set -euo pipefail

: "${SQLCMD:?set SQLCMD to the path of sqlcmd (e.g. /opt/mssql-tools18/bin/sqlcmd)}"
: "${SA_PASSWORD:?set SA_PASSWORD to the sa password of the throwaway SQL Server instance}"

example="example/example-01-using-sql-scripts-to-update-table"
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
# Source rows whose copy in Destination is missing or carries an older SourceVersion.
stale_count="SELECT COUNT(*) FROM AdventureWorks2022.Demo.Source AS s
    LEFT JOIN AdventureWorks2022.Demo.Destination AS d ON d.rowguid = s.rowguid
    WHERE d.rowguid IS NULL OR d.SourceVersion <> CONVERT(binary(8), s.Version)"

# SQL Server takes several seconds to accept logins after its container starts; wait up to
# about 60 seconds rather than failing on the first script.
for attempt in $(seq 1 30); do
    if sql -Q "SELECT 1" > /dev/null 2>&1; then
        break
    fi
    if [[ "$attempt" -eq 30 ]]; then
        echo "FAIL: SQL Server at '$server' did not accept a login within 60 seconds" >&2
        exit 1
    fi
    sleep 2
done

sql -i tests/stub-adventureworks.sql

sql -i "$example/1 - Setup.sql"
expect "destination rows after setup" 0 "$(scalar "$dest_count")"
expect "primary keys on the Demo tables" 2 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.sys.key_constraints k JOIN AdventureWorks2022.sys.schemas s ON s.schema_id = k.schema_id WHERE s.name = 'Demo' AND k.type = 'PK'")"

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
expect "destination rows whose SourceVersion lags the source" 0 "$(scalar "$stale_count")"

# The ReadMe says step 3 can be run again: a second run must add another distinct person
# and update the Crystal rows again (new rowversions), and step 2 must copy both changes.
versions_before="$(scalar "SELECT STRING_AGG(CONVERT(varchar(20), SourceVersion, 1), ',') WITHIN GROUP (ORDER BY rowguid) FROM AdventureWorks2022.Demo.Destination WHERE FirstName = 'Crystal'")"
sql -i "$example/3 - Modify Data.sql"
expect "duplicate BusinessEntityIDs after modifying the source twice" 0 \
    "$(scalar "SELECT COUNT(*) - COUNT(DISTINCT BusinessEntityID) FROM AdventureWorks2022.Demo.Source")"
expect "rows that differ after modifying the source twice" 1 "$(scalar "$diff_count")"
expect "destination rows whose SourceVersion lags the source after modifying it twice" 3 "$(scalar "$stale_count")"
sql -i "$example/2 - Update Table.sql"
expect "destination rows after the third update" "$(scalar "$source_count")" "$(scalar "$dest_count")"
expect "rows that differ after the third update" 0 "$(scalar "$diff_count")"
expect "destination rows whose SourceVersion lags the source after the third update" 0 "$(scalar "$stale_count")"
versions_after="$(scalar "SELECT STRING_AGG(CONVERT(varchar(20), SourceVersion, 1), ',') WITHIN GROUP (ORDER BY rowguid) FROM AdventureWorks2022.Demo.Destination WHERE FirstName = 'Crystal'")"
if [[ "$versions_after" == "$versions_before" ]]; then
    echo "FAIL: the second run of step 3 did not give the Crystal rows new versions ($versions_after)" >&2
    exit 1
fi
echo "ok: Crystal rows have new versions after the second run of step 3"

# The ReadMe also invites deleting source rows: step 2 must remove them from Destination.
sql -Q "SET NOCOUNT ON; DELETE FROM AdventureWorks2022.Demo.Source WHERE LastName = 'Doe'"
expect "Doe rows left in the destination before the delete is copied" 2 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.Demo.Destination WHERE LastName = 'Doe'")"
sql -i "$example/2 - Update Table.sql"
expect "Doe rows left in the destination after the fourth update" 0 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.Demo.Destination WHERE LastName = 'Doe'")"
expect "destination rows after the fourth update" "$(scalar "$source_count")" "$(scalar "$dest_count")"
expect "rows that differ after the fourth update" 0 "$(scalar "$diff_count")"

sql -i "$example/5 - Teardown.sql"
expect "Demo schema after teardown" 0 \
    "$(scalar "SELECT COUNT(*) FROM AdventureWorks2022.sys.schemas WHERE name = 'Demo'")"

echo "example 01: all checks passed"
