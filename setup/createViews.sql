-- @author alriit00, damait06
ECHO "Course Planner";
CREATE VIEW COURSE_PLANNER AS
SELECT 	EVENT.current_semester
		, EVENT.lecture_number AS Event_number
		, LECTURE.lecture_name		
		, LECTURE.pwz
		, EVENT.event_comments
		, LECTURE.semester_hours_spo 
		, EVENT.semester_hours_actual
FROM LECTURE
FULL OUTER JOIN EVENT
ON LECTURE.lecture_number = EVENT.lecture_number;

ECHO "Workload Reduction";
CREATE VIEW WORKLOAD_REDUCTION AS
SELECT 	EVENT.current_semester
		, LECTURER.name
		, PROFESSOR.workload_red_reason
		, PROFESSOR.workload_red_amount 
FROM PROFESSOR
FULL OUTER JOIN LECTURER
ON PROFESSOR.lecturer_number = LECTURER.lecturer_number
FULL OUTER JOIN LECTURER_EVENT
ON LECTURER.lecturer_number = LECTURER_EVENT.lecturer_number
FULL OUTER JOIN EVENT
ON (LECTURER_EVENT.lecture_number = EVENT.lecture_number 
	AND	LECTURER_EVENT.course = EVENT.course);
	
ECHO "Matchmaker";
CREATE VIEW MATCHMAKER AS
SELECT 	EVENT.course
		, LECTURE.semester
		, EVENT.current_semester
		, EVENT.lecture_number AS Event_number
		, LECTURE.lecture_name
		, LECTURE.semester_hours_spo
		, EVENT.semester_hours_actual
		, LECTURE.pwz
		, LECTURER_EVENT.schedule_workload_actual 
		, EVENT.department_imported_from
		, EVENT.department
		, LECTURER_EVENT.lecturer_workload_actual
		, LECTURER.name
		, LECTURE.lecture_comments
		, LECTURER.lecturer_comments
		, EVENT.event_comments
FROM LECTURE
FULL OUTER JOIN EVENT
ON LECTURE.lecture_number = EVENT.lecture_number
FULL OUTER JOIN LECTURER_EVENT
ON (EVENT.lecture_number = LECTURER_EVENT.lecture_number
	AND EVENT.course = LECTURER_EVENT.course)
FULL OUTER JOIN LECTURER
ON LECTURER_EVENT.lecturer_number = LECTURER.lecturer_number
FULL OUTER JOIN EVENT_COUPLING
ON LECTURER_EVENT.coupling_id = EVENT_COUPLING.coupling_id
;

ECHO "Service Planner";
CREATE VIEW SERVICE_PLANNER AS
SELECT 	EVENT.course
		, LECTURE.semester
		, EVENT.current_semester
		, EVENT.lecture_number AS Event_number
		, LECTURE.lecture_name
		, LECTURE.semester_hours_spo
		, EVENT.semester_hours_actual
		, LECTURE.pwz
		, LECTURER_EVENT.schedule_workload_actual 
		, EVENT.department_imported_from
		, EVENT.department
		, LECTURER_EVENT.lecturer_workload_actual
		, LECTURER.name
		, LECTURE.lecture_comments
		, LECTURER.lecturer_comments
FROM LECTURE
FULL OUTER JOIN EVENT
ON LECTURE.lecture_number = EVENT.lecture_number
FULL OUTER JOIN LECTURER_EVENT
ON (EVENT.lecture_number = LECTURER_EVENT.lecture_number
	AND EVENT.course = LECTURER_EVENT.course)
FULL OUTER JOIN LECTURER
ON LECTURER_EVENT.lecturer_number = LECTURER.lecturer_number
FULL OUTER JOIN EVENT_COUPLING
ON LECTURER_EVENT.coupling_id = EVENT_COUPLING.coupling_id
;