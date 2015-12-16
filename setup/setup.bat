db2 connect to project
db2 set schema TEAM01
db2 -tf dropall.sql
db2 -tf createTables.sql
db2 -tf alterTables.sql