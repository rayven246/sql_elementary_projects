-- Run this command in your SQL client to find out the directory where MySQL allows import/export operations. 
-- SHOW VARIABLES LIKE 'secure_file_priv';
-- Place your CSV files in this specific directory and run the LOAD DATA INFILE command using the full path.
-- Please change the address to each of the file as per the local file upload server for your system


-- Domains
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/domains.csv'
INTO TABLE domains
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(domain_id, domain_name);

-- Data Labelers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data_labelers.csv'
INTO TABLE data_labelers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(contributor_id, name, age, country, sex, exp_points, domain_id1, domain_id2, domain_id3);

-- Client Types
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/client_types.csv'
INTO TABLE client_types
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(client_type_id, client_type_name);

-- Clients
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clients.csv'
INTO TABLE clients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(client_id, name, client_type_id);

-- Project Status
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/project_status.csv'
INTO TABLE project_status
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(status_id, status_name);

-- Projects
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/projects.csv'
INTO TABLE projects
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(project_id, required_domain, contributor1_id, contributor2_id, contributor3_id, client_id, start_date, end_date, status_id);
