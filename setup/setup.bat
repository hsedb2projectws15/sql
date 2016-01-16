REM @author alriit00, damait06
REM connect to relevant project and schema
db2 connect to project
db2 set schema TEAM01

REM cleanup
db2 -tf dropAll.sql

REM create relevant tables
db2 -tf createTables.sql

REM insert from rawdata
db2 -tf insertAllData.sql

REM create relevant views
db2 -tf createViews.sql

REM grant all rights to public 
db2 -tf grantRights.sql
