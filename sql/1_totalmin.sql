-- =====================================================================================
-- CTE that calculates total minutes watched & total number of students in each course
-- =====================================================================================
WITH tmw AS (
SELECT ci.course_id, ci.course_title,
ROUND(SUM(sl.minutes_watched),2) AS total_minutes_watched,
COUNT(DISTINCT sl.student_id) AS num_students
FROM 365_database.365_course_info ci
JOIN 365_database.365_student_learning sl ON ci.course_id = sl.course_id
GROUP BY ci.course_id
),
total_avg_min AS (
SELECT *, ROUND(total_minutes_watched / num_students, 2) AS average_minutes
 from tmw
 ),
 title_rating AS (
 SELECT t.course_id, t.course_title, t.total_minutes_watched, t.average_minutes,
 COUNT(cr.course_rating) AS number_ratings,
 IF(COUNT(cr.course_rating) != 0, SUM(cr.course_rating) / COUNT(cr.course_rating), 0) AS average_rating
 FROM total_avg_min t
 LEFT JOIN 365_database.365_course_ratings cr ON t.course_id = cr.course_id
 GROUP BY t.course_id
 )
 SELECT * from title_rating;