DROP TABLE DataTemp;
CREATE TABLE DataTemp
	( sbjNo varchar (255)
	, sbjName varchar (255)
	, sbjlevel varchar (255)
	, dept varchar (255)
	, studyPrg varchar (255)
	, elective varchar (255)
	, numCurr varchar (255)
	, numSchd varchar (255)
	, sbjNotes varchar (255)
	, lecNo varchar (255)
	, lecName varchar (255)
	, lec1stn varchar (255)
	, lecdept varchar (255)
	, lecRoom varchar (255)
	, lecNotes varchar (255)
	, prof varchar (255)
	, linkedWith varchar (255)
	, term varchar (255)
	, cntLec varchar (255)
	, cntCurr varchar (255)
	, cntSchd varchar (255)
	, assNotes varchar (255) )
;

IMPORT FROM 'Sample15ws-2.csv' of del INSERT INTO "TEAM01"."DataTemp";
