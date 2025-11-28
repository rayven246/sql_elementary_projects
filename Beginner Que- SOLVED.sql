-- 10 Beginner level SQL Queries for data_labeling_projects DB with solutions

-- Q1. List the names and countries of all data_labelers who have more than 75 experience points in decending order of experience points.

SELECT name, country, exp_points
FROM data_labelers
WHERE exp_points > 75
ORDER BY exp_points DESC;


-- Q2. Find all projects that started in 2025 and display their project_id, start_date, and status.

-- Solution 1: Using Outer Join & WHERE Clause
SELECT project_id, start_date, status_name
FROM projects p
LEFT JOIN project_status ps 
		USING (status_id)
WHERE YEAR(start_date) = 2025;

-- Solution 2: Using HAVING Clause
SELECT project_id, start_date, status_name
FROM projects p
LEFT JOIN project_status ps 
		USING (status_id)
HAVING YEAR(start_date) = 2025;



-- Q3. Retrieve the total number of projects that have status_id = 1 (successful).

SELECT COUNT(project_id) as successful_projects
FROM projects
WHERE status_id = 1;


-- Q4. List the names and id's of all clients who are classified as ‘non-profit’ in the client_types table.

SELECT name, c.client_id, ct.client_type_name AS client_type
FROM clients c
JOIN client_types ct ON c.client_type_id = ct.client_type_id
WHERE ct.client_type_name = 'non-profit';


-- Q5. Get a count of data_labelers grouped by country.

SELECT country, COUNT(contributor_id) AS total_contributers
FROM data_labelers
GROUP BY country;

-- Q6. Display the names and exp_points of the top 5 most experienced data_labelers.

SELECT name, exp_points 
FROM data_labelers
ORDER BY exp_points DESC LIMIT 5;

-- Q7. Show all project_id values with required_domain = 3, along with their client_id and start_date is after 2023.

SELECT project_id, required_domain, client_id, start_date
FROM projects
WHERE required_domain = 3 AND start_date > '2023-12-31';

-- Q8. Find the name and domain specializations (as domain_id1, domain_id2, domain_id3) for all data_labelers who are from India.

SELECT name, domain_id1, domain_id2, domain_id3
FROM data_labelers
WHERE country = 'India';

-- Q9. For each client_type_name, show how many clients belong to that type using a join between clients and client_types.

SELECT client_type_name, client_type_id, COUNT(client_id)
FROM clients
LEFT JOIN client_types
	USING (client_type_id)
GROUP BY client_type_id;