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

# Запрос, с помощью которого формируется отчет с информацией о количестве пользователей в трех возрастных группах: 16-25, 26-40, старше 40. Данные отсортированы по возрастным группам.

select 
	case 
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
	COUNT(*) as age_count
from customers 
group by age_category
order by age_category;

# Запрос, с помощью которого формируется отчет с информацией о количестве уникальных покупателей и выручке, которую они принесли. Данные сгруппированы по дате и отсортированы по дате по возрастанию.

select
	TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
	COUNT(distinct s.customer_id) as total_customers,
	SUM(floor(s.quantity * p.price)) as income
from sales s
left join products p 
	on s.product_id = p.product_id
group by TO_CHAR(s.sale_date, 'YYYY-MM')
order by selling_month;

# Запрос, с помощью которого формируется отчет о покупателях, первая покупка которых была в ходе проведения акций (цена товара указана как равная нулю). Данные отсортированы по id покупателя.

select DISTINCT ON (s.customer_id)
	concat(c.first_name, ' ', c.last_name) as customer,
	s.sale_date as sale_date,
	concat(e.first_name, ' ', e.last_name) as seller
from sales s
left join employees e 
	on s.sales_person_id = e.employee_id
left join customers c
	on s.customer_id = c.customer_id
left join products p
	on s.product_id = p.product_id
where p.price = 0 
order by s.customer_id, s.sale_date;