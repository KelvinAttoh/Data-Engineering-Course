-- STEP 4: Mart - Create skills demand mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

CREATE TABLE skills_mart.dim_skills (
    skill_id    INTEGER     PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
)
;

INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim
;




CREATE TABLE skills_mart.dim_date_month (
    month_start_date      DATE        PRIMARY KEY,
    year            INTEGER,
    month           INTEGER,
    quarter         INTEGER,
    quarter_name    VARCHAR,
    quarter_year    VARCHAR
)
;


INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    quarter_year
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) :: DATE AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date) AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date) || '-Q' ||
    EXTRACT(QUARTER FROM job_posted_date) AS quarter_year
FROM job_postings_fact
ORDER BY month_start_date
;



CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                INTEGER,
    month_start_date        DATE,
    job_title_short         VARCHAR,
    job_posting_count       INTEGER,
    remote_count            INTEGER,
    health_insurance_count  INTEGER,
    no_degree_mention_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
)
;

INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    job_posting_count,
    remote_count,
    health_insurance_count,
    no_degree_mention_count
)
WITH job_posting_prep AS (
    SELECT
        DATE_TRUNC('month', jpf.job_posted_date) :: DATE AS month_start_date,
        jpf.job_title_short,
        sjd.skill_id,
        --convert all boolean values to 1 or 0
        CASE
            WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0
        END AS is_remote,
        CASE
            WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0
        END AS has_health_insurance,
        CASE
            WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0
        END AS no_degree_mention,
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS job_posting_count,
    SUM(is_remote) AS remote_count,
    SUM(has_health_insurance) AS health_insurance_count,
    SUM(no_degree_mention) AS no_degree_mention_count
FROM job_posting_prep
GROUP BY
    skill_id,
    month_start_date,
    job_title_short
ORDER BY
    skill_id,
    month_start_date,
    job_title_short
;


-- DATA VALIDATION: Check the number of rows in the fact table
SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count
FROM skills_mart.dim_skills
UNION ALL
SELECT 'Date Month Dimension', COUNT(*)
FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact', COUNT(*)
FROM skills_mart.fact_skill_demand_monthly
;




SELECT '=== Loading Skills Dimension Table ===' AS Info;
SELECT *
FROM skills_mart.dim_skills
LIMIT 5
;

SELECT '=== Loading Date Month Dimension Table ===' AS Info;
SELECT *
FROM skills_mart.dim_date_month
LIMIT 5
;

SELECT '=== Loading Skill Demand Fact Table ===' AS Info;
SELECT *
FROM skills_mart.fact_skill_demand_monthly
LIMIT 5
;





