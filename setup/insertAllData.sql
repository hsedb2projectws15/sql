-- @author eumuit00
echo "----------------------------";
echo "EXECUTE: insertAllData.sql";
echo "----------------------------";
echo "";
echo "INSERT INTO LECTURER";
INSERT INTO LECTURER (LECTURER_NUMBER, LECTURER_COMMENTS , NAME, FIRSTNAME)
SELECT LECNR, COMMENTS, LASTN, FIRSTN
	FROM(
		SELECT
			CASE
				when LECNO IS NULL then '0000'
				else LECNO
			END AS LECNR,
			CASE
				when SBJNOTES IS NULL then ''
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

echo "INSERT INTO DEPARTMENT";
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

echo "INSERT INTO LECTURE";
INSERT INTO LECTURE (LECTURE_NUMBER, LECTURE_NAME, LECTURE_COMMENTS, SEMESTER, CREDIT_AMOUNT, PWZ, SEMESTER_HOURS_SPO)
SELECT SBJNO, SBJNAME, LECNOTES, SBJLEVEL, NUMCURR, ELECTIVE, CNTLEC
FROM(
	SELECT
	SBJNO, 
	SBJNAME, 
	LECNOTES,
	SBJLEVEL, 
	NUMCURR, 
	ELECTIVE, 
	CNTLEC,
	ROW_NUMBER() OVER(PARTITION BY SBJNO ORDER BY LECNOTES) rn
	FROM RAWDATA 
) a
WHERE rn = 1		
ORDER BY SBJNAME DESC
;

echo "INSERT INTO PROFESSOR";
INSERT INTO PROFESSOR (LECTURER_NUMBER, DEPARTMENT_SHORT)

SELECT DISTINCT LECNO, LECDEPT
FROM RAWDATA WHERE PROF = 1 AND NOT LECDEPT = 'G';
;

echo "INSERT INTO EXTERNAL_LECTURER";
INSERT INTO EXTERNAL_LECTURER (LECTURER_NUMBER)
SELECT DISTINCT LECNO
FROM RAWDATA
WHERE LECNAME LIKE 'LB %'
;

echo "INSERT INTO REDUCTION";
INSERT INTO REDUCTION (LECTURER_NUMBER, WORKLOAD_RED_REASON, WORKLOAD_RED_AMOUNT, TERM)
SELECT
	(SELECT LECTURER_NUMBER FROM LECTURER WHERE NAME = R.NAME),
	R.JOB_TITLE,
	R.REDUCTION,
	R.TERM
FROM
	RAWDATA_WORKLOAD AS R
;


echo "INSERT INTO EVENT";
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


echo "INSERT INTO LECTURER_EVENT";
INSERT INTO LECTURER_EVENT (LECTURER_NUMBER, COURSE, LECTURE_NUMBER, SPLIT_WORKLOAD)
SELECT a.LECNO, a.STUDYPRG, a.SBJNO, min(a.CNTLEC)
FROM RAWDATA a 
LEFT JOIN LECTURER b 
ON a.linkedWith = b.NAME

GROUP BY LECNO, STUDYPRG, SBJNO
ORDER BY SBJNO
;

echo "UPDATE 1 PROFESSOR";
UPDATE PROFESSOR AS P
SET P.WORKLOAD_ACTUAL = P.WORKLOAD_ACTUAL - (
		SELECT SUM(LE.SPLIT_WORKLOAD)
		FROM LECTURER_EVENT AS LE
		WHERE LE.LECTURER_NUMBER = P.LECTURER_NUMBER
	);
	
--echo "UPDATE 2 PROFESSOR";
--UPDATE PROFESSOR AS P
--SET P.WORKLOAD_ACTUAL = P.WORKLOAD_ACTUAL - (
--		SELECT SUM(R.WORKLOAD_RED_AMOUNT)
--		FROM REDUCTION AS R
--		WHERE R.LECTURER_NUMBER = P.LECTURER_NUMBER
--	);

