-- CASE Expressions
-- Bucket Salary

-- < 25 = 'Low'
-- between 25 & 50 = 'Medium'
-- > 50 = 'High'


SELECT 
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 10
;




-- Handling Missing Data (Nulls)
-- Filter NULL salary values

SELECT 
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM job_postings_fact
LIMIT 10
;




-- Categorizing Categorical Values
-- Classify the 'job_title' column values as:
-- 'Data Analyst'
-- 'Data Scientist'
-- 'Data Engineer'


SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title_short LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title_short LIKE '%Scientist%' THEN 'Data Scientist'
        WHEN job_title LIKE '%Data%' AND job_title_short LIKE '%Engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM job_postings_fact
LIMIT 20
;



-- Conditional Aggregation
-- Calculate Median Shares for different Buckets:
-- < $100K
-- >= $100K

SELECT
    job_title_short,
    COUNT(*) AS job_postings,
    MEDIAN(
        CASE WHEN salary_year_avg < 100_000 THEN salary_year_avg
        END
    ) AS Median_low_salary,
    MEDIAN(
        CASE WHEN salary_year_avg >= 100_000 THEN salary_year_avg
        END
    ) AS Median_high_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
LIMIT 25
;



-- FINAL EXAMPLE: Conditional Calculations
-- Compute a standardized_salary using yearly salary and adjusted hourly salary (Eg. 2080 hours/year)
-- Categorize salary into tiers of:
-- < $75K 'Low'
-- $75K - $105K 'Medium'
-- >= $105K 'High'


WITH salary_category AS (
SELECT
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    CASE
        WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
        WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    END AS standardized_salary
FROM job_postings_fact
)

SELECT 
    *,
    CASE
        WHEN standardized_salary IS NULL THEN 'Missing'
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 105_000 THEN 'Medium'
        ELSE 'High'
    END AS salaty_buckets
FROM salary_category
WHERE
    salary_year_avg IS NOT NULL
    OR
    salary_hour_avg IS NOT NULL
LIMIT 20
;




