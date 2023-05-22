use PORTFOLIO 
alter database TEST_PORTFOLIO MODIFY NAME = PORTFOLIO;
----Create view
create view sales17 AS
select * from sales_2017
create view sales16 AS
select * from sales_2016
create view Return_1 AS
select * from returns
--UNION sales 16, 17
create view UnionTable_Sale1617 
AS
select * from dbo.sales_2016 
UNION
select * from dbo.sales_2017
order by OrderDate, ProductKey offset 0 rows;

drop view UnionTable_Sale1617
--Sum(OrderQuantity) and group by fill ProductKey
create view totalOrders AS
select sum(OrderQuantity) numberOforders, ProductKey
from UnionTable_Sale1617 
group by ProductKey
order by numberOforders offset 0 rows;
drop view totalOrders
--Sum(ReturnQuantity) and group by fill ProductKey
create view totalReturns AS
select sum(ReturnQuantity) numberOfReturns, ProductKey
from Return_1
where Return_1.ReturnDate not like '%2015%'
group by ProductKey
order by numberOfReturns offset 0 rows;
drop view totalReturns
--inner join 
create view TotalReturnsAndOrders AS
select numberOforders, numberOfReturns,totalOrders.ProductKey
from totalOrders 
inner join totalReturns
on totalOrders.ProductKey = totalReturns.ProductKeyss
order by numberOforders, numberOfReturns, ProductKey offset 0 rows;
drop view TotalReturnsAndOrders
select * from TotalReturnsAndOrders
--inner join table product get details products
create view TotalRandO AS
select s.numberOforders, s.numberOfReturns, p.*
from TotalReturnsAndOrders as s
inner join dbo.products as p
on s.ProductKey = p.ProductKey
order by s.numberOforders, s.numberOfReturns, p.ProductName, p.ProductPrice, p.ProductDescription asc offset 0 rows;
drop view TotalRandO
--Câu 6: calc percent average return rate
create view percentReturnQuantity AS
select cast(((numberOfReturns*1.0 / numberOforders) * 100) as numeric(10,2)) as ReturnRate, ProductName,ReturnDate
from TotalRandO
inner join dbo.returns 
on TotalRandO.ProductKey = dbo.returns.ProductKey
where  ReturnDate not like '%2015%'
order by ReturnRate asc offset 0 rows;
drop view percentReturnQuantity

-- create table## 
create table ##ReportRR
(
	ReturnID int identity primary key,
	ReturnRate float,
	ProductName nvarchar(50),
	ReturnDate date
)
-- insert into date table 1 to table 2
insert into ##ReportRR
select * 
from percentReturnQuantity
--Delete ##table
drop table ##PercentReturnQuantity
