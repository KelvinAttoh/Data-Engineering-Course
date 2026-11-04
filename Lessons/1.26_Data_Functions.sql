

SELECT 
    job_posted_date
FROM job_postings_fact
LIMIT 10
;



-- Using the CAST function
SELECT 
    job_posted_date,
    job_posted_date :: DATE AS job_posted,
    job_posted_date :: TIME AS job_posted_time,
    job_posted_date :: TIMESTAMP AS job_posted_timestamp,
    job_posted_date :: TIMESTAMPTZ AS job_posted_timestampz
FROM job_postings_fact
LIMIT 10
;



-- Using EXTRACT function
SELECT 
    job_posted_date,
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    EXTRACT(DAY FROM job_posted_date) AS job_posted_day
FROM job_postings_fact
LIMIT 10
;


-- Aggregating job_posting in months
-- Using EXTRACT function
SELECT 
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id)                       AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY EXTRACT(YEAR FROM job_posted_date), EXTRACT(MONTH FROM job_posted_date)
ORDER BY job_posted_year DESC, job_count DESC
;


-- Using the DATE_TRUNC function
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id)                        AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer' AND
     EXTRACT(YEAR FROM job_posted_date) = 2024
GROUP BY DATE_TRUNC('month', job_posted_date)
ORDER BY job_posted_month
;















