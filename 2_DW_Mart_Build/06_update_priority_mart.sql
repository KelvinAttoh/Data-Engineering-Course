-- STEP 6: Mart - Update priority role mart


SELECT '=== Updating Roles for Priority Mart ===' AS Info;
-- Update the Data Engineer to priority level 1
UPDATE priority_mart.priority_roles
SET priority_level = 1
WHERE role_name = 'Data Engineer'
;


-- Add Data Scientist as priority level 3
INSERT INTO priority_mart.priority_roles (
    role_id,
    role_name,
    priority_level
)
VALUES
    (4, 'Data Scientist', 3)
;

SELECT * FROM priority_mart.priority_roles;



SELECT '=== Creating Temporary Source Table for Priority Mart ===' AS Info;
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
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS pr
    ON jpf.job_title_short = pr.role_name
;



-- MERGE INTO statement
-- This combines all of the three processes; UPDATE, INSERT & DELETE
SELECT '=== Batch updating priority jobs snapshot for Priority Mart ===' AS Info;
MERGE INTO priority_mart.priority_jobs_snapshot AS target_tbl
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
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC
;