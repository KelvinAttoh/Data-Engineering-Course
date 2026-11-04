

CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    jpf.company_id,
    cd.name                     AS company_name
FROM data_jobs.job_postings_fact AS jpf
INNER JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
;

-- Checking the results of the staging table creation
SELECT *
FROM staging.job_postings_flat
LIMIT 10
;


-- Checking the total number of records in the staging table
SELECT COUNT(*)
FROM staging.job_postings_flat
;


/*

Creating a view for priority job postings based on the priority roles defined
in the staging.priority_roles table. This view will filter job postings to include only
those that match the priority roles with a priority level of 1.

*/

CREATE OR REPLACE VIEW staging.priority_jobs_flat_view AS
SELECT
    jpf.*
FROM staging.job_postings_flat AS jpf
JOIN staging.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name
WHERE pr.priority_level = 1
;


SELECT
    job_title_short,
    COUNT(*) AS priority_job_count
FROM staging.priority_jobs_flat_view
GROUP BY job_title_short
;


CREATE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT
    *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer'
;

SELECT
    job_title_short,
    COUNT(*) AS priority_job_count
FROM senior_jobs_flat_temp
GROUP BY job_title_short
;



SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;


DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01'

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp; -- The results in this temporary table will remain unchanged 
                                            -- since it is not updated and not in the schema, which is not 
                                            -- affected by the deletion in the job_postings_flat table.



TRUNCATE TABLE staging.job_postings_flat;

SELECT COUNT(*) FROM staging.job_postings_flat;


INSERT INTO staging.job_postings_flat
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    jpf.company_id,
    cd.name                     AS company_name
FROM data_jobs.job_postings_fact AS jpf
INNER JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.job_posted_date >= '2024-01-01'
;

SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;


