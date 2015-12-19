REM @author alriit00, damait06
REM connect to relevant project and schema
db2 connect to project
db2 set schema TEAM01

REM cleanup
db2 -tf dropTables.sql
db2 -tf dropViews.sql

REM create relevant tables and views
db2 -tf setupDB.sql
db2 -tf createViews.sql

REM grant all rights to public 
db2 -tf grantRights.sql