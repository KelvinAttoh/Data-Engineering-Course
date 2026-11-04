SELECT [1, 2, 3];

SELECT ['python', 'sql', 'r'] AS skills;

SELECT 'python' AS skill
UNION ALL
SELECT 'sql' 
UNION ALL
SELECT 'r' ;


-- Perform a CTE for array of skills
WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql' 
    UNION ALL
    SELECT 'r'
)
SELECT ARRAY_AGG(skill) AS skills_array
FROM skills
;




-- Working with JSON data
WITH raw_skill_json AS (
SELECT
    '{"skill" : "python", "type" : "programming"}' :: JSON AS skill_json
)
SELECT 
    skill_json
FROM raw_skill_json
;


-- Now using the STRUCT to extract the key column from json data
-- Rebuilding this format so that this could be used in SQL

WITH raw_skill_json AS (
SELECT
    '{"skill" : "python", "type" : "programming"}' :: JSON AS skill_json
)
SELECT 
    STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
FROM raw_skill_json
;




-- ARRAYS - Final Example
-- Build a flat skill table for co-workers to access job titles, salary info and skills in one table

CREATE OR REPLACE TEMPORARY TABLE job_skills_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL
;

-- From the perspective of a Data Analyst, analyze the median salary per skill
WITH flat_skill AS (
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_array) AS skill
FROM job_skills_array
)
SELECT 
    skill,
    MEDIAN(salary_year_avg) AS median_skill_salary
FROM flat_skill
GROUP BY skill
ORDER BY median_skill_salary DESC
LIMIT 20
;


-- ARRAYS - Final Example
-- Build a flat skill table for co-workers to access job titles, salary info, type and skills in one table

CREATE OR REPLACE TEMPORARY TABLE job_skills_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) AS skills_struct
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id
GROUP BY ALL
;

-- From the perspective of a Data Analyst, analyze the median salary per type
WITH flat_skill_struct AS (
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_struct).skill_type AS skill_type,
    UNNEST(skills_struct).skill_name AS skill,
FROM job_skills_struct
)
SELECT 
    skill_type,
    MEDIAN(salary_year_avg) AS median_skill_salary
FROM flat_skill_struct
GROUP BY skill_type
-- ORDER BY median_skill_salary DESC
LIMIT 20
;










