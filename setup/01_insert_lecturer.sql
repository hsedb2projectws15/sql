INSERT INTO LECTURER (LECTURER_NUMBER, LECTURER_COMMENTS , NAME, FIRSTNAME)
SELECT LECNR, COMMENTS, FIRSTN, LASTN
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
