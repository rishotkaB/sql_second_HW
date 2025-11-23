-- Задание 1
select p.brand, sum(oi.quantity) as total_sales
from product p
join order_items oi on p.product_id = oi.product_id
where p.standard_cost > 1500
group by p.brand
having sum(oi.quantity) >= 1000
order by total_sales desc;


-- Задание 2
select order_date, count(order_id) as order_count, count(distinct customer_id) as unique_customers
from orders 
where order_date between '2017-04-01' and '2017-04-09'
and online_order = true
and order_status = 'Approved'
group by order_date;


-- Задание 3
select job_title from customer where  job_industry_category = 'IT' and job_title like 'Senior%' and date_part('year', age(current_date, to_date("DOB", 'YYYY-MM-DD'))) > 35
union all
select job_title from customer where  job_industry_category = 'Financial Services' and job_title like 'Lead%'and date_part('year', age(current_date, to_date("DOB", 'YYYY-MM-DD'))) > 35;


-- Задание 4
select distinct p.brand
from product p
join order_items oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id
join customer c on o.customer_id = c.customer_id
where c.job_industry_category = 'Financial Services'

except

select distinct p.brand
from product p
join order_items oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id
join customer c on o.customer_id = c.customer_id
where c.job_industry_category = 'IT';


-- Задание 5

select c.customer_id, c.first_name, c.last_name, count(o.order_id) as total_orders
from customer c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id  
join product p on oi.product_id = p.product_id
where o.online_order = true
and c.deceased_indicator = 'N'
and c.property_valuation > (
    select avg(c2.property_valuation) 
    from customer c2 
    where c2.state = c.state
)
and p.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles')
group by c.customer_id, c.first_name, c.last_name
order by total_orders desc
limit 10;

-- Задание 6
select c.customer_id, c.first_name, c.last_name
from customer c
where c.owns_car = 'Yes'
and c.wealth_segment != 'Mass Customer'
and not exists (
select *
from orders o
where o.customer_id = c.customer_id
and o.online_order = true
and o.order_status = 'Approved'
and to_date(o.order_date, 'YYYY-MM-DD') >= current_date - interval '1 year');

-- Задание 7
select c.customer_id, c.first_name, c.last_name
from customer c
where c.job_industry_category = 'IT'
and (
    select count(distinct p.product_id)
    from orders o
    join order_items oi on o.order_id = oi.order_id  
    join product p on oi.product_id = p.product_id
    where o.customer_id = c.customer_id
    and p.product_id in (
        select product_id from product 
        where product_line = 'Road' 
        order by list_price desc 
        limit 5
    )
) = 2;

-- Задание 8
select c.customer_id, c.first_name, c.last_name, c.job_industry_category
from customer c
where c.job_industry_category = 'IT'
and exists (
select 1
from orders o
join order_items oi on o.order_id = oi.order_id
where o.customer_id = c.customer_id
and o.order_status = 'Approved'
and to_date(o.order_date, 'YYYY-MM-DD') between '2017-01-01' and '2017-03-01'
group by o.customer_id
having count(o.order_id) >= 3 and sum(oi.quantity * oi.item_list_price_at_sale) > 10000
)
union
select c.customer_id, c.first_name, c.last_name, c.job_industry_category
from customer c
where c.job_industry_category = 'Health'
and exists (
select 1
from orders o
join order_items oi on o.order_id = oi.order_id
where o.customer_id = c.customer_id
and o.order_status = 'Approved'
and to_date(o.order_date, 'YYYY-MM-DD') between '2017-01-01' and '2017-03-01'
group by o.customer_id
having count(o.order_id) >= 3 and sum(oi.quantity * oi.item_list_price_at_sale) > 10000);