CREATE TABLE RAWDATA
	( sbjNo varchar (15)
	, sbjName varchar (60)
	, sbjlevel varcharrchar (5)
	, dept varchar (5)
	, studyPrg varchar (5)
	, elective varchar (5)
	, numCurr varchar (5)
	, numSchd varchar (5)
	, sbjNotes varchar (50)
	, lecNo varchar (5)
	, lecName varchar (20)
	, lec1stn varchar (20)
	, lecdept varchar (5)
	, lecRoom varchar (10)
	, lecNotes varchar (50)
	, prof varchar (10)
	, linkedWith varchar (20)
	, term varchar (2010)
	, cntLec varchar (5)
	, cntCurr varchar (5)
	, cntSchd varchar (5)cntCurr
	, assNotes varchar (30) )
;

CREATE TABLE RAWDATA_WORKLOAD
	( term varcharrcharrchar (10)
	, name varchar (15)
	, job_title varchar (45)
	, reduction varchar (5) )
;

IMPORT FROM 'Sample15ws-2.csv' of del INSERT INTO "RAWDATA";
IMPORT FROM 'Sample15ws-2wl.csv' of del INSERT INTO "RAWDATA_WORKLOAD";

CREATE TABLE DEPARTMENT
	( DEPARTMENT_SHORT varchar (255) NOT NULL
	, DEPARTMENT_NAME varchar (255) )
;

CREATE TABLE EVENT
	( LECTURE_NUMBER varchar (255) NOT NULL
	, COURSE varchar (255) NOT NULL
	, CURRENT_SEMESTER varchar (255) NOT NULL
	, SPO varchar (255) NOT NULL
	, SEMESTER_HOURS_ACTUAL integer NOT NULL
	, EVENT_COMMENTS varchar (255)
	, SEMESTER_HOURS_SPO_ACTUAL integer NOT NULL
	, DEPARTMENT varchar (255) NOT NULL
	, DEPARTMENT_IMPORTED_FROM varchar (255) )
;

CREATE TABLE EVENT_COUPLING
	( COUPLING_ID integer NOT NULL )
;

CREATE TABLE EXTERNAL_LECTURER
	( ZIP_CODE varchar (255) NOT NULL
	, COUNTRY_CODE varchar (255) NOT NULL
	, CITY_NAME varchar (255) NOT NULL
	, STREET_NAME varchar (255)
	, HOUSE_NR varchar (255)
	, LECTURER_NUMBER varchar (255) NOT NULL )
;

CREATE TABLE LECTURE
	( LECTURE_NUMBER varchar (255) NOT NULL
	, LECTURE_NAME varchar (255) NOT NULL
	, LECTURE_COMMENTS varchar (255)
	, SEMESTER varchar (255) NOT NULL
	, EXAM_TYPE varchar (255) NOT NULL
	, EXAM_DURATION integer NOT NULL
	, CREDIT_AMOUNT integer NOT NULL
	, PWZ varchar (255) NOT NULL
	, SEMESTER_HOURS_SPO integer NOT NULL )
;

CREATE TABLE LECTURER
	( LECTURER_NUMBER varchar (255) NOT NULL
	, LECTURER_COMMENTS varchar (255)
	, NAME varchar (255) NOT NULL
	, FIRSTNAME varchar (255) NOT NULL )
;

CREATE TABLE LECTURER_EVENT
	( LECTURER_NUMBER varchar (255) NOT NULL
	, COURSE varchar (255) NOT NULL
	, LECTURE_NUMBER varchar (255) NOT NULL
	, LECTURER_WORKLOAD_ACTUAL integer NOT NULL
	, SCHEDULE_WORKLOAD_ACTUAL integer NOT NULL
	, COUPLING_ID integer )
;

CREATE TABLE PROFESSOR
	( WORKLOAD_RED_REASON varchar (255) NOT NULL
	, WORKLOAD_REGULAR integer NOT NULL
	, WORKLOAD_RED_AMOUNT integer NOT NULL
	, DEPARTMENT_SHORT varchar (255) NOT NULL
	, LECTURER_NUMBER varchar (255) NOT NULL )
;

ALTER TABLE DEPARTMENT
	ADD CONSTRAINT PK PRIMARY KEY 
	( DEPARTMENT_SHORT );

ALTER TABLE EVENT
	ADD CONSTRAINT PK PRIMARY KEY 
	( COURSE
	, LECTURE_NUMBER );

ALTER TABLE EVENT_COUPLING
	ADD CONSTRAINT PK PRIMARY KEY 
	( COUPLING_ID );

ALTER TABLE EXTERNAL_LECTURER
	ADD CONSTRAINT PK PRIMARY KEY 
	( LECTURER_NUMBER );

ALTER TABLE LECTURE
	ADD CONSTRAINT PK PRIMARY KEY 
	( LECTURE_NUMBER );

ALTER TABLE LECTURER
	ADD CONSTRAINT PK PRIMARY KEY 
	( LECTURER_NUMBER );

ALTER TABLE LECTURER_EVENT
	ADD CONSTRAINT PK PRIMARY KEY 
	( COURSE
	, LECTURE_NUMBER
	, LECTURER_NUMBER );

ALTER TABLE PROFESSOR
	ADD CONSTRAINT PK PRIMARY KEY 
	( WORKLOAD_RED_REASON
	, LECTURER_NUMBER );

ALTER TABLE EVENT
	ADD CONSTRAINT EVENT_LECTURE FOREIGN KEY
	( LECTURE_NUMBER )
	REFERENCES LECTURE
	( LECTURE_NUMBER )
	ON DELETE CASCADE; 

ALTER TABLE EVENT
	ADD CONSTRAINT EVENT_DEPARTMENT FOREIGN KEY
	( DEPARTMENT )
	REFERENCES DEPARTMENT
	( DEPARTMENT_SHORT ); 

ALTER TABLE EVENT
	ADD CONSTRAINT EVENT_DEPARTMENT_38 FOREIGN KEY
	( DEPARTMENT_IMPORTED_FROM )
	REFERENCES DEPARTMENT
	( DEPARTMENT_SHORT ); 

ALTER TABLE EXTERNAL_LECTURER
	ADD CONSTRAINT EXTERNAL_LECTURER_LECTURER FOREIGN KEY
	( LECTURER_NUMBER )
	REFERENCES LECTURER
	( LECTURER_NUMBER )
	ON DELETE CASCADE; 

ALTER TABLE LECTURER_EVENT
	ADD CONSTRAINT LECTURER_EVENT_LECTURER FOREIGN KEY
	( LECTURER_NUMBER )
	REFERENCES LECTURER
	( LECTURER_NUMBER )
	ON DELETE CASCADE; 

ALTER TABLE LECTURER_EVENT
	ADD CONSTRAINT LECTURER_EVENT_EVENT FOREIGN KEY
	( COURSE
	, LECTURE_NUMBER )
	REFERENCES EVENT
	( COURSE
	, LECTURE_NUMBER )
	ON DELETE CASCADE; 

ALTER TABLE LECTURER_EVENT
	ADD CONSTRAINT LECTURER_EVENT_EVENT_COUPLING FOREIGN KEY
	( COUPLING_ID )
	REFERENCES EVENT_COUPLING
	( COUPLING_ID ); 

ALTER TABLE PROFESSOR
	ADD CONSTRAINT PROFESSOR_LECTURER FOREIGN KEY
	( LECTURER_NUMBER )
	REFERENCES LECTURER
	( LECTURER_NUMBER )
	ON DELETE CASCADE; 

ALTER TABLE PROFESSOR
	ADD CONSTRAINT PROFESSOR_DEPARTMENT FOREIGN KEY
	( DEPARTMENT_SHORT )
	REFERENCES DEPARTMENT
	( DEPARTMENT_SHORT ); 

