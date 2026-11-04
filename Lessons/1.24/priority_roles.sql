CREATE OR REPLACE TABLE staging.priority_roles (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(255),
    priority_level INT 
)
;

INSERT INTO staging.priority_roles (role_id, role_name, priority_level)
VALUES
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3)
;

SELECT *
FROM staging.priority_roles
;