DROP VIEW WORKLOAD_REDUCTION_VIEW;

CREATE VIEW WORKLOAD_REDUCTION_VIEW 
	(Professor, Funktion, Nachlass)
AS SELECT name, workload_red_reason,  workload_red_amount
FROM LECTURER, PROFESSOR;
