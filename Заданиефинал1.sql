USE customers_transactions;
CREATE DATABASE customers_transactions;
UPDATE customers SET Gender = NULL WHERE Gender ='';
UPDATE customers SET Age = NULL WHERE Age ='';
ALTER TABLE Customers MODIFY AGE INT NULL;


SELECT * FROM Customers; 

CREATE TABLE Transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL (10,3),
Sum_payment DECIMAL (10,2));

SELECT * FROM Transactions; 

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_(1).csv"
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'   
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_(1).csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@date_new, Id_check, ID_client, Count_products, Sum_payment)
SET date_new = STR_TO_DATE(@date_new, '%d/%m/%Y');

SHOW VARIABLES LIKE 'secure_file_priv';


# SQL Final Project
## Описание
В рамках проекта выполнен анализ клиентской базы и транзакций за период с 01.06.2015 по 01.06.2016.
## Выполненные задачи
- Поиск клиентов с непрерывной историей покупок.
- Расчет среднего чека.
- Расчет средней суммы покупок за месяц.
- Анализ операций по месяцам.
- Анализ возрастных групп клиентов.
- Поквартальная статистика.

## -- Задание 1
SELECT
    t.ID_client,
    COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS active_months,
    ROUND(AVG(t.Sum_payment), 2) AS avg_check,
    ROUND(SUM(t.Sum_payment) / 12, 2) AS avg_month_sum,
    COUNT(*) AS total_operations
FROM transactions t
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY t.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new,'%Y-%m')) = 12;


-- Задание 2
SELECT
    DATE_FORMAT(t.date_new,'%Y-%m') AS month,
    ROUND(AVG(t.Sum_payment),2) AS avg_check,
    COUNT(*) AS operations_count,
    COUNT(DISTINCT t.ID_client) AS clients_count,
    ROUND(
        COUNT(*) * 100 /
        (SELECT COUNT(*)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new < '2016-06-01'),
        2
    ) AS operations_share,
    ROUND(
        SUM(t.Sum_payment) * 100 /
        (SELECT SUM(Sum_payment)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new < '2016-06-01'),
        2
    ) AS payment_share,
    ROUND(100*SUM(CASE WHEN c.Gender='M' THEN 1 ELSE 0 END)/COUNT(*),2) AS male_percent,
    ROUND(100*SUM(CASE WHEN c.Gender='F' THEN 1 ELSE 0 END)/COUNT(*),2) AS female_percent,
    ROUND(100*SUM(CASE WHEN c.Gender IS NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS na_percent,
    ROUND(100*SUM(CASE WHEN c.Gender='M' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS male_spending,
    ROUND(100*SUM(CASE WHEN c.Gender='F' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS female_spending,
    ROUND(100*SUM(CASE WHEN c.Gender IS NULL THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment),2) AS na_spending
FROM transactions t
LEFT JOIN customers c
ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY DATE_FORMAT(t.date_new,'%Y-%m')
ORDER BY month;

SELECT
    ROUND(AVG(operations_count),2) AS avg_operations_month,
    ROUND(AVG(clients_count),2) AS avg_clients_month
FROM
(
    SELECT
        DATE_FORMAT(date_new,'%Y-%m') AS month,
        COUNT(*) AS operations_count,
        COUNT(DISTINCT ID_client) AS clients_count
    FROM transactions
    WHERE date_new >= '2015-06-01'
      AND date_new < '2016-06-01'
    GROUP BY DATE_FORMAT(date_new,'%Y-%m')
) t;


 
 -- Задание 3
SELECT
    CASE
        WHEN c.Age IS NULL THEN 'Нет данных'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    COUNT(*) AS operations_count,
    ROUND(SUM(t.Sum_payment),2) AS total_sum,
    ROUND(AVG(t.Sum_payment),2) AS avg_check,

    ROUND(
        COUNT(*) * 100 /
        (SELECT COUNT(*)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new < '2016-06-01'),
        2
    ) AS operations_percent,

    ROUND(
        SUM(t.Sum_payment) * 100 /
        (SELECT SUM(Sum_payment)
         FROM transactions
         WHERE date_new >= '2015-06-01'
           AND date_new < '2016-06-01'),
        2
    ) AS payment_percent

FROM transactions t
LEFT JOIN customers c
ON t.ID_client = c.Id_client

WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'

GROUP BY age_group
ORDER BY age_group;