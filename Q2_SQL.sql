--Second: Write queries that directly answer predetermined questions from a business stakeholder
--Xinyue(Starry) Zhang
 
 --Q1
 /* What are the top 5 brands by receipts scanned for most recent month? */
 
select b.name, count(distinct r.receipt_id) as total_receipts 
from Receipt r
left join ReceiptItems i on r.receipt_id = i.receipt_id
left join Brands b on i.barcode = b.barcode
where r.date_scanned >= date_trunc('month', current_date) - interval '1 month' --start of the most recent month
  and r.date_scanned < date_trunc('month', current_date)-- end of the most recent month
group by 1
order by 2 desc
limit 5;

 --Q2
/*How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?*/

-- this month
with t1 as(
	select b.barcode, b.name as brand_name, count(distinct r.receipt_id) as receipt_count,
  				'this_month' as time
  from Brands b
  left join ReceiptItems ri on b.barcode = ri.barcode
  left join Receipt r on ri.receipt_id = r.receipt_id
  where r.purchase_date >= date_trunc('month', current_date) -- start of the current month
  and r.purchase_date < date_trunc('month', current_date) + interval '1 month' -- end of the current month
  group by 1, 2
  order by receipt_count desc
  limit 5
)

-- last month
with t2 as(
	select b.barcode, b.name as brand_name, count(distinct r.receipt_id) as receipt_count,
  				'last_month' as time
  from Brands b
  left join ReceiptItems ri on b.barcode = ri.barcode
  left join Receipt r on ri.receipt_id = r.receipt_id
  where r.purchase_date >= date_trunc('month', current_date) - interval '1 month'-- start of the previous month
  and r.purchase_date < date_tranc('month', current_date) -- end of the previous month
  group by 1, 2
  order by receipt_count desc
  limit 5
)

-- Combine the two tables
select *
from t1
union all
select * 
from t2;

--Q3
/*When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater? */

select avg(total_spent) as avg, rewards_receipt_status
from Receipt
where rewards_receipt_status in ('Accepted','Rejected')
group by rewards_receipt_status
order by 1 desc;

--04
/*When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?*/

select sum(purchased_item_count) as total, rewards_receipt_status
from Receipt
where rewards_receipt_status in ('Accepted','Rejected')
group by rewards_receipt_status
order by 1 desc;

--05
/*Which brand has the most spend among users who were created within the past 6 months?*/

with t as(
select user_id
from User
where user_created_date >= dateadd(month, -6,  cast(current_timestamp as date)) 
  ---- Filter users created in the past 6 months
）

select b.name as brand_name, sum(r.total_spend) as total
from Receipt r
left join t on r.user_id = t.user_id
left join ReceiptItems i on r.receipt_id = i.receipt_id 
left join Brands b on i.barcode = b.barcode
group by 1
order by 2 desc
limit 1;

--06
/*Which brand has the most transactions among users who were created within the past 6 months?*/

with t as(
select user_id
from User
where user_created_date >= dateadd(month, -6, cast(current_timestamp as date))
  -- Filter users created in the past 6 months
）

select b.name as brand_name, count(distinct(r.receipt.id))as total_transactions -- count unique transactions 
from Receipt r
left join t on r.user_id = t.user_id
left join ReceiptItems i on r.receipt_id = i.receipt_id
left join Brands b on i.barcode = b.barcode 
group by 1
order by 2 desc
limit 1;
  
