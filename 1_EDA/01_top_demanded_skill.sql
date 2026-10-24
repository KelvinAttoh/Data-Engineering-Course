
/*
Question: What are the most in-demand skills for data engineers?
- Join job postings to inner join table similar to query 2
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? Retrieves the top 10 skills with the highest demand in the remote job market,
    providing insights into the most valuable skills for data engineers seeking remote work
*/

SELECT
    DISTINCT sd2.skills AS skill,
    COUNT(sd2.skills) AS demand_count
FROM job_postings_fact jpf
LEFT JOIN skills_job_dim sd
    ON jpf.job_id = sd.job_id
INNER JOIN skills_dim sd2
    ON sd.skill_id = sd2.skill_id
WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = 'Yes'
GROUP BY sd2.skills
ORDER BY demand_count DESC
LIMIT 10
;

/*

┌────────────┬─────────────┐
│   skill    │ skill_count │
│  varchar   │    int64    │
├────────────┼─────────────┤
│ sql        │       29221 │
│ python     │       28776 │
│ aws        │       17823 │
│ azure      │       14143 │
│ spark      │       12799 │
│ airflow    │        9996 │
│ snowflake  │        8639 │
│ databricks │        8183 │
│ java       │        7267 │
│ gcp        │        6446 │
└────────────┴─────────────┘


*/