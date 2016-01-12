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
