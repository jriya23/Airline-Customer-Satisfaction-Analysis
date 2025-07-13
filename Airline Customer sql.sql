
-- Invistico Airline: Customer Satisfaction Analysis Project

-- Creating the database
Create Database flight;

use flight;

select * from invistico_airline;


-- Data Cleaning

-- Rename the column 'Arrival Delay in Minutes' to 'arrival_delay'
Alter Table invistico_airline
Change `Departure Delay in Minutes` departure_delay Int;

Alter Table invistico_airline
Change `Arrival Delay in Minutes` arrival_delay Int;

-- Disable safe update mode for the session
SET SQL_SAFE_UPDATES = 0;

-- Update 'satisfied' to 'Satisfied'
UPDATE invistico_airline
SET satisfaction = 'Satisfied'
WHERE satisfaction = 'satisfied';

-- Update 'dissatisfied' to 'Dissatisfied'
UPDATE invistico_airline
SET satisfaction = 'Dissatisfied'
WHERE satisfaction = 'dissatisfied';

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Customer Satisfaction Questions

-- Ques.1 Total customer 

select count(*) As total_cus from invistico_airline;

-- Ques.2 How many passengers are satisfied vs. dissatisfied overall?

With SatisfactionCount As(
select Satisfaction, 
Count(*) As count
From invistico_airline
Group by Satisfaction)

Select
Satisfaction,
count,
Round(100 * count/Sum(Count) Over(),2) As total_percent
From SatisfactionCount
Group by Satisfaction,
count;

-- Ques.3 Which customer type (Loyal or Disloyal) has the highest satisfaction rate? 

-- 🛠️ Rename column 'Customer Type' to 'customer_type' and set its type to VARCHAR(50)
ALTER TABLE invistico_airline
CHANGE `Customer Type` customer_type VARCHAR(50);

--  Calculate satisfaction rate by customer type
SELECT customer_type,
       Round(SUM(Case when Satisfaction = 'Satisfied' Then 1 Else 0 End) * 100.0 / COUNT(*),2) AS satisfaction_rate,
              Round(SUM(Case when Satisfaction = 'Dissatisfied' Then 1 Else 0 End) * 100.0 / COUNT(*),2) AS dissatisfaction_rate
FROM invistico_airline
GROUP BY customer_type;

-- Ques.4 Is there a difference in satisfaction between Business and Personal travel?

Alter Table invistico_airline
Change `Type of travel` travel_type VARCHAR(20);

-- 📊 Calculate the difference between Business and Personal travelers for each satisfaction level
Select Satisfaction, 
Sum(Case When travel_type = 'Business travel' Then 1 Else 0 End)  As business_traveler_count,
Sum(Case When travel_type = 'Personal Travel' Then 1 Else 0 End) As personal_traveler_count,
Sum(Case When travel_type = 'Business travel' Then 1 Else 0 End) - Sum(Case When travel_type = 'Personal Travel' Then 1 Else 0 End) 
As diff From invistico_airline
Group by Satisfaction;

-- Ques 5. Which class of travel (Business, Eco, Eco Plus) has the highest satisfaction?

Select Class, Round(Sum(Case When Satisfaction = 'Satisfied' Then 1 Else 0 End)*100,2) As satisfied
From invistico_airline
Group by Class Order by satisfied DESC;

-- Delay & Punctuality Questions 

-- Ques 6. Do longer arrival or departure delays lead to lower satisfaction?

With Delay As (
Select Satisfaction,
 Round(avg(arrival_delay_in_minutes),2) As avg_arrival_delay,
 Round(avg(departure_delay),2) As avg_departure_delay
 From  invistico_airline
 Group by Satisfaction)
 
 Select Satisfaction,
 avg_arrival_delay,
 avg_departure_delay
 From Delay
 Group by Satisfaction, avg_arrival_delay, avg_departure_delay;
 
 
 -- Ques.7 What is the average arrival and departure delay by travel class?
 
 With ClassDelay As (
 Select Class , 
 Round(avg(arrival_delay_in_minutes),2) As avg_arrival_delay,
 Round(avg(departure_delay),2) As avg_departure_delay
 From  invistico_airline
 Group by Class)
 
 Select Class , avg_arrival_delay, avg_departure_delay
 From ClassDelay;

 -- Service Quality Questions
 
--  Ques.8 Which in-flight service features are rated lowest by dissatisfied passengers?


WITH Dissatisfied AS (
  SELECT *
  FROM invistico_airline
  WHERE Satisfaction = 'Dissatisfied'
),

ServiceAverages AS (
  SELECT 'Seat comfort' AS service, ROUND(AVG(`Seat comfort`), 2) AS avg_rating FROM Dissatisfied
  UNION ALL
  SELECT 'Departure/Arrival time convenient', ROUND(AVG(`Departure/Arrival time convenient`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Food and drink', ROUND(AVG(`Food and drink`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Gate location', ROUND(AVG(`Gate location`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Inflight wifi service', ROUND(AVG(`Inflight wifi service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Inflight entertainment', ROUND(AVG(`Inflight entertainment`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Online support', ROUND(AVG(`Online support`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Ease of Online booking', ROUND(AVG(`Ease of Online booking`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'On-board service', ROUND(AVG(`On-board service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Leg room service', ROUND(AVG(`Leg room service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Baggage handling', ROUND(AVG(`Baggage handling`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Checkin service', ROUND(AVG(`Checkin service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Cleanliness', ROUND(AVG(`Cleanliness`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Online boarding', ROUND(AVG(`Online boarding`), 2) FROM Dissatisfied
)

SELECT * 
FROM ServiceAverages
ORDER BY avg_rating ASC
LIMIT 1;

-- Ques.9 What are the top 3 pain points for dissatisfied passengers?

WITH Dissatisfied AS (
  SELECT *
  FROM invistico_airline
  WHERE Satisfaction = 'dissatisfied'
),

ServiceAverages AS (
  SELECT 'Seat comfort' AS feature, ROUND(AVG(`Seat comfort`), 2) AS avg_rating FROM Dissatisfied
  UNION ALL
  SELECT 'Departure/Arrival time convenient', ROUND(AVG(`Departure/Arrival time convenient`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Food and drink', ROUND(AVG(`Food and drink`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Gate location', ROUND(AVG(`Gate location`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Inflight wifi service', ROUND(AVG(`Inflight wifi service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Inflight entertainment', ROUND(AVG(`Inflight entertainment`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Online support', ROUND(AVG(`Online support`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Ease of Online booking', ROUND(AVG(`Ease of Online booking`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'On-board service', ROUND(AVG(`On-board service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Leg room service', ROUND(AVG(`Leg room service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Baggage handling', ROUND(AVG(`Baggage handling`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Checkin service', ROUND(AVG(`Checkin service`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Cleanliness', ROUND(AVG(`Cleanliness`), 2) FROM Dissatisfied
  UNION ALL
  SELECT 'Online boarding', ROUND(AVG(`Online boarding`), 2) FROM Dissatisfied
),
RankedRatings AS (
  SELECT *,
         RANK() OVER (ORDER BY feature ASC) AS rn
  FROM ServiceAverages
)
SELECT * FROM RankedRatings
WHERE rn <= 3;

 -- Flight Distance & Demographics Questions
 
-- Ques.10 Is there any relationship between flight distance and satisfaction?

With DistanceBuckets As
(Select *,
Case 
When `Flight Distance` <500 Then 'Short (<500)'
When `Flight Distance` Between 500 And 1000 Then 'Medium (500-1000)'
Else 'Long (>1000)'
End as distance_range
From invistico_airline)
,
SatisfactionStats As (
Select 
distance_range,
Count(*) As total_passenger,
Sum(Case When Satisfaction = "Satisfied" Then 1 Else 0 End) As satisfied_passenger
From DistanceBuckets
Group by distance_range)

Select 
distance_range,
total_passenger,
satisfied_passenger,
Round(100 * satisfied_passenger/total_passenger , 2) As satisfied_percentage
From SatisfactionStats
Group by distance_range,total_passenger,satisfied_passenger
Order by distance_range;

-- Ques.11 Which gender and age group combination is most dissatisfied?

WITH AgeBuckets AS (
  SELECT 
    Gender,
    Satisfaction,
    CASE
      WHEN Age BETWEEN 5 AND 25 THEN '5-25'
      WHEN Age BETWEEN 26 AND 45 THEN '26-45'
      WHEN Age BETWEEN 46 AND 65 THEN '46-65'
      ELSE '66-85'
    END AS age_range
  FROM invistico_airline
  WHERE Satisfaction = 'dissatisfied'
),

DissatisfactionStats AS (
  SELECT 
    age_range,
    Gender,
    COUNT(*) AS dissatisfied_passenger
  FROM AgeBuckets
  GROUP BY age_range, Gender
)

SELECT 
  age_range,
  Gender,
  dissatisfied_passenger
FROM DissatisfactionStats
ORDER BY age_range, Gender;

-- -----------------------------------------------------------
-- ✈️ Invistico Airline: Customer Satisfaction Analysis Project
-- -----------------------------------------------------------

-- 🔍 Objective:
-- Analyze airline passenger data to identify key factors 
-- affecting customer satisfaction, service experience, 
-- and punctuality.

-- 📌 Key Insights:

-- 1. Overall Satisfaction:
--    - Majority of passengers are either 'Satisfied' or 'Dissatisfied'.
--    - Helps understand the need for operational or service improvements.

-- 2. Customer Type:
--    - Loyal customers have a significantly higher satisfaction rate.
--    - Investing in loyalty programs can help retain valuable customers.

-- 3. Travel Type:
--    - Business travelers are more satisfied than personal travelers.
--    - Suggests improving the experience for personal travel customers.

-- 4. Travel Class:
--    - Business Class shows the highest satisfaction levels.
--    - Insights can guide improvements in Economy and Eco Plus.

-- 5. Delay Impact:
--    - Longer delays correlate with lower satisfaction.
--    - Operational improvements can enhance customer experience.

-- 6. In-flight Service Pain Points:
--    - Lowest-rated services (by dissatisfied customers) include:
--      * Inflight Wi-Fi
--      * Online Support
--      * Gate Location
--    - Focused improvements here may boost satisfaction rates.

-- 7. Flight Distance vs. Satisfaction:
--    - Short-haul flights show lower satisfaction rates.
--    - Indicates need for better short-flight services.

-- 8. Gender & Age Analysis:
--    - Males aged 26–45 have higher dissatisfaction.
--    - Tailored engagement for this group can help improve perception.

-- ✅ Conclusion:
-- Improving service quality, reducing delays, and targeting key
-- dissatisfied customer segments can help Invistico Airlines
-- significantly boost overall passenger satisfaction and loyalty.

-- Converting sql file into csv file

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT * FROM invistico_airline
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invistico_airline_sql.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';









