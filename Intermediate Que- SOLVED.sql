-- 10 Intermediate Queries with actual business applications
-- This uses basic CTE's, WINDOW functions, 

-- Q1. What is the average experience points of data_labelers who worked on successful projects in the NLP domain?
-- Solution1
SELECT AVG(exp_points), COUNT(d.contributor_id)
FROM data_labelers d
WHERE d.contributor_id 
	IN 
	(SELECT p.contributor1_id
	FROM projects p
	JOIN domains d ON p.required_domain = d.domain_id
	WHERE p.status_id = 1 AND d.domain_name = 'NLP'
	UNION
	SELECT p.contributor2_id
	FROM projects p
	JOIN domains d ON p.required_domain = d.domain_id
	WHERE p.status_id = 1 AND d.domain_name = 'NLP'
	UNION
	SELECT p.contributor3_id
	FROM projects p
	JOIN domains d ON p.required_domain = d.domain_id
	WHERE p.status_id = 1 AND d.domain_name = 'NLP'
);
-- Solution2: Better & No redundant code
SELECT AVG(dl2.exp_points), COUNT(dl2.contributor_id)
FROM (
	SELECT DISTINCT dl.contributor_id
	FROM projects p 
	JOIN data_labelers dl 
		ON dl.contributor_id IN (p.contributor1_id, p.contributor2_id, p.contributor3_id)
	JOIN domains d 
		ON p.required_domain = d.domain_id
	JOIN project_status ps 
		ON p.status_id = ps.status_id
	WHERE ps.status_name = 'successful' AND d.domain_name = 'NLP'
) as uniq
JOIN data_labelers dl2
	ON uniq.contributor_id = dl2.contributor_id
;

-- Q2. Which country provides the highest number of contributors for computer vision projects, and how many projects were completed successfully?
-- Solution

WITH top_country AS (
	SELECT dl.country, COUNT(dl.contributor_id) AS count_dl 
    FROM data_labelers dl
    JOIN domains d ON d.domain_id IN (dl.domain_id1, dl.domain_id2, dl.domain_id3)
    WHERE d.domain_name = 'computer vision'
    GROUP BY dl.country 
    ORDER BY count_dl DESC Limit 1
    ) 
    , top_country_contributors AS (
	SELECT dl.contributor_id
    FROM data_labelers dl
    JOIN domains d ON d.domain_id IN (dl.domain_id1, dl.domain_id2, dl.domain_id3)
    JOIN top_country tc ON tc.country = dl.country
    WHERE d.domain_name = 'computer vision'
    )
    , successful_projects AS(
    SELECT COUNT(DISTINCT project_id) as successful_cv_projects
	FROM projects p
    JOIN domains d ON d.domain_id = p.required_domain
    JOIN project_status ps ON p.status_id = ps.status_id
    JOIN top_country_contributors tcc ON tcc.contributor_id IN (p.contributor1_id, p.contributor2_id, p.contributor3_id)
    WHERE ps.status_name = 'successful' AND d.domain_name = 'computer vision'
   )
    SELECT tc.country, tc.count_dl, sp.successful_cv_projects
    FROM top_country tc
    CROSS JOIN successful_projects sp;

	
-- Q3. List top 5 clients (by client_id and name) who have the highest number of successful projects completed in 2025.
-- Solution

SELECT p.client_id, c.name, COUNT(DISTINCT p.project_id) AS project_count
FROM projects p
JOIN clients c ON p.client_id = c.client_id
JOIN project_status ps ON p.status_id = ps.status_id
WHERE YEAR(p.end_date) = 2025 AND ps.status_name = 'successful'
GROUP BY p.client_id
ORDER BY project_count DESC
LIMIT 5;

-- Q4. For each domain, what is the project success rate (percentage of successful projects out of total projects within that domain)?
-- Solution 1:
WITH success_metrics AS (
	SELECT d.domain_name, ps.status_name, COUNT(DISTINCT p.project_id) AS project_count
    FROM projects p
    JOIN domains d ON d.domain_id = p.required_domain
    JOIN project_status ps ON p.status_id = ps.status_id
    GROUP BY d.domain_name, ps.status_name
    ),
    total_projects AS (
    SELECT sm.domain_name, SUM(sm.project_count) AS project_count
    FROM success_metrics sm
    GROUP BY sm.domain_name
    )    
SELECT sm.domain_name, sm.status_name, 
	sm.project_count AS successful_count, 
	tp.project_count AS total_project_count, 
	(sm.project_count / tp.project_count * 100) AS success_percentage 
FROM success_metrics sm
JOIN total_projects tp ON sm.domain_name = tp.domain_name
WHERE sm.status_name = 'successful';
    
-- Solution 2:
SELECT d.domain_name,
	COUNT(*) AS total_projects,
    SUM(CASE WHEN ps.status_name = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
    ROUND(SUM(CASE WHEN ps.status_name = 'successful' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS success_percentage
    FROM projects p
    JOIN domains d ON d.domain_id = p.required_domain
    JOIN project_status ps ON p.status_id = ps.status_id
    GROUP BY d.domain_name;
    
-- Q5. Identify contributors who worked on more than 10 projects starting and ending in 2025, and report their average project success rate.
-- Solution
SELECT dl.contributor_id, dl.name, 
	COUNT(*) AS project_count, 
	ROUND(SUM(CASE WHEN ps.status_name = 'successful' THEN 1 ELSE 0 END) / COUNT(*) * 100) AS project_success_rate
FROM projects p
JOIN data_labelers dl ON dl.contributor_id IN (p.contributor1_id, p.contributor2_id, p.contributor3_id)
JOIN project_status ps ON ps.status_id = p.status_id
WHERE YEAR(start_date) = 2025 AND YEAR(end_date) = 2025
GROUP BY dl.contributor_id, dl.name
HAVING COUNT(p.project_id) > 10
ORDER BY project_success_rate DESC;

-- Q6. Show the distribution of project status (successful, failed, non conclusive) for each client_type_name.
-- Solution

WITH status_distribution AS (
	SELECT ct.client_type_name, ps.status_name, COUNT(*) AS count_status_projects
	FROM projects p
	JOIN project_status ps ON p.status_id = ps.status_id
	JOIN clients c ON c.client_id = p.client_id
	JOIN client_types ct ON c.client_type_id = ct.client_type_id
	GROUP BY  ct.client_type_name, ps.status_name
	ORDER BY client_type_name
)
SELECT sd.client_type_name, sd.status_name, sd.count_status_projects, 
	ROUND(sd.count_status_projects / SUM(sd.count_status_projects) OVER(PARTITION BY sd.client_type_name) * 100, 2) AS status_rate
FROM status_distribution sd;

-- Q7. Which contributors have participated in projects across three different domains, and what’s the average duration of their projects?
-- Solution

SELECT dl.contributor_id, dl.name,
	COUNT(DISTINCT p.required_domain) AS domain_count, 
	AVG(DATEDIFF(p.end_date, p.start_date)) AS avg_project_days
FROM data_labelers dl
JOIN projects p ON dl.contributor_id IN (p.contributor1_id, p.contributor2_id, p.contributor3_id)
GROUP BY dl.contributor_id
HAVING domain_count>=3
ORDER BY avg_project_days;

-- Q8. For each non-profit client, how many projects started on or after July 1, 2025, how many were successful, and what were the successful one's domains?
-- Solution

SELECT c.name, c.client_id,
	COUNT(DISTINCT p.project_id) AS count_projects, 
	SUM(CASE WHEN ps.status_name = 'successful' THEN 1 ELSE 0 END) AS count_successful,
	GROUP_CONCAT(DISTINCT CASE WHEN ps.status_name = 'successful' THEN d.domain_name END ORDER BY d.domain_name SEPARATOR ', ') AS domains_used
FROM clients c
JOIN client_types ct USING(client_type_id)
JOIN projects p USING(client_id)
JOIN project_status ps USING(status_id)
JOIN domains d ON d.domain_id = p.required_domain
WHERE ct.client_type_name = 'non-profit'
	AND p.start_date >= '2025-07-01'
GROUP BY c.client_id, c.name
ORDER BY count_successful DESC;
    
-- Q9. What is the monthly trend of new projects started, grouped by domain, in 2025?
-- Solution 

SELECT YEAR(p.start_date) AS report_year, MONTH(p.start_date) AS report_month, 
	MONTHNAME(p.start_date) AS month_name, d.domain_name, COUNT(*) AS count_of_projects_started
FROM projects p
JOIN domains d ON p.required_domain = d.domain_id
WHERE YEAR(p.start_date) = 2025
GROUP BY report_year, report_month, month_name, d.domain_name
ORDER BY report_month, d.domain_name;

-- Q10. Among projects ending in 2025, which are the top three domains in terms of least average project duration, and how many contributors participated per domain?
-- Solution 

SELECT d.domain_name, 
	AVG(DATEDIFF(p.end_date, p.start_date)) AS avg_project_time, 
	COUNT(DISTINCT dl.contributor_id) count_contributors 
FROM projects p
JOIN domains d ON p.required_domain = d.domain_id
JOIN data_labelers dl ON dl.contributor_id IN (p.contributor1_id, p.contributor2_id, p.contributor3_id)
WHERE YEAR(p.end_date) = 2025
GROUP BY d.domain_name
ORDER BY avg_project_time
LIMIT 3;