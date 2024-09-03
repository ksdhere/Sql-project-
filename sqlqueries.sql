select * FROM sqlproject.bank_churn;

ALTER TABLE bank_churn
RENAME TO customerinfo;
----- Q2 Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
SELECT customerid, surname, estimatedsalary
FROM customerinfo
WHERE EXTRACT(QUARTER FROM bank_doj) = 4
ORDER BY estimatedsalary DESC
LIMIT 5;

----- Q3 Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT AVG(NumOfProducts) AS avg_products_with_credit_card
FROM bank_churn
WHERE HasCrCard = 1; 

----- Q5 Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT Exited,
       AVG(CreditScore) AS avg_credit_score
FROM bank_churn
GROUP BY Exited;

----- Q6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
WITH ActiveAccounts AS (
    SELECT CustomerId,COUNT(*) AS ActiveAccounts
    FROM Bank_Churn
    WHERE IsActiveMember = 1
    GROUP BY customerId
)
SELECT CASE WHEN c.GenderID = 1 THEN 'Male' ELSE 'Female' END AS Gender,
    COUNT(aa.CustomerId) AS ActiveAccounts, AVG(c.EstimatedSalary) AS AvgSalary
FROM CustomerInfo c
LEFT JOIN ActiveAccounts aa ON c.CustomerId = aa.CustomerId
GROUP BY Gender
ORDER BY AvgSalary DESC;

----- Q7 Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
WITH credit_score_segments AS (
  SELECT
    customerid, isactivemember,
   CASE
      WHEN creditscore between 800 and 850 THEN 'Excellent'
      WHEN creditscore between 740 and 799 THEN 'Very Good'
      WHEN creditscore between 670 and 739 THEN 'Good'
      WHEN creditscore between 580 and 669 THEN 'Fair'
      ELSE 'Poor'
    END AS credit_score_segment
  FROM bank_churn
)
SELECT
  credit_score_segment,
  AVG(CASE WHEN isactivemember = 0 THEN 0 ELSE 1 END) AS exit_rate
FROM credit_score_segments
GROUP BY credit_score_segment
ORDER BY exit_rate DESC
LIMIT 1;

----- Q8 Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT 
    ci.REGION, COUNT(ci.customerId) AS active_customers
FROM
    customerinfo ci
join bank_churn bc
on  ci.CustomerId = bc.CustomerId 
WHERE
    bc.Tenure > 5
GROUP BY REGION
ORDER BY COUNT(ci.customerId) DESC
LIMIT 1;

----- Q15 Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
WITH geographic_avg_salary AS (
SELECT REGION,
    CASE
        WHEN GenderID = 1 THEN 'Male'
        ELSE 'Female'
    END AS gender,
    AVG(EstimatedSalary) AS avg_salary
FROM
    customerinfo ci
group by REGION,gender
order BY  AVG(EstimatedSalary)
)

SELECT *, RANK() OVER(PARTITION BY REGION ORDER BY avg_salary DESC) AS `rank`
FROM geographic_avg_salary;

----- Q16 Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT 
    CASE
        WHEN c.Age BETWEEN 18 AND 30 THEN 'Adult'
        WHEN c.Age BETWEEN 31 AND 50 THEN 'Middle-Aged'
        ELSE 'Old-Aged'
    END AS age_brackets,
    AVG(b.Tenure) AS avg_tenure
FROM
    customerinfo c
        JOIN
    bank_churn b ON c.CustomerId = b.CustomerId
WHERE
    b.Exited = 1
GROUP BY age_brackets
ORDER BY age_brackets;

----- Q20 According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.
WITH info AS (
SELECT 
    CASE
        WHEN c.Age BETWEEN 18 AND 30 THEN 'Adult'
        WHEN c.Age BETWEEN 31 AND 50 THEN 'Middle-Aged'
        ELSE 'Old-Aged'
    END AS age_brackets,
    count(c.CustomerId) AS HasCreditCard
FROM customerinfo c JOIN bank_churn b ON c.CustomerId=b.CustomerId
WHERE b.HasCrCard = 1
GROUP BY age_brackets)
SELECT *
FROM info
WHERE HasCreditCard < (SELECT AVG(HasCreditCard) FROM info);

----- Q21 Rank the Locations as per the number of people who have churned the bank and average balance of the customers.
SELECT c.REGION, COUNT(b.CustomerId) AS num_exited_people, AVG(b.CustomerId) AS avg_balance
FROM bank_churn b
JOIN customerinfo c ON b.CustomerId = c.CustomerId
WHERE b.Exited = 1
GROUP BY c.REGION
ORDER BY Count(b.CustomerId)desc;

----- Q23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
SELECT CustomerId,CreditScore,Tenure,Balance,NumOfProducts,HasCrCard,IsActiveMember,
    CASE
        WHEN Exited = 0 THEN 'Retain'
        ELSE 'Exit'
    END AS ExitCategory
FROM
    bank_churn;

----- Q25 Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
SELECT 
    c.CustomerId,
    c.Surname,
    CASE
        WHEN b.IsActiveMember = 1 THEN 'Active'
        ELSE 'InActive'
    END AS activity_status
FROM
    customerinfo c
        JOIN
    bank_churn b ON c.CustomerId = b.CustomerId
WHERE
    c.Surname REGEXP 'on$'
ORDER BY c.Surname;

----- SAQ9 Utilize SQL queries to segment customers based on demographics and account details.

SELECT 
    REGION,
    CASE
        WHEN EstimatedSalary < 50000 THEN 'Low'
        WHEN EstimatedSalary < 100000 THEN 'Medium'
        ELSE 'High'
    END AS income_segment,
    CASE
        WHEN GenderID = 1 THEN 'Male'
        ELSE 'Female'
    END AS gender, Age,
    COUNT(CustomerId) AS number_of_customers
FROM customerinfo
GROUP BY income_segment , REGION ,gender,age
ORDER BY REGION;

----- Q14 Renaming
ALTER TABLE bank_churn
RENAME COLUMN HasCrCard TO Has_creditcard;











