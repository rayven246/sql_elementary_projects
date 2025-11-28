CREATE DATABASE IF NOT EXISTS data_labeling_projects;
USE data_labeling_projects;

CREATE TABLE domains (
    domain_id INT PRIMARY KEY,
    domain_name VARCHAR(100) NOT NULL
);

CREATE TABLE data_labelers (
    contributor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    country VARCHAR(50),
    sex VARCHAR(10),
    exp_points INT,
    domain_id1 INT,
    domain_id2 INT,
    domain_id3 INT,
    FOREIGN KEY (domain_id1) REFERENCES domains(domain_id),
    FOREIGN KEY (domain_id2) REFERENCES domains(domain_id),
    FOREIGN KEY (domain_id3) REFERENCES domains(domain_id)
);

CREATE TABLE client_types (
    client_type_id INT PRIMARY KEY,
    client_type_name VARCHAR(50) NOT NULL
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    client_type_id INT,
    FOREIGN KEY (client_type_id) REFERENCES client_types(client_type_id)
);

CREATE TABLE project_status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    required_domain INT,
    contributor1_id INT,
    contributor2_id INT,
    contributor3_id INT,
    client_id INT,
    start_date DATE,
    end_date DATE,
    status_id INT,
    FOREIGN KEY (required_domain) REFERENCES domains(domain_id),
    FOREIGN KEY (contributor1_id) REFERENCES data_labelers(contributor_id),
    FOREIGN KEY (contributor2_id) REFERENCES data_labelers(contributor_id),
    FOREIGN KEY (contributor3_id) REFERENCES data_labelers(contributor_id),
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (status_id) REFERENCES project_status(status_id)
);
