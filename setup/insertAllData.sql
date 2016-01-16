-- @author eumuit00

INSERT INTO LECTURER (LECTURER_NUMBER, LECTURER_COMMENTS , NAME, FIRSTNAME)
SELECT LECNR, COMMENTS, LASTN, FIRSTN
	FROM(
		SELECT
			CASE
				when LECNO IS NULL then '0000'
				else LECNO
			END AS LECNR,
			CASE
				when SBJNOTES IS NULL then 'NA'
				else SBJNOTES
			END AS COMMENTS,
			CASE
				when LEC1STN IS NULL then 'noname'
				else LEC1STN
			END AS FIRSTN,
			CASE
				when LECNAME IS NULL then 'noname'
				else LECNAME
			END AS LASTN,
			ROW_NUMBER() OVER(PARTITION BY LECNO ORDER BY SBJNOTES) rn
		FROM RAWDATA
	) a
WHERE rn = 1
;

INSERT INTO DEPARTMENT (DEPARTMENT_SHORT, DEPARTMENT_NAME)
SELECT FirstRow, concat
(
	CASE FirstRow
	WHEN 'G' then 'Grundlagen'
	WHEN 'GS' then 'Graduate School'
	WHEN 'IFS' then 'Institut für Fremdsprachen'
	WHEN 'IT' then 'Informationstechnik'
	WHEN 'WI' then 'Wirtschaftsingenieurswesen'
	WHEN 'AN' then 'Angewandte Naturwissenschaften'
	WHEN 'HHZ' then 'HHZ'

	ELSE 'Not Available'
	END, ''
) AS SecondRow
FROM(
	Select coalesce (LECDEPT, 'NA') as FirstRow 
	FROM RAWDATA
	UNION
	Select coalesce (DEPT, 'NA')
	FROM RAWDATA) SRC
;

INSERT INTO LECTURE (LECTURE_NUMBER, LECTURE_NAME, LECTURE_COMMENTS, SEMESTER, CREDIT_AMOUNT, PWZ, SEMESTER_HOURS_SPO)
SELECT SBJNO, SBJNAME, LECNOTES, SBJLEVEL, NUMCURR, ELECTIVE, NUMSCHD
FROM(
	SELECT
	SBJNO, 
	SBJNAME, 
	LECNOTES,
	SBJLEVEL, 
	NUMCURR, 
	ELECTIVE, 
	NUMSCHD,
	ROW_NUMBER() OVER(PARTITION BY SBJNO ORDER BY LECNOTES) rn
	FROM RAWDATA 
) a
WHERE rn = 1		
ORDER BY SBJNAME DESC
;

INSERT INTO PROFESSOR (WORKLOAD_RED_REASON, WORKLOAD_RED_AMOUNT, DEPARTMENT_SHORT, LECTURER_NUMBER)
SELECT DISTINCT JOB_TITLE, REDUCTION, 
CASE
when RAWDATA.LECDEPT IS NULL then 'NA'
else RAWDATA.LECDEPT
END AS DEPTA,
RAWDATA.LECNO

FROM RAWDATA_WORKLOAD
LEFT JOIN RAWDATA
ON RAWDATA_WORKLOAD.NAME = RAWDATA.LECNAME
;

INSERT INTO EXTERNAL_LECTURER (LECTURER_NUMBER)
SELECT DISTINCT LECNO
FROM RAWDATA
WHERE LECNAME LIKE 'LB %'
;

INSERT INTO EVENT (LECTURE_NUMBER, COURSE, CURRENT_SEMESTER, SEMESTER_HOURS_ACTUAL, EVENT_COMMENTS, SEMESTER_HOURS_SPO_ACTUAL, DEPARTMENT, DEPARTMENT_IMPORTED_FROM)
SELECT SBJNO, STUDYPRG, TERM, CNTSCHD, LECNOTES, CNTCURR, DEPT, DEPTEX
FROM(
	SELECT
	SBJNO, 
	STUDYPRG,
	TERM, 
	CNTSCHD, 
	LECNOTES, 
	CNTCURR,
	CASE
	when RAWDATA.DEPT = 'IT' then RAWDATA.DEPT
	else 'IT'
	END as DEPT,
	CASE
	when RAWDATA.DEPT != 'IT' then RAWDATA.DEPT
	END as DEPTEX,
	ROW_NUMBER() OVER(PARTITION BY SBJNO ORDER BY LECNOTES) rn
	FROM RAWDATA 
) a
WHERE rn = 1		
ORDER BY SBJNO
;

INSERT INTO LECTURER_EVENT (LECTURER_NUMBER, COURSE, LECTURE_NUMBER)
SELECT DISTINCT LECNO, STUDYPRG, SBJNO
FROM(
	SELECT
	LECNO,
	STUDYPRG,
	SBJNO
	FROM RAWDATA 
) a
;
