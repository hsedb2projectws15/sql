INSERT INTO EXTERNAL_LECTURER (LECTURER_NUMBER)
SELECT DISTINCT LECNO
FROM RAWDATA
WHERE LECNAME LIKE 'LB %'
;
