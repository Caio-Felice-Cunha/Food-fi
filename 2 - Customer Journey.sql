########## Customer Journey ##########
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
SELECT
	customer_id,
	plan_id,  
    plan_name,
    start_date,  
    price
FROM
	subscriptions
		JOIN
	plans USING (plan_id)
WHERE customer_id IN (1,2,11, 13, 15, 16, 18, 19);

/*Through a generalized analysis, we have that the majority of customers, so far, have liked the service, as there were only two cancellations ('churn'), as shown below: */
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id IN (1,2,11, 13, 15, 16, 18, 19) AND price is null;

-- Customer_id = 1
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 1;
-- Started at 2020-08-01 through the trial plan, went to basic monthly at 2020-08-08
-- He most likely liked the content, but still doesn't want to commit to a higher value.
-- It's also possible that he forgot to cancel the plan at the end of the trial.

-- Customer_id = 2
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 2;
-- Started at 2020-09-20 through the trial plan, went to pro annual at 2020-09-27
-- In this case, compared to the previous one, we see that the consumer really liked the service, as he went from trial to pro annual, demonstrating that he wants to enjoy the service in the long term.

-- Customer_id = 11
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 11;
-- Started at 2020-11-19 through the trial plan, went to churn at 2020-11-26
-- This one really didn't like the service, because he canceled it as soon as the trial ended.
-- It is also possible that he have very low income and do not have the amount to pay (very unlikely)

-- Customer_id = 13
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 13;
-- Started at 2020-12-15 through the trial plan, went to basic monthly at 2020-12-22, and then to pro monthly at 2021-03-29
-- In this case, we have something new, as the customer changed plans twice, first starting with the trial and as soon as that period ended, he went to basic monthly, indicating that he liked the service, but it could still be that he had forgotten to cancel the subscription.
-- However, we have proof that he liked it with a view to going pro monthly, seeking a more complete subscription. The question that remains is: "will he go to the pro annual?"


-- Customer_id = 15
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 15;
-- Started at 2020-03-17 through the trial plan, went to pro monthly at 2020-03-24
-- In this case, he canceled the service right after his monthly pro period ended. so we have a consumer who, at first, liked the service, but later didn't want it anymore. 
-- Why? Little content? Repetitive content? Financial problems? Has another competitor appeared in the market?


-- Customer_id = 16
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 16;
-- Started at 2020-05-31 through the trial plan, went to basic monthly at 2020-06-07
-- This case is similar to consumer 13 and 2, who liked the product and gradually went to the annual pro plan, that is, they liked the service a lot.


-- Customer_id = 18
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 18;
-- Started at 2020-07-06 through the trial plan, went to pro monthly at 2020-07-13
-- This consumer has also shown interest in the service, and the next step is to try to make it evolve into the annual service



-- Customer_id = 19
SELECT customer_id,	plan_name,start_date, price FROM subscriptions JOIN plans USING (plan_id) WHERE customer_id = 19;
-- Started at 2020-06-22 through the trial plan, went to pro monthly at 2020-06-29
-- This consumer followed a path similar to that of number 13, demonstrating that he liked the service.