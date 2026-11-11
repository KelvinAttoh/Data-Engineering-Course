SELECT
    job_location,
    COUNT(*)       AS job_postings
FROM {{ref('job_postings')}}
GROUP BY 
    job_location
ORDER BY
    job_postings DESC
LIMIT 10