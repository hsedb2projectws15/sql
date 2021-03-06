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
