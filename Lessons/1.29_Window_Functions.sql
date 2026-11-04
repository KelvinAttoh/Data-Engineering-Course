-- Understanding the difference between Aggregated Functions & Window Functions
-- SO Aggregated functions calculate all rows into one single value while
-- Window functions perfroms a row level data aggregation


-- Performing Aggregations
SELECT
    COUNT(*)
FROM job_postings_fact
;

-- This returns a single value counts of job postings in the data


SELECT
    MEDIAN(salary_hour_avg)
FROM job_postings_fact
;
-- This returns the median hourly salary average for all job postings in the data



-- Performing WIndow Functions
SELECT
    job_id,
    COUNT(*) OVER () -- We use the phrase "OVER()" indicating that this is a WIndow function
FROM job_postings_fact
;


SELECT
    job_id,
    job_title_short,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short 
    /*

    This calculates the average of salary hourly by grouping job titles 

    */
    ) AS Average_salary_hour
FROM job_postings_fact
;


-- Assuming I want to find the running average salary hourly by job title and by which company
SELECT
    job_id,
    company_id,
    job_title_short,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short, company_id
    ) :: INT AS Average_salary_hour
FROM job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
LIMIT 20

/*

ANSWER
─────────┬────────────┬──────────────────────┬─────────────────────┐
│ job_id  │ company_id │   job_title_short    │ Average_salary_hour │
│  int32  │   int32    │       varchar        │        int32        │
├─────────┼────────────┼──────────────────────┼─────────────────────┤
│ 1218643 │      70568 │ Data Analyst         │                  44 │
│ 1218745 │    1218745 │ Data Analyst         │                  26 │
│ 1218797 │     979242 │ Data Analyst         │                  77 │
│ 1218798 │     979242 │ Data Analyst         │                  77 │
│ 1218807 │       4830 │ Data Engineer        │                  51 │
│ 1218837 │       6749 │ Senior Data Analyst  │                  27 │
│ 1218840 │       4830 │ Senior Data Engineer │                  51 │
│ 1218842 │       4830 │ Data Engineer        │                  51 │
│ 1218843 │       4830 │ Data Engineer        │                  51 │
│ 1218844 │       4830 │ Data Engineer        │                  51 │
│ 1218845 │       4830 │ Senior Data Engineer │                  51 │
│ 1218936 │     232403 │ Data Engineer        │                  70 │
│ 1218939 │    1218939 │ Data Engineer        │                  30 │
│ 1218965 │      22472 │ Data Engineer        │                  59 │
│ 1219070 │     945606 │ Data Engineer        │                  74 │
│ 1219075 │       7013 │ Data Scientist       │                  57 │
│ 1219077 │     945606 │ Data Engineer        │                  74 │
│ 1219094 │    1219094 │ Data Analyst         │                  41 │
│ 1219100 │      23162 │ Data Scientist       │                  48 │
│ 1219112 │     181093 │ Data Analyst         │                  52 │
└─────────┴────────────┴──────────────────────┴─────────────────────┘

*/
;



-- PARTITION BY & ORDER BY - Running Average Hourly Salary
SELECT
    job_id,
    job_posted_date,
    job_title_short,
    salary_hour_avg :: INT,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) :: INT AS running_average_by_title
FROM job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    job_title_short,
    job_posted_date
LIMIT 20
;



-- Running avaergae hourly salary by Data Engineers in job postings
SELECT
    job_id,
    job_posted_date,
    job_title_short,
    salary_hour_avg :: INT,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    ) :: INT AS running_average_by_title
FROM job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL AND
    job_title_short = 'Data Engineer'
ORDER BY
    job_title_short,
    job_posted_date
LIMIT 20
;


-- Perfroming a rank on hourly salary for job postings

SELECT
    job_id,
    job_title_short,
    salary_hour_avg :: INT,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) rank_hourly_salary
FROM job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
LIMIT 20
;



-- PARTITION BY & ORDER BY - Ranking Hourly Salary by job title
SELECT
    job_id,
    job_title_short,
    salary_hour_avg :: INT,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) rank_hourly_salary
FROM job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    job_title_short,
    salary_hour_avg DESC
LIMIT 20
;



-- Performing LAG() & LEAD() in Window functions
SELECT
    job_id,
    job_posted_date,
    job_title_short,
    company_id,
    salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_salary
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY 
    company_id,
    job_posted_date
LIMIT 60
;



-- Now adding a salary change column
SELECT
    job_id,
    job_posted_date,
    job_title_short,
    company_id,
    salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_salary,
    -- We use LAG() to determine the previous value and LEAD() for next value
    salary_year_avg - LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) As salary_change
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY 
    company_id,
    job_posted_date
LIMIT 60
;









