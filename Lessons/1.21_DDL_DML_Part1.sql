/*

Run this in the terminaland it will work just as running the query code in the SQL editor.
The output will be displayed in the terminal.

    .read Lessons/1.21_DDL_DML_Part1.sql

*/

-- CREATE DATABASE jobs_mart;

SHOW DATABASES;

USE data_jobs;

DROP DATABASE IF EXISTS jobs_mart;

CREATE DATABASE IF NOT EXISTS jobs_mart;

SELECT * 
FROM information_schema.schemata
;


USE jobs_mart
;

CREATE SCHEMA IF NOT EXISTS jobs_mart.staging
;


-- DROP SCHEMA IF EXISTS jobs_mart.staging;


CREATE TABLE staging.preferred_roles(
    role_id INT PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL
)
;


SELECT * 
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart'
;


DROP TABLE IF EXISTS main.preferred_roles;

INSERT INTO staging.preferred_roles(role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer')
;

SELECT *
FROM staging.preferred_roles
;

INSERT INTO staging.preferred_roles(role_id, role_name)
VALUES
    (3, 'Data Scientist')
;


ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_roles BOOLEAN
;

/*

ALTER TABLE staging.preferred_roles
DROP COLUMN preferred_roles
;

*/


UPDATE staging.preferred_roles
SET preferred_roles = TRUE
WHERE
    role_id = 1 OR
    role_id = 2
;

UPDATE staging.preferred_roles
SET preferred_roles = FALSE
WHERE
    role_id = 3
;

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles
;


ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_roles TO priority_level
;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_level TYPE INTEGER
;

UPDATE staging.priority_roles
SET priority_level = 3
WHERE role_id = 3
;



SELECT *
FROM staging.priority_roles
;

