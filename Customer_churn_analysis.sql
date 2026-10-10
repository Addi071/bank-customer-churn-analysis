select * from customer;


-- Adding credit score band column 
ALTER TABLE customer
ADD COLUMN credit_score_band VARCHAR(20);

UPDATE customer
SET credit_score_band = CASE
		WHEN credit_score < 600 THEN '<600'
		WHEN credit_score >= 600 AND credit_score < 700 THEN '600–699'
    	WHEN credit_score >= 700 AND credit_score < 800 THEN '700–799'
    	WHEN credit_score >= 800 THEN '800+'
    	ELSE 'Unknown'
	END;

-- Adding balance band column 
ALTER TABLE customer
ADD COLUMN balance_band VARCHAR(20);

UPDATE customer 
SET balance_band = CASE
		WHEN balance = 0 THEN '0'
		WHEN balance >= 1 AND balance < 50000 THEN '1–50k'
    	WHEN balance >= 50000 AND balance < 100000 THEN '50k–100k'
    	WHEN balance >= 100000 AND balance < 150000 THEN '100k–150k'
    	WHEN balance >= 150000 AND balance < 200000 THEN '150k–200k'
    	WHEN balance >= 200000 THEN '200k+'
    	ELSE 'Unknown'
	END;

-- Adding salary band column 
ALTER TABLE customer
ADD COLUMN salary_band VARCHAR(20);

UPDATE customer 
SET salary_band = CASE
		WHEN estimated_salary >= 1 AND estimated_salary < 50000 THEN '<50k'
    	WHEN estimated_salary >= 50000 AND estimated_salary < 100000 THEN '50k–100k'
    	WHEN estimated_salary >= 100000 AND estimated_salary < 150000 THEN '100k–150k'
    	WHEN estimated_salary >= 150000 AND estimated_salary < 200000 THEN '150k–200k'
    	WHEN estimated_salary >= 200000 THEN '200k+'
    	ELSE 'Unknown'
	END;


-- Basic KPI analysis

-- 1. What is the total number of customers?
SELECT 
	COUNT(customer_id) AS total_customers 
FROM
	customer ;

-- 2. How many customers have churned?
SELECT 
	COUNT(customer_id) AS no_of_churned_customers
FROM
	customer
WHERE
	churn = 1;

-- 3. What is the overall churn rate?
SELECT
	ROUND(AVG(churn)*100,2) AS churn_rate
FROM
	customer;

-- 4. What is the average credit score, balance and salary?
SELECT
	ROUND(AVG(credit_score),2) AS avg_credit_score,
	ROUND(AVG(balance)::numeric,2) AS avg_balance,
	ROUND(AVG(estimated_salary)::numeric,2) AS avg_salary
FROM 
	customer;

-- 5. What percentage of customers are active members?
SELECT
	ROUND(AVG(active_member)*100::numeric,2) AS active_member_percent
FROM
	customer;

-- Demographic analysis
-- 6. What is the churn rate by gender?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	gender
FROM
	customer
GROUP BY
	gender;

-- 7. What is the churn rate by age group?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	age_group
FROM
	customer
GROUP BY
	age_group;
	
-- 8. Which age group has the highest number of churned customers?
SELECT
	COUNT(churn) AS churn_customer_no,
	age_group
FROM
	customer
GROUP BY
	age_group
ORDER BY 
	COUNT(churn) DESC
LIMIT 1;

-- 9. Which country has the highest churn rate?
SELECT
	ROUND(AVG(churn)*100::numeric,2) AS churn_rate,
	country
FROM
	customer
GROUP BY
	country
ORDER BY 
	churn_rate DESC
LIMIT 1;

-- 10. How does customer distribution differ across countries?
SELECT
	country,
	COUNT(*) AS total_customers,
	ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER())::numeric, 2) AS percentage_of_total_base,
    ROUND((AVG(churn) * 100)::numeric, 2) AS country_churn_rate
FROM
	customer
GROUP BY
	country
ORDER BY
	total_customers DESC;

-- Product analysis
-- 11. What is the churn rate by number of products?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	products_number
FROM
	customer
GROUP BY
	products_number;
	
-- 12. Which product-count segment has the highest churn?
SELECT 
    products_number AS product_segment,
    COUNT(*) AS total_customers,
    ROUND((AVG(churn) * 100)::numeric, 2) AS churn_rate
FROM 
    customer
GROUP BY 
    products_number
ORDER BY 
    churn_rate DESC;

-- 13. Does having a credit card correlate with lower churn?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	credit_card
FROM
	customer
GROUP BY
	credit_card;
	
-- 14. What is the relationship between product count and customer activity?
SELECT 
	COUNT(products_number) AS customer_no,
	active_member,
	products_number
FROM
	customer
GROUP BY
	products_number,
	active_member
ORDER BY
	products_number ASC,
	active_member DESC;
	
-- Engagement analysis
-- 15. What is the churn rate for active vs inactive members?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	active_member
FROM
	customer
GROUP BY
	active_member;
	
-- 16. Which country has the highest churn among inactive customers?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	active_member,
	country
FROM
	customer
GROUP BY
	active_member,
	country
HAVING 
	active_member = 0
ORDER by
	churn_rate DESC;
	
-- 17. Which age group has the highest churn among inactive customers?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	active_member,
	age_group
FROM
	customer
GROUP BY
	age_group,
	active_member
HAVING 
	active_member = 0
ORDER by
	churn_rate DESC;
	
-- 18. What is the churn rate by ActiveMember × ProductsNumber?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	active_member,
	products_number
FROM
	customer
GROUP BY
	products_number,
	active_member

ORDER by
	products_number ASC;
	
-- Financial analysis
-- 19. What is the churn rate by credit-score band?
SELECT
	ROUND(AVG(churn)*100,2) AS churn_rate,
	credit_score_band
FROM
	customer
GROUP BY
	credit_score_band;

-- 20. What is the churn rate by balance band?
SELECT
	ROUND(AVG(churn)*100,2) AS churn_rate,
	balance_band
FROM
	customer
GROUP BY
	balance_band;
	
-- 21. What is the churn rate by salary band?
SELECT
	ROUND(AVG(churn)*100,2) AS churn_rate,
	salary_band
FROM
	customer
GROUP BY
	salary_band;
	
-- 22. How much total balance belongs to churned customers?
SELECT
	ROUND(SUM(balance)::numeric,2) as churned_balance
FROM 
	customer
WHERE
	churn = 1;
	
-- Advanced segmentation
-- 23. Which customer segments have both high churn rate and high balance?
SELECT 
	ROUND(AVG(churn)*100,2) AS churn_rate,
	country,
	active_member,
	age_group,
	ROUND(SUM(balance)::numeric,2) as churned_balance
FROM
	customer
GROUP BY
	country,
	age_group,
	active_member
ORDER BY
	churn_rate DESC,
	churned_balance DESC
LIMIT 3;

-- 24. What are the top 10 customer profiles/segments by churn rate?
SELECT 
	country,
	COUNT(*) AS customer,
	products_number,
	active_member,
	age_group,
	ROUND(AVG(churn)*100,2) AS churn_rate
FROM
	customer
GROUP BY
	country,
	age_group,
	active_member,
	products_number
ORDER BY
	churn_rate DESC
LIMIT 10;