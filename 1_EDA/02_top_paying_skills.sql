/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development priorities
*/


SELECT
    DISTINCT sd2.skills AS skill,
    COUNT(sd2.skills) AS skill_frequency,
    ROUND(MEDIAN(jpf.salary_year_avg), 0) AS median_salary
FROM job_postings_fact jpf
LEFT JOIN skills_job_dim sd
    ON jpf.job_id = sd.job_id
INNER JOIN skills_dim sd2
    ON sd.skill_id = sd2.skill_id
WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = 'Yes'
GROUP BY sd2.skills
ORDER BY median_salary DESC
LIMIT 25
;


/*

┌───────────┬─────────────────┬───────────────┐
│   skill   │ skill_frequency │ median_salary │
│  varchar  │      int64      │    double     │
├───────────┼─────────────────┼───────────────┤
│ rust      │             232 │      210000.0 │
│ sheets    │              98 │      196698.0 │
│ solidity  │              45 │      192500.0 │
│ golang    │             912 │      184000.0 │
│ terraform │            3248 │      184000.0 │
│ next.js   │              19 │      180000.0 │
│ ggplot2   │              15 │      176250.0 │
│ spring    │             364 │      175500.0 │
│ erlang    │               9 │      172500.0 │
│ ocaml     │               1 │      172500.0 │
│ haskell   │              17 │      172500.0 │
│ neo4j     │             277 │      170000.0 │
│ gdpr      │             582 │      169616.0 │
│ zoom      │             127 │      168438.0 │
│ graphql   │             445 │      167500.0 │
│ plotly    │              61 │      162500.0 │
│ mongo     │             265 │      162250.0 │
│ centos    │              31 │      159350.0 │
│ fastapi   │             204 │      157500.0 │
│ mxnet     │               5 │      157500.0 │
│ drupal    │               9 │      156000.0 │
│ vue       │              71 │      156000.0 │
│ bitbucket │             478 │      155000.0 │
│ django    │             265 │      155000.0 │
│ trello    │              36 │      155000.0 │
└───────────┴─────────────────┴───────────────┘

*/