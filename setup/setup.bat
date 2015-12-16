db2 connect to project
db2 set schema TEAM01
db2 -tf dropTables.sql
db2 -tf setupDB.sql
db2 -tf grantRights.sql
db2 -tf importData.sql
