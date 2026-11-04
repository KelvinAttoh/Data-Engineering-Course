-- Subquery

SELECT 
    *
FROM (
        SELECT *
        FROM job_postings_fact
        WHERE salary_year_avg IS NOT NULL
            OR salary_hour_avg IS NOT NULL
) AS valid_salaries
LIMIT 10
;


-- Using CTEs

WITH valid_salaries AS (
    SELECT *
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL
)
SELECT *
FROM valid_salaries
LIMIT 10
;


-- SCENARIO 1: Performing Subquery in the SELECT clause
-- Show each job salary next to the overall median market

SELECT
    job_title_short,
    ROUND(salary_year_avg, 2) AS salary_year_avg,
    (

        SELECT 
            MEDIAN(salary_year_avg)
        FROM job_postings_fact

    ) AS market_median_salary,
    CASE
        WHEN salary_year_avg > (
            SELECT 
                MEDIAN(salary_year_avg)
            FROM job_postings_fact
        ) THEN 'Above Median'
        WHEN salary_year_avg < (
            SELECT 
                MEDIAN(salary_year_avg)
            FROM job_postings_fact
        ) THEN 'Below Median'
        ELSE 'At Median'
    END AS salary_comparison    

FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10
;


-- SCENARIO 2: Performing Subquery in the FROM clause
-- Stage only jobs that are only remote before aggregating to determine the remote median salary

SELECT
    job_title_short,
    ROUND(MEDIAN(salary_year_avg), 2) AS median_salary,
    (

        SELECT 
            MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE -- Adding this because I want the market salary to refelct through for only remote jobs

    ) AS market_remote_median_salary 
FROM (
    SELECT 
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE -- Because its boolean, either 'TRUE' or 'YES' works, but 'TRUE' is more standard
) AS remote_jobs -- Not gonna use it anywhere else, i mean the alias
GROUP BY job_title_short
-- ORDER BY remote_median_salary DESC
LIMIT 10
;


-- SCENARIO 3: Performing Subquery in the HAVING clause
-- Keep only job titles whose median salary is above the overall market median salary

SELECT
    job_title_short,
    ROUND(MEDIAN(salary_year_avg), 2) AS salary_year_avg,
   (

        SELECT 
            MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE -- Adding this because I want the market salary to refelct through for only remote jobs
        
    ) AS market_remote_median_salary  
FROM (
    SELECT 
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE -- Because its boolean, either 'TRUE' or 'YES' works, but 'TRUE' is more standard
) AS remote_jobs -- Not gonna use it anywhere else, i mean the alias
-- WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
HAVING ROUND(MEDIAN(salary_year_avg), 2) > (
   
        SELECT 
            MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
)
LIMIT 10
;



-- CTE Example
-- Compare how much or less remote role pays compared to onsite role for each job title
-- Use CTE to calculate the median salary by title and work arrangement, then compare those medians

WITH title_median_salaries AS (
SELECT
    job_title_short,
    job_work_from_home,
    MEDIAN(salary_year_avg) :: INT AS median_salary
FROM job_postings_fact
GROUP BY job_title_short, job_work_from_home
)
SELECT
    r.job_title_short,
    r.median_salary AS remote_median_salary,
    o.median_salary AS onsite_median_salary,
    (r.median_salary - o.median_salary) AS salary_difference_premium
FROM title_median_salaries AS r
JOIN title_median_salaries AS o
    ON r.job_title_short = o.job_title_short
WHERE r.job_work_from_home = TRUE
    AND o.job_work_from_home = FALSE
ORDER BY salary_difference_premium DESC
;



-- Using the WHERE EXIST clause

SELECT range(8);

SELECT *
FROM range(3) as src(key);

SELECT *
FROM range(2) as tg(key);

SELECT *
FROM range(3) AS src(key)
WHERE EXISTS (

    SELECT 1
    FROM range(2) AS tg(key)
    WHERE src.key = tg.key

)
;


-- Using WHERE NOT EXIST clause
SELECT *
FROM range(3) AS src(key)
WHERE NOT EXISTS (

    SELECT 1
    FROM range(2) AS tg(key)
    WHERE src.key = tg.key

)
;

-- FInal Example:
-- Identify job postings that have no associated skills before loading them into data mart

SELECT *
FROM job_postings_fact
ORDER BY job_id DESC
;


SELECT *
FROM skills_job_dim
ORDER BY job_id
LIMIT 40
;


SELECT *
FROM job_postings_fact AS tg
WHERE NOT EXISTS (
    
    SELECT 1
    FROM skills_job_dim AS src
    WHERE tg.job_id = src.job_id
)

ORDER BY job_id
;















