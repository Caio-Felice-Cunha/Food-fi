########## Data Analysis Questions ##########
-- 1) How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT customer_id) AS TotalClients
FROM
	subscriptions;
/*
############ Answer ############
# TotalClients
1000
############ Answer ############
*/

-- 2) What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT
    DATE_FORMAT(subscriptions.start_date, '%Y-%m') AS YearMonth,
    COUNT(*) AS TotalTrial
FROM
    subscriptions
JOIN
    plans USING(plan_id)
WHERE
    plans.plan_name = 'trial'
GROUP BY
    YearMonth
ORDER BY
    YearMonth DESC;

/*
############ Answer ############
# YearMonth, TotalTrial
2020-12, 84
2020-11, 75
2020-10, 79
2020-09, 87
2020-08, 88
2020-07, 89
2020-06, 79
2020-05, 88
2020-04, 81
2020-03, 94
2020-02, 68
2020-01, 88
############ Answer ############
*/

-- 3) What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	plans.plan_name AS Plan,
    COUNT(plans.plan_name) Total
FROM
	subscriptions
		JOIN
	plans USING(plan_id)
WHERE
	YEAR(start_date) > 2020
GROUP BY
	plans.plan_name,plans.plan_id
ORDER BY
	plans.plan_id;

/*
############ Answer ############
# Plan, Total
basic monthly, 8
pro monthly, 60
pro annual, 63
churn, 71
############ Answer ############
*/

-- 4) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
    COUNT(DISTINCT customer_id) Total,
    COUNT(CASE
        WHEN plans.plan_name = 'churn' THEN 1
    END) Churn,
    CONCAT(ROUND(COUNT(CASE
                        WHEN plans.plan_name = 'churn' THEN 1
                    END) / COUNT(DISTINCT customer_id) * 100,
                    1),
            '%') AS PercOfChurn
FROM
    subscriptions
        JOIN
    plans USING (plan_id);

/*
############ Answer ############
# Total, Churn, PercOfChurn
1000, 307, 30.7%
############ Answer ############
*/

-- 5) How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- I (Caio) want to make it a little more interesting. I want to know the churn in comparison to the end of the trial date. 
-- The trial date ends 7 days after it started. 
-- So, I considered the therm "straight after their initial free trial" as the customer who churned after 15 days of the end od the 7 days trial.
-- In this query you can decide what period do you want, just change the statement "AND DATEDIFF(start_date, EndDateTrial) <= 15".

WITH ChurnTableCTE AS (
	SELECT 
		customer_id,
		CASE
			WHEN plan_name = 'churn' THEN start_date 
				END AS start_date,
		plan_name,
		CASE
			WHEN plan_name = 'trial' THEN DATE_ADD(start_date, INTERVAL 7 DAY)
				END AS EndTrial,
		LAG(CASE
			WHEN plan_name = 'trial' THEN DATE_ADD(start_date, INTERVAL 7 DAY)
				END) OVER (
					PARTITION BY customer_id
					ORDER BY customer_id) AS EndDateTrial
	FROM
		subscriptions
	JOIN
		plans USING (plan_id)
	WHERE
		plan_name IN ('trial', 'churn')
	ORDER BY
		customer_id)
SELECT 
	(select count( DISTINCT customer_id) from subscriptions) AS AllCustomers,
	COUNT( DISTINCT customer_id) AS CustomerChurn15DaysAfterTrial,
	CONCAT(ROUND(COUNT( DISTINCT customer_id)/ 
		 (SELECT COUNT( DISTINCT customer_id) from subscriptions) * 100,2),'%') AS Perc_Churn    
FROM 
	ChurnTableCTE
WHERE
	start_date IS NOT NULL
    AND DATEDIFF(start_date, EndDateTrial) <= 15
ORDER BY
	customer_id;

/*
############ Answer ############
# AllCustomers, CustomerChurn15DaysAfterTrial, Perc_Churn
1000, 107, 9.35%
############ Answer ############
*/

-- 6) What is the number and percentage of customer plans after their initial free trial?
WITH PlanAfterCTE AS (
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id,1) 
			OVER(
				PARTITION BY customer_id
				ORDER BY plan_id) AS PlanAfter
	FROM
		subscriptions)
SELECT
	CASE
		WHEN PlanAfter = 1	THEN 'basic monthly'
        WHEN PlanAfter = 2	THEN 'pro monthly'
        WHEN PlanAfter = 3	THEN 'pro annual'
        WHEN PlanAfter = 4	THEN 'churn'
        END AS PlanName,
	COUNT(PlanAfter) AS Total,
    CONCAT(ROUND(COUNT(PlanAfter)
		/ (SELECT 
				COUNT(DISTINCT customer_id) 
			FROM 
				subscriptions) *100, 2), '%') AS Perc
FROM
	PlanAfterCTE
WHERE
	PlanAfter IS NOT NULL
		AND plan_id = 0
GROUP BY
	PlanName
ORDER BY
	plan_id;

/*
############ Answer ############
# PlanName, COUNT(PlanAfter), Perc
basic monthly, 546, 54.60%
pro monthly, 325, 32.50%
pro annual, 37, 3.70%
churn, 92, 9.20%
############ Answer ############
*/

-- 7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- To retrieve next plan's start date located in the next row based on current row
WITH PlanAfter AS (
    SELECT 
        customer_id, 
        plan_id, 
        start_date,
        LEAD(start_date, 1) 
			OVER (
				PARTITION BY customer_id 
				ORDER BY start_date) AS DateAfter
    FROM 
		subscriptions
    WHERE 
		start_date <= '2020-12-31'
),
CustomerBRKD AS (
    SELECT 
		plan_id, 
		COUNT(DISTINCT customer_id) AS TotalCustomers
    FROM 
		PlanAfter
    WHERE 
		(DateAfter IS NOT NULL 
			AND (start_date < '2020-12-31' 
				AND DateAfter > '2020-12-31'))
				OR (DateAfter IS NULL 
						AND start_date < '2020-12-31')
    GROUP BY 
		plan_id
)
SELECT 
	plan_id, 
    TotalCustomers, 
    CONCAT(
		ROUND(100 * TotalCustomers / 
			(SELECT 
				COUNT(DISTINCT customer_id) 
			FROM 
				foodie_fi.subscriptions
				), 1),'%') AS Perc
FROM 
	CustomerBRKD
GROUP BY 
	plan_id, 
    TotalCustomers
ORDER BY 
	plan_id;

/*
############ Answer ############
# plan_id, TotalCustomers, Perc
0, 19, 1.9%
1, 224, 22.4%
2, 326, 32.6%
3, 195, 19.5%
4, 235, 23.5%
############ Answer ############
*/

-- 8) How many customers have upgraded to an annual plan in 2020?
WITH PrevPlan AS (
	SELECT
		customer_id,
		plan_id,
		LAG(plan_id) 
			OVER(
				PARTITION BY customer_id
				ORDER BY plan_id) AS PreviousPlan,
		start_date
	FROM
		subscriptions
	WHERE
		start_date >= 01-01-2020 OR start_date <= 31-12-2020)
SELECT
	COUNT(*) AS customer
FROM
	PrevPlan
WHERE
	plan_id = 3 and PreviousPlan <> 3
ORDER BY
	customer_id;


/*
############ Answer ############
# customer
258
############ Answer ############
*/

-- 9) How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH TrialTable AS (
    SELECT 
        customer_id, 
        start_date AS DateTrial
    FROM 
        subscriptions
    WHERE 
        plan_id = 0
),
AnnualTable AS (
    SELECT 
        customer_id, 
        start_date AS DateAnnual
    FROM 
        subscriptions
    WHERE 
        plan_id = 3
)
SELECT 
    ROUND(
        AVG(DATEDIFF(DateAnnual, DateTrial)), 0
    ) AS UpgAvgDays
FROM 
    TrialTable
JOIN 
    AnnualTable USING(customer_id);

/*
############ Answer ############
# UpgAvgDays
105
############ Answer ############
*/

-- 10) Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- Filter results to customers at trial plan = 0
WITH TrialTableCTE AS (
	SELECT 
		customer_id, 
		start_date AS TrialDate
	FROM 
		subscriptions
	WHERE 
		plan_id = 0
),
AnnualTableCTE AS (
	SELECT 
		customer_id, 
		start_date AS AnnualDate
	FROM 
		subscriptions
	WHERE 
		plan_id = 3
),
PeriodsTableCTE AS (
	SELECT 
		FLOOR(
			DATEDIFF(AnnualTableCTE.AnnualDate, TrialTableCTE.TrialDate) / 30) + 1 AS DaysForUpg
	FROM 
		TrialTableCTE 
			JOIN 
		AnnualTableCTE USING(customer_id)
)
SELECT 
	CONCAT((DaysForUpg - 1) * 30, ' - ', DaysForUpg * 30, ' days') AS breakdown, 
	COUNT(*) AS customers
FROM 
	PeriodsTableCTE
GROUP BY 
	DaysForUpg
ORDER BY 
	DaysForUpg;



/*
############ Answer ############
# breakdown, customers
0 - 30 days, 48
30 - 60 days, 25
60 - 90 days, 33
90 - 120 days, 35
120 - 150 days, 43
150 - 180 days, 35
180 - 210 days, 27
210 - 240 days, 4
240 - 270 days, 5
270 - 300 days, 1
300 - 330 days, 1
330 - 360 days, 1
############ Answer ############
*/

-- 11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH PlanLeadCTE AS (
	SELECT
		customer_id,
		plan_id,
		start_date,
		LEAD(plan_id, 1) 
			OVER(
				PARTITION BY customer_id 
				ORDER BY plan_id) as LeadPlan
	FROM
		foodie_fi.subscriptions
)

SELECT
	COUNT(*) AS TotalDowngraded
FROM
	PlanLeadCTE
WHERE
	start_date <= '2020-12-31'
		AND plan_id = 2
		AND LeadPlan = 1;

/*
############ Answer ############
# TotalDowngraded
0
############ Answer ############
*/