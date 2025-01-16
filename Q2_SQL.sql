--Second: Write queries that directly answer predetermined questions from a business stakeholder
--Xinyue(Starry) Zhang
 
 --Q1
 /* What are the top 5 brands by receipts scanned for most recent month? */
 
select b.name, count(distinct r.receipt_id) as total_receipts 
from Fact_Receipt r
left join Fact_Receipt_Items i on r.receipt_id = i.receipt_id
left join Dim_Brands b on i.brand_id = b.brand_id
-- where r.dateScanned >= dateadd(month, -1, cast(current_timestamp as date))
where r.dateScanned >= date_trunc('month', current_date) - interval '1 month'
  and r.dateScanned < date_trunc('month', current_date)
group by 1
order by 2 desc
limit 5

 --Q2
/*How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?*/

-- this month
with t1 as(
	select b.brand_id, b.name, count(distinct r.receipt_id) as receipt_count
  from Dim_Brands b
  left join Fact_Receipt_Items ri on b.brand_id = ri.brand_id
  left join Fact_Receipt r on ri.receipt_id = r.receipt_id
  where r.purchase_date >= date_tranc('month', current_date)
  and r.purchase_date < date_trunc('month', current_date) + interval '1 month'
  group by 1, 2
)
select *
from t1
order by receipt_count desc
limit 5

-- last month
with t2 as(
	select b.brand_id, b.name, count(distinct r.receipt_id) as receipt_count
  from Dim_Brands b
  left join Fact_Receipt_Items ri on b.brand_id = ri.brand_id
  left join Fact_Receipt r on ri.receipt_id = r.receipt_id
  where r.purchase_date >= date_trunc('month', current_date) - interval '1 month'
  and r.purchase_date < date_tranc('month', current_date)
  group by 1, 2
)
select *
from t2
order by receipt_count desc
limit 5


--Q3
/*When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater? */

select avg(totalSpend) as avg, rewardsReceiptStatus
from Fact_Receipt
where rewardsReceiptStatus in ('Accepted','Rejected')
group by rewardsReceiptStatus
order by 1 desc

--04
/*When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?*/

select sum(purchasedItemCount) as total, rewardsReceiptStatus
from Fact_Receipt
where rewardsReceiptStatus in ('Accepted','Rejected')
group by rewardsReceiptStatus
order by 1 desc

--05
/*Which brand has the most spend among users who were created within the past 6 months?*/

with t as(
select user_id
from Dim_User
where user_created_date >= dateadd(month, -6,  cast(current_timestamp as date)) 
）

select b.name, sum(r.totalSpend) as total
from Fact_Receipt r
left join t on r.user_id = t.user_id
left join Fact_Receipt_Items i on r.receipt_id = i.receipt_id 
left join Dim_Brands b on i.brand_id = b.brand_id 
group by 1
order by 2 desc
limit 1

--06
/*Which brand has the most transactions among users who were created within the past 6 months?*/

with t as(
select user_id
from Dim_User
where user_created_date >= dateadd(month, -6, cast(current_timestamp as date))
）

select b.name, count(distinct(r.receipt.id))as total_transactions
from Fact_Receipt r
left join t on r.user_id = t.user_id
left join Fact_Receipt_Items i on r.receipt_id = i.receipt_id
left join Dim_Brands b on i.brand_id = b.brand_id
group by 1
order by 2 desc
limit 1
  
