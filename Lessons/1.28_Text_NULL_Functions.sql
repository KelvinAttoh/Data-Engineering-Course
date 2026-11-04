
WITH lowercase_job_title AS (

SELECT
    job_title,
    LOWER(TRIM(job_title)) AS job_title_clean -- Use TRIM() to remove white spaces from text
                                                -- Use LOWER() to convert all text to lowercases
FROM job_postings_fact

)
SELECT
    job_title,
    CASE
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM lowercase_job_title
ORDER BY RANDOM()
;


-- USING COALESCE()
-- THis returns the first NON-NULL value when there's a NULL value

SELECT COALESCE(1, 7, 4); -- Even when there's no NULL value, it returns the first value
SELECT COALESCE(1, NULL, 4);
SELECT COALESCE(NULL, NULL, 4);
SELECT COALESCE(6, 3, NULL);


-- EXAMPLE
SELECT
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    COALESCE(salary_year_avg, (salary_hour_avg * 2080)) AS standardized_salary
    /*

    The COALESCE function above should return the salary_year_avg if it exists but return
    the multiplication value of salary_hour_avg * 2080 when there's a NULL value 

    */

FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL OR
    salary_hour_avg IS NOT NULL
;



-- SImplifying our CASE function with COALESCE function for salary bucket

SELECT
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    COALESCE(salary_year_avg, salary_hour_avg * 2080) :: INT AS standardized_salary,
    CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 75_000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 105_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC
LIMIT 10
;








