--@author eumuit00
--#SET TERMINATOR %
echo "----------------------------"%
echo "EXECUTE: createTrigger.sql"%
echo "----------------------------"%
echo ""%
echo "DROP TRIGGER COURSE_PLANNER_VIEW_INSERT..."%
DROP TRIGGER COURSE_PLANNER_VIEW_INSERT%

echo "CREATE TRIGGER COURSE_PLANNER_VIEW_INSERT..."%
CREATE TRIGGER COURSE_PLANNER_VIEW_INSERT
INSTEAD OF INSERT ON COURSE_PLANNER
REFERENCING NEW AS n
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	INSERT INTO LECTURE VALUES(n.lecture_number, n.lecture_name, n.lecture_comments, n.semester, n.credit_amount, n.pwz, n.semester_hours_spo);
	
	INSERT INTO EVENT VALUES(n.lecture_number, n.course, n.current_semester, n.semester_hours_actual, n.event_comments, n.semester_hours_spo, 'IT',NULL);
	
END%

echo "DROP TRIGGER COURSE_PLANNER_VIEW_UPDATE..."%
DROP TRIGGER COURSE_PLANNER_VIEW_UPDATE%

echo "CREATE TRIGGER COURSE_PLANNER_VIEW_UPDATE..."%
CREATE TRIGGER COURSE_PLANNER_VIEW_UPDATE
INSTEAD OF UPDATE ON COURSE_PLANNER
REFERENCING NEW AS n OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	DELETE FROM EVENT 
	WHERE lecture_number = o.lecture_number AND  course = o.course
	;

	DELETE FROM LECTURE 
	WHERE lecture_number = o.lecture_number
	;
	
	INSERT INTO LECTURE VALUES(n.lecture_number, n.lecture_name, n.lecture_comments, n.semester, n.credit_amount, n.pwz, n.semester_hours_spo);
	
	INSERT INTO EVENT VALUES(n.lecture_number, n.course, n.current_semester, n.semester_hours_actual, n.event_comments, n.semester_hours_spo, 'IT',NULL);
	
END%

echo "DROP TRIGGER COURSE_PLANNER_VIEW_DELETE..."%
DROP TRIGGER COURSE_PLANNER_VIEW_DELETE%

echo "CREATE TRIGGER COURSE_PLANNER_VIEW_DELETE..."%
CREATE TRIGGER COURSE_PLANNER_VIEW_DELETE
INSTEAD OF DELETE ON COURSE_PLANNER
REFERENCING OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	DELETE FROM EVENT 
	WHERE lecture_number = o.lecture_number AND  course = o.course
	;

	DELETE FROM LECTURE 
	WHERE lecture_number = o.lecture_number
	;
END%

---------------------------------------------------------------------
echo "DROP TRIGGER WORKLOAD_REDUCTION_VIEW_INSERT..."%
DROP TRIGGER WORKLOAD_REDUCTION_VIEW_INSERT%

echo "CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_INSERT..."%
CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_INSERT
INSTEAD OF INSERT ON WORKLOAD_REDUCTION
REFERENCING NEW AS n
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	INSERT INTO REDUCTION
	VALUES(	n.WORKLOAD_RED_REASON, 
			(
				SELECT L.LECTURER_NUMBER
				FROM LECTURER AS L 
				WHERE N.NAME = L.NAME
			), 
			n.WORKLOAD_RED_AMOUNT, 
			n.TERM );

END%

echo "DROP TRIGGER WORKLOAD_REDUCTION_VIEW_UPDATE..."%
DROP TRIGGER WORKLOAD_REDUCTION_VIEW_UPDATE%

echo "CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_UPDATE..."%
CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_UPDATE
INSTEAD OF UPDATE ON WORKLOAD_REDUCTION
REFERENCING NEW AS n OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	DELETE FROM REDUCTION 
	WHERE LECTURER_NUMBER = 			
		(
			SELECT L.LECTURER_NUMBER
			FROM LECTURER AS L 
			WHERE o.NAME = L.NAME
		)
	AND  WORKLOAD_RED_REASON = o.WORKLOAD_RED_REASON
	;

	INSERT INTO REDUCTION
	VALUES( n.WORKLOAD_RED_REASON,
			(
				SELECT L.LECTURER_NUMBER
				FROM LECTURER AS L 
				WHERE N.NAME = L.NAME
			), 
			n.WORKLOAD_RED_AMOUNT,
			n.TERM
			);

END%

echo "DROP TRIGGER WORKLOAD_REDUCTION_VIEW_DELETE..."%
DROP TRIGGER WORKLOAD_REDUCTION_VIEW_DELETE%

echo "CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_DELETE..."%
CREATE TRIGGER WORKLOAD_REDUCTION_VIEW_DELETE
INSTEAD OF DELETE ON WORKLOAD_REDUCTION
REFERENCING OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	DELETE FROM REDUCTION 
	WHERE LECTURER_NUMBER = 			
		(
			SELECT L.LECTURER_NUMBER
			FROM LECTURER AS L 
			WHERE o.NAME = L.NAME
		)
	AND  WORKLOAD_RED_REASON = o.WORKLOAD_RED_REASON
	;

END%
---------------------------------------------------------------------

echo "DROP TRIGGER MATCHMAKER_VIEW_INSERT..."%
DROP TRIGGER MATCHMAKER_VIEW_INSERT%

echo "CREATE TRIGGER MATCHMAKER_VIEW_INSERT..."%
CREATE TRIGGER MATCHMAKER_VIEW_INSERT
INSTEAD OF INSERT ON MATCHMAKER
REFERENCING NEW AS n
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC
-- INSERT INTO MATCHMAKER (
-- 		COURSE, SEMESTER, CURRENT_SEMESTER, LECTURE_NAME,
--		SEMESTER_HOURS_SPO_ACTUAL, SEMESTER_HOURS_ACTUAL,
--		SPLIT_WORKLOAD, NAME, EVENT_COMMENTS)

	INSERT INTO
		LECTURER_EVENT (
			LECTURER_NUMBER,
			COURSE,
			LECTURE_NUMBER,
			SPLIT_WORKLOAD)
		VALUES
			(
				(
					SELECT LECTURER_NUMBER
					FROM LECTURER 
					WHERE NAME = n.NAME
				),
				n.COURSE,
				(
					SELECT L.LECTURE_NUMBER
					FROM EVENT AS E LEFT OUTER JOIN LECTURE AS L
					ON E.LECTURE_NUMBER = L.LECTURE_NUMBER
					WHERE
						E.COURSE = n.COURSE AND
						E.CURRENT_SEMESTER = n.CURRENT_SEMESTER AND
						L.SEMESTER = n.SEMESTER AND
						L.LECTURE_NAME = n.LECTURE_NAME
					FETCH FIRST 1 ROW ONLY
				),
				n.SPLIT_WORKLOAD
			);
		
	UPDATE PROFESSOR AS P SET P.WORKLOAD_ACTUAL = (P.WORKLOAD_ACTUAL - n.SPLIT_WORKLOAD)
	WHERE n.LECTURER_NUMBER = P.LECTURER_NUMBER;
END%

echo "DROP TRIGGER MATCHMAKER_VIEW_UPDATE..."%
DROP TRIGGER MATCHMAKER_VIEW_UPDATE%

echo "CREATE TRIGGER MATCHMAKER_VIEW_UPDATE..."%
CREATE TRIGGER MATCHMAKER_VIEW_UPDATE
INSTEAD OF UPDATE ON MATCHMAKER
REFERENCING new AS n OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	UPDATE PROFESSOR AS P1 SET P1.WORKLOAD_ACTUAL = (P1.WORKLOAD_ACTUAL + o.SPLIT_WORKLOAD)
	WHERE o.LECTURER_NUMBER = P1.LECTURER_NUMBER;

	DELETE FROM LECTURER_EVENT AS LE
	WHERE 	LE.LECTURER_NUMBER = o.LECTURER_NUMBER
	AND 	COURSE = o.COURSE
	AND		LE.LECTURE_NUMBER = o.LECTURE_NUMBER
	;

	UPDATE EVENT AS E1 SET
	E1.SEMESTER_HOURS_ACTUAL = n.SEMESTER_HOURS_ACTUAL,
	E1.SEMESTER_HOURS_SPO_ACTUAL = n.SEMESTER_HOURS_SPO_ACTUAL
	WHERE 	E1.LECTURE_NUMBER = o.LECTURE_NUMBER
	AND		E1.COURSE = o.COURSE
	;
	
	INSERT INTO
	LECTURER_EVENT (
		LECTURER_NUMBER,
		COURSE,
		LECTURE_NUMBER,
		SPLIT_WORKLOAD)
	VALUES
		(
			(
				SELECT LECTURER_NUMBER
				FROM LECTURER 
				WHERE NAME = n.NAME
			),
			n.COURSE,
			(
				SELECT L.LECTURE_NUMBER
				FROM EVENT AS E2 LEFT OUTER JOIN LECTURE AS L
				ON E2.LECTURE_NUMBER = L.LECTURE_NUMBER
				WHERE
					E2.COURSE = n.COURSE AND
					E2.CURRENT_SEMESTER = n.CURRENT_SEMESTER AND
					L.SEMESTER = n.SEMESTER AND
					L.LECTURE_NAME = n.LECTURE_NAME
				FETCH FIRST 1 ROW ONLY
			),
			n.SPLIT_WORKLOAD
		);
		
	UPDATE PROFESSOR AS P2 SET P2.WORKLOAD_ACTUAL = (P2.WORKLOAD_ACTUAL - n.SPLIT_WORKLOAD)
	WHERE n.LECTURER_NUMBER = P2.LECTURER_NUMBER;
	
END%

echo "DROP TRIGGER MATCHMAKER_VIEW_DELETE..."%
DROP TRIGGER MATCHMAKER_VIEW_DELETE%

echo "CREATE TRIGGER MATCHMAKER_VIEW_DELETE..."%
CREATE TRIGGER MATCHMAKER_VIEW_DELETE
INSTEAD OF DELETE ON MATCHMAKER
REFERENCING OLD AS o
FOR EACH ROW MODE DB2SQL
BEGIN ATOMIC

	UPDATE PROFESSOR AS P SET P.WORKLOAD_ACTUAL = P.WORKLOAD_ACTUAL + o.SPLIT_WORKLOAD
	WHERE o.LECTURER_NUMBER = P.LECTURER_NUMBER;

	DELETE FROM LECTURER_EVENT 
	WHERE 	LECTURER_NUMBER = o.LECTURER_NUMBER
	AND 	COURSE = o.COURSE
	AND		LECTURE_NUMBER = o.LECTURE_NUMBER
	;
	
END%

--#SET TERMINATOR ;