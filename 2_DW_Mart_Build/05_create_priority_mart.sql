DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

SELECT '=== Loading Roles for Priority Mart ===' AS Info;
CREATE TABLE priority_mart.priority_roles (
    role_id             INTEGER         PRIMARY KEY,
    role_name           VARCHAR,
    priority_level      INTEGER
)
;

INSERT INTO priority_mart.priority_roles (
    role_id,
    role_name,
    priority_level
)
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3)
;


-- DATA VALIDATION:
SELECT *
FROM priority_mart.priority_roles
;

SELECT
    'Priority Role' AS table_name,
    COUNT(*) AS record_count
FROM priority_mart.priority_roles;




SELECT '=== Loading Snapshot for Priority Mart ===' AS Info;
CREATE OR REPLACE TABLE priority_mart.priority_jobs_snapshot (
    job_id                  INT PRIMARY KEY,
    job_title_short         VARCHAR,
    company_name            VARCHAR,
    job_posted_date         TIMESTAMP,
    salary_year_avg         DOUBLE,
    priority_level          INT,
    updated_at              TIMESTAMP,
)
;

INSERT INTO priority_mart.priority_jobs_snapshot (  
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_level,
    updated_at
    )
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name                 AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_level,
    CURRENT_TIMESTAMP
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name
;


SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_level),
    MIN(updated_at)
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC
;