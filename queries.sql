# Запрос, считающий общее количество покупателей из таблицы customers.

select 
	COUNT(customer_id) from customers c;

# Запрос, с помощью которого формируется отчет о десяти лучших продавцах. Отчет состоит из трех колонок: данные о продавце, данные о суммарной выручке с проданных товаров и данные о количестве проведенных сделок. Данные отсортированы по убыванию выручки.

select  
	concat(e.first_name, ' ', e.last_name) as seller,
	COUNT(s.sales_id) as operations,
	floor(SUM(s.quantity * p.price)) as income
from sales s
left join employees e 
	on s.sales_person_id = e.employee_id
left join products p 
	on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

# Запрос, с помощью которого формируется отчет с информацией о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Данные отсортированы по возрастанию выручки.

with average_seller as (
select
	concat(e.first_name, ' ', e.last_name) as seller,
	floor(AVG(s.quantity * p.price)) as average_income
from sales s
left join employees e 
	on s.sales_person_id = e.employee_id
left join products p 
	on s.product_id = p.product_id
group by seller
)
select 
	seller,
	average_income
from average_seller
where average_income < (select avg(average_income) from average_seller)	
order by average_income asc;

# Запрос, с помощью которого формируется отчет, содержащий информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку. Данные отсортированы по порядковому номеру дня недели и продавцу.

select  
	concat(e.first_name, ' ', e.last_name) as seller,
	TO_CHAR(s.sale_date, 'Day') AS day_of_week,
	floor(SUM(s.quantity * p.price)) as income
from sales s
left join employees e 
	on s.sales_person_id = e.employee_id
left join products p 
	on s.product_id = p.product_id
group by seller, s.sale_date
order by extract(isodow from s.sale_date), seller;
