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

REM insert from rawdata
db2 -tf 01_insert_lecturer.sql
db2 -tf 02_insert_dep.sql
db2 -tf 03_insert_lecture.sql
db2 -tf 04_insert_prof.sql
db2 -tf 05_insert_extern.sql
db2 -tf 06_insert_event.sql
db2 -tf 07_insert_lecture_events.sql