Create Database banking;
use banking;

CREATE TABLE DISTRICT(
District_code INT PRIMARY KEY ,
District_name	VARCHAR(100) ,
Region	        VARCHAR(100),
No_of_inhabitants	INT,
No_of_municipalities_with_inhabitants_less_499	INT,
No_of_municipalities_with_inhabitants_500_btw_1999	INT,
No_of_municipalities_with_inhabitants_2000_btw_9999	INT,
No_of_municipalities_with_inhabitants_less_10000	INT,
No_of_cities	INT,
Ratio_of_urban_inhabitants	FLOAT,
Average_salary	INT,
No_of_entrepreneurs_per_1000_inhabitants	INT,
No_committed_crime_2017	 INT,
No_committed_crime_2018  INT
);

LOAD DATA LOCAL INFILE "C:/district.csv"
INTO TABLE DISTRICT
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

UPDATE DISTRICT
SET No_committed_crime_2017	= NULL
WHERE No_committed_crime_2017 = 0

SELECT COUNT(*) FROM DISTRICT

CREATE TABLE `ACCOUNT`(
account_id	INT PRIMARY KEY ,
district_id	INT ,
frequency	varchar(100),
`Date`	DATE,
Account_type	varchar(100),
Card_Assigned VARCHAR(50),

FOREIGN KEY(district_id) REFERENCES DISTRICT(district_code)
);

LOAD DATA LOCAL INFILE "C:/account_new.csv"
INTO TABLE `ACCOUNT`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

SELECT * FROM ACCOUNT;

CREATE TABLE `ORDER`(
order_id	INT PRIMARY KEY,
account_id	INT,
Bank_to	 VARCHAR(50),
account_to	INT,
amount FLOAT,

FOREIGN KEY(account_id) REFERENCES `ACCOUNT`(account_id)
);

LOAD DATA LOCAL INFILE "C:/order.csv"
INTO TABLE `ORDER` 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

SELECT * FROM `ORDER`

CREATE TABLE LOAN(
loan_id	INT PRIMARY KEY,
account_id	INT,
`Date`	DATE,
amount	INT,
duration	INT,
payments	INT,
`status` VARCHAR(50),

FOREIGN KEY(account_id) REFERENCES `ACCOUNT`(account_id)
);

LOAD DATA LOCAL INFILE "C:/loan.csv"
INTO TABLE LOAN
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

SELECT * FROM LOAN

CREATE TABLE TRANSACTIONS(
trans_id	INT PRIMARY KEY ,
account_id	INT,
`Date` DATE,	
`Type` VARCHAR(50),	
operation	VARCHAR(100),
amount	INT,
balance	FLOAT,
Purpose	VARCHAR(50),
bank	VARCHAR(50),
`account` INT,

FOREIGN KEY(account_id) REFERENCES `ACCOUNT`(account_id)
);

LOAD DATA LOCAL INFILE "C:/tax_21.csv"
INTO TABLE TRANSACTIONS
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS


CREATE TABLE `CLIENT`(
client_id	INT PRIMARY KEY,
Sex	VARCHAR(10),
Birth_date DATE,
district_id INT,

FOREIGN KEY(district_id) REFERENCES DISTRICT(District_code)
);

DROP TABLE `CLIENT`

LOAD DATA LOCAL INFILE "C:/client_new.csv"
INTO TABLE `CLIENT`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

SELECT * FROM  `CLIENT`

CREATE TABLE DISPOSITION(
disp_id	INT PRIMARY KEY,
client_id	INT,
account_id	INT,
`type` VARCHAR(6),

FOREIGN KEY(account_id) REFERENCES `ACCOUNT`(account_id),
FOREIGN KEY(client_id) REFERENCES `CLIENT`(client_id)
);

LOAD DATA LOCAL INFILE "C:/disp.csv"
INTO TABLE DISPOSITION
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

CREATE TABLE CARD(
card_id	INT PRIMARY KEY,
disp_id	INT,
`Type` VARCHAR(10),	
issued DATE,

FOREIGN KEY(disp_id) REFERENCES DISPOSITION(disp_id)
);

LOAD DATA LOCAL INFILE "C:/card.csv"
INTO TABLE CARD
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

SELECT * FROM CARD

SELECT *  FROM TRANSACTIONS WHERE BANK IS NULL AND YEAR(DATE) = '2016'

SELECT YEAR(DATE)AS TXT_YEAR,COUNT(*) AS TOTAL_TXNS
FROM TRANSACTIONS
WHERE BANK IS NULL 
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM DISTRICT;
SELECT *  FROM TRANSACTIONS;
SELECT * FROM `ACCOUNT`;
SELECT * FROM `ORDER`;
SELECT * FROM LOAN;
SELECT * FROM `CLIENT`;
SELECT * FROM CARD;
SELECT * FROM DISPOSITION;

select count(*) as total_transaction from transactions;
/* 1048575*/

select `bank`,count(*) as total_transaction from
transactions
group by `bank`;

select account_id,round(sum(balance),2)as account_bal 
from transactions
group by account_id;

select account_id,count(*) as total_trans from
transactions
group by account_id;

select account_id,total_trans from(
select account_id,count(*)as total_trans,dense_rank()
over(order by count(*) desc)as rank_num
from transactions
group by account_id
)t
where rank_num = 1

/* account no 8261 is highest 672 total trans comparision to other account */

q.1 which account is highest total balance 

select account_id,total_balance from(
select account_id,round(sum(balance),2) as total_balance,dense_rank()
over(order by sum(balance) desc) as rank_num
from transactions
group by 1
)t
where rank_num = 1;

/* account no 96 have highest total balance 49845489.27 comaprison to other account */

q.2 how many transactions in 2017 to 2021

select year(date),count(*) as total_trans from
transactions
group by  year(date)
order by year(date)

/* total trans year wise 
2016 = 28205. 
2017 = 91628. 
2018 = 133022. 
2019 = 196779. 
2020 = 284409. 
2021 = 314532. */

which operation account holder use for maximum transactions

select operation,total_trans from(
select operation,count(*) as total_trans,dense_rank()
over(order by count(*) desc)as rank_num from
transactions 
group by operation
)t
where rank_num = 1;

/* most customers use Withdrawal in cash for most transactions */

select sum(amount) as total_amount
from transactions;

-- 6230793381 total amount 

select round(sum(balance),2) as total_balance
from transactions;

-- total balance 40324764430.59

select type,sum(amount) as total_amount
from transactions
group by type;

-- Credit amount	3216335973
-- Withdrawal amount	3014457408

select timestampdiff(year,birth_date,curdate()) as age 
from client;

Q1. Customer Demographics
q.1.1] What is the age distribution of clients?
select 
case
when timestampdiff(year,birth_date,curdate()) between 18 and 25 then '18-25'
when timestampdiff(year,birth_date,curdate()) between 26 and 35 then '26-35'
when timestampdiff(year,birth_date,curdate()) between 36 and 45 then '26-45'
when timestampdiff(year,birth_date,curdate()) between 46 and 60 then '46-60'
else '60+'
end as age_group,
count(*) as total_clients
from client
group by age_group
order by age_group;

-- age group 18-25 total_clients 648
-- age group 26-35	total_clients 971
-- age group 36-45		total_clients 966
-- age group 46-60	total_clients 1466 age group 46 + most client bank is old age customer do for young people 
-- age group 60+	total_clients 1318

q.1.2] How many male vs female customers?

select sex,count(*) as total_customers 
from client
group by sex;

-- Male	2766
-- Female	2603

q.1.3] Which district has the most customers?

select district_name,total_customers from(
select d.district_name,count(c.client_id) as total_customers,
dense_rank() over(order by count(c.client_id) desc) as rank_num
from client c left join district d
on c.district_id=d.district_code
group by d.district_name
)t
where rank_num = 1;

-- district Hl.m. Praha have most customers 663

q.2] Account Distribution
q.2].1] Total number of accounts?

select count(*) as total_account 
from account

-- total 4500 account.

q.2.2] How many customers have multiple accounts?

select client_id,count(account_id) as total_customers
from disposition
group by client_id
having count(account_id) > 1;

-- all customer have only one account

q.3.3] Which district has highest number of accounts?

select district_name,total_accounts from(
select d.district_name,count(a.account_id)as total_accounts,
dense_rank() over(order by count(a.account_id) desc) as rank_num
from district d left join account a 
on d.district_code=a.district_id
group by 1
)t
where rank_num = 1;

-- Hl.m. Praha	district has highest number of accounts. 554

Q3. Transaction Volume

q.3.1] Total number of transactions?

select count(*) as total_transactions
from transactions;

-- total transactions is 1048575.

q.3.2] Total money credited vs debited?

select type,sum(amount)as total_money 
from transactions
group by type

total money Credit	is 3216335973
total money debit(Withdrawal) is 3014457408
insight not much difference between credit and debit 

q.3.3] Monthly transaction trend

select year(date)as yr,month(date) as mn,sum(amount) as total_amount
from transactions
group by year(date),month(date)
order by yr,mn

Q4. Customer Activity
q.4].1]
Top 10 most active customers (by transaction count)

select client_id,total_transactions from(
select d.client_id,count(t.trans_id)as total_transactions,
dense_rank() over(order by count(t.trans_id) desc) as rank_num
from disposition d left join transactions t 
on d.account_id=t.account_id
group by client_id
)t
where rank_num <= 10;

q.4].2] Customers with no transactions

select distinct d.client_id
from disposition d  left join transactions t
on d.account_id=t.account_id
where t.trans_id is null

Q5. Transaction Behavior

q.5].1] Average transaction amount

select round(avg(amount),2) avg_transaction_amount 
from transactions

-- insight: avg_transaction_amount is 5942.15.

q.5].2] Most common transaction type

select operation,count(*) as total_transactions 
from transactions
group by operation
order by total_transactions desc;

/* Withdrawal in cash	432377
Remittance to Another Bank	208283
Interest Credit	178663
Credit in cash 	156320
Electronic funds transfer	65226
Credit card withdrawal	7706

insight : Withdrawal in cash is most common transaction type. */

SECTION 3: CARD ANALYSIS

Q6. Card Usage
q.6].1] How many customers have cards?

select count(distinct d.client_id)as customer_with_cards
from card c join disposition d 
on c.disp_id=d.disp_id

-- 892 customer with cards

q.6]. 2] Card types distribution (gold/silver/etc.)

select c.type,count(d.client_id) as total_customers 
from card c left join disposition d 
on c.disp_id=d.disp_id
group by c.type
order by total_customers desc;

/* insight :Gold card has 659 customers.
Silver card  has 145 customers.
Diamond	card has 88 customers.
in comarision  between gold and diamond gold has more customers.
*/
q.6].3] Customers without cards
select distinct d.client_id
from disposition d  left join  card c 
on d.disp_id=c.disp_id
where c.card_id is null

SECTION 4: LOAN ANALYSIS (VERY IMPORTANT)

Q7. Loan Distribution
q.7].1] Total number of loans

select count(loan_id) as total_loans
from loan

-- 682 total loans.

q.7].2] Total loan amount

select sum(amount) as total_loan_amount 
from loan

-- total loan amount is 103261740.

q.7].3] Average loan per customer

select round(avg(amount),2) as avg_loan
from loan

-- insight avg_loan per customer is 151410.18.

select round(sum(l.amount)/count(d.client_id),2)as avg_Loan
from loan l left join disposition d
on l.account_id=d.account_id

-- insgiht: avg_loan per_customer 151801.54.

Q8. Loan Status

q.8].1] Fully paid loans

select status,count(*) as loan_count
from loan
group by status

/* insight: loan complete : Contract Finished : 203
Loan not payed : 31
Client in debt : 45
Running Contract : 403
*/

-- risk lvevel increase because running loan showing 403

Q9. Default Analysis

defaut rate is not given 
i also calauclate default rate but showing 0.00 
that why i drop q.9 

q.10 also i drop

select 
round(
    sum(case 
        when status in ('Client in debt','Loan not payed') then 1 
        else 0 
    end) * 100.0 / count(*), 2
) as default_rate
from loan;

select status, count(*) 
from loan
group by status;

select 
round(
    sum(case 
        when trim(status) like '%debt%' 
          or trim(status) like '%not payed%' 
        then 1 else 0 
    end) * 100.0 / count(*), 2
) as default_rate
from loan;

select a.account_type,count(c.client_id) as total_customers 
from account a left join client c 
on a.district_id=c.client_id
group by a.account_type

 /* NRI account: 1427
 Salary account	1358
 Savings account	1457 */
 
select * from loan

select a.account_type,count(t.trans_id)as total_transactions
from account a left join transactions t 
on a.account_id=t.account_id
group by a.account_type

select a.frequency,count(t.trans_id)as total_transactions,
sum(t.amount) as total_amount,
round(avg(t.amount),2) as avg_transaction_amount
from account a left join transactions t 
on a.account_id=t.account_id
group by 1

MONTHLY ISSUANCE	962231	5309874806	5518.30
WEEKLY ISSUANCE	62058	660942638	10650.40
ISSUANCE AFTER TRANSACTION	24286	259975937	10704.77

select frequency,count(*)as total_account
from account
group by frequency

MONTHLY ISSUANCE	4167
WEEKLY ISSUANCE	240
ISSUANCE AFTER TRANSACTION	93

/* Monthly accounts drive the majority of transaction volume and revenue, making them the backbone of the bank’s operations.”
“However, weekly and post-transaction accounts exhibit significantly higher average transaction values, indicating a high-value customer segment.”
“The bank should focus on converting more customers into high-frequency account types to increase profitability
*/

select * from `order`

select bank,sum(amount) as transaction_amount
from transactions
group by 1


select operation,sum(amount)as total_expense 
from transactions
where type = 'Withdrawal'
group by operation
order by total_expense desc;

Withdrawal in cash	2324392424
Remittance to Another Bank	672638484
Credit card withdrawal	17426500

select `type`,count(*) as total
from transactions
group by `type`

/* The majority of expenses are driven by cash withdrawals, indicating a strong reliance on physical cash transactions.”
“Interbank remittances also contribute significantly, suggesting dependency on external banking networks.”
“Low credit card usage presents an opportunity for the bank to promote digital payment solutions and improve profitability.
*/

select count(*) as total_count,
sum(amount) as total_loan,
round(avg(amount),2) as avg_total_loan
from loan


total count = 682	total_loan = 103261740	avg_total_loan = 151410.18

select d.district_name,
count(l.loan_id)as loans_count,
sum(l.amount)as total_loan,
round(avg(l.amount),2) avg_total_loan
from district d left join account a 
on d.district_code =a.district_id
left join loan l
on a.account_id=l.account_id
group  by d.district_name

select 
case 
when amount < 100000 then 'low loan'
when amount between 100000 and 200000 then 'medium loan'
else 'high loan'
end as loan_segment,
count(*) loan_count,
sum(amount) as total_loan,
round(avg(amount),2) total_avg_loan
from loan
group by loan_segment

/*The bank’s loan portfolio is distributed across low, medium, and high loan segments.
While the majority of customers fall under the low loan segment, the high loan segment contributes the largest share of total loan amount.”
This indicates that a smaller group of customers carries a significant portion of the bank’s financial exposure.”
The medium loan segment provides a balanced contribution in terms of both volume and value.*/



