/* 

Using these opertaions
UNION       INTERSECT       EXCEPT
UNION ALL   INTERSECT ALL   EXCEPT ALL

*/




-- Creating Tables for job_posting 2023 and 2024

CREATE TEMPORARY TABLE job_posting_2023 AS
/* 

Use DESCRIBE to view the columns available in table
┌───────────────────────────────┐
│       job_postings_fact       │
│                               │
│ company_id            integer │
│ job_title_short       varchar │
│ job_title             varchar │
│ job_location          varchar │
│ job_via               varchar │
│ job_schedule_type     varchar │
│ job_work_from_home    boolean │
│ search_location       varchar │
│ job_no_degree_mention boolean │
│ job_health_insurance  boolean │
│ job_country           varchar │
│ salary_rate           varchar │
│ salary_year_avg       double  │
│ salary_hour_avg       double  │
└───────────────────────────────┘

*/

SELECT
    * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023
;

/*

SELECT *
FROM job_posting_2023
;

*/




CREATE TEMPORARY TABLE job_posting_2024 AS
SELECT
    * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2024
;


/*

SELECT *
FROM job_posting_2024
;

*/



-- Answering these questions with set operations

-- QUESTION 1: Which unique job postings are appear in either 2023 or 2024?

SELECT *
FROM job_posting_2023
UNION
SELECT *
FROM job_posting_2024
;


-- Which job postings appear in both years, counting duplicates?
SELECT *
FROM job_posting_2023
UNION ALL
SELECT *
FROM job_posting_2024
;


-- Which job posting appear in 2023 but not in 2024?
SELECT *
FROM job_posting_2023
EXCEPT
SELECT *
FROM job_posting_2024
;


-- Which job posting from 2023 remain after subtracting matching 2024 posting, one-to-one?
SELECT *
FROM job_posting_2023
EXCEPT ALL
SELECT *
FROM job_posting_2024
;


-- Which job postings appear in both 2023 and 2024?
SELECT *
FROM job_posting_2023
INTERSECT
SELECT *
FROM job_posting_2024
;


-- Which job postings appear in both years, preserving duplicate counts
SELECT *
FROM job_posting_2023
INTERSECT ALL
SELECT *
FROM job_posting_2024
;

