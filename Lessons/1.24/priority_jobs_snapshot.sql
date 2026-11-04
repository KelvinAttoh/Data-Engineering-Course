
/*

This is a full data pipeline in order to perform batch processing...
STEP 1: By loading into our temporary source table
STEP 2: Performing an update in our main table
STEP 3: Then an insert 
STEP 4: And delete where necessary

*/



-- Create a Temporary TAble for referencing
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name                 AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_level,
    CURRENT_TIMESTAMP       AS updated_at
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name
;

-- -- To update the priority level in the main table
-- UPDATE main.priority_jobs_snapshot AS target_tbl
-- SET
--     priority_level = source_tbl.priority_level,
--     updated_at = source_tbl.updated_at
-- FROM src_priority_jobs AS source_tbl
-- WHERE target_tbl.job_id = source_tbl.job_id
--     AND target_tbl.priority_level IS DISTINCT FROM source_tbl.priority_level
-- ;


-- -- Insert statement
-- INSERT INTO main.priority_jobs_snapshot (
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_level,
--     updated_at 
-- )
-- SELECT
--     src.job_id,
--     src.job_title_short,
--     src.company_name,
--     src.job_posted_date,
--     src.salary_year_avg,
--     src.priority_level,
--     src.updated_at
-- FROM src_priority_jobs src
-- WHERE NOT EXISTS(
--     SELECT 1
--     FROM main.priority_jobs_snapshot AS target_tbl
--     WHERE target_tbl.job_id = src.job_id
-- )
-- ;


-- -- Delete statement
-- DELETE FROM main.priority_jobs_snapshot AS target_tbl
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM src_priority_jobs AS src
--     WHERE src.job_id = target_tbl.job_id
-- )
-- ;











-- MERGE INTO statement
-- This combines all of the three processes; UPDATE, INSERT & DELETE

MERGE INTO main.priority_jobs_snapshot AS target_tbl
USING src_priority_jobs AS source_tbl
ON target_tbl.job_id = source_tbl.job_id

WHEN MATCHED AND target_tbl.priority_level IS DISTINCT FROM source_tbl.priority_level THEN
    UPDATE SET
        priority_level = source_tbl.priority_level,
        updated_at = source_tbl.updated_at

WHEN NOT MATCHED THEN
    INSERT (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_level,
        updated_at 
    )
    VALUES (
        source_tbl.job_id,
        source_tbl.job_title_short,
        source_tbl.company_name,
        source_tbl.job_posted_date,
        source_tbl.salary_year_avg,
        source_tbl.priority_level,
        source_tbl.updated_at
    )

WHEN NOT MATCHED BY SOURCE THEN DELETE
;



-- Final Check
-- Checking whether everythinmg is updated when priority level changes from the priority roles table
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_level),
    MIN(updated_at)
FROM main.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC
;






















