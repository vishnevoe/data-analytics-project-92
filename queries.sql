/* Запрос, считающий общее количество покупателей из таблицы customers. */

select COUNT(customer_id)
from customers;

/* Запрос, с помощью которого формируется отчет о десяти лучших продавцах.
Отчет состоит из трех колонок: данные о продавце, данные о суммарной выручке
проданных товаров и данные о количестве проведенных сделок.
Данные отсортированы по убыванию выручки. */

select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

/* Запрос, с помощью которого формируется отчет с информацией о продавцах,
чья средняя выручка за сделку меньше средней выручки за сделку по всем
продавцам.
Данные отсортированы по возрастанию выручки. */

select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(s.quantity * p.price)) as average_income
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
group by seller
having
    avg(s.quantity * p.price)
    < (
        select avg(s1.quantity * p1.price)
        from sales as s1
        left join products as p1 on s1.product_id = p1.product_id
    )
order by average_income asc;

/* Запрос, с помощью которого формируется отчет,
содержащий информацию о выручке по дням недели.
Каждая запись содержит имя и фамилию продавца,
день недели и суммарную выручку.
Данные отсортированы по порядковому номеру дня недели и продавцу. */

select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    TO_CHAR(s.sale_date, 'day') as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join products as p
    on s.product_id = p.product_id
group by seller, TO_CHAR(s.sale_date, 'day'), EXTRACT(isodow from s.sale_date)
order by EXTRACT(isodow from s.sale_date), seller;

/* Запрос, с помощью которого формируется отчет
с информацией о количестве пользователей в трех
возрастных группах: 16-25, 26-40, старше 40.
Данные отсортированы по возрастным группам. */

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

/* Запрос, с помощью которого формируется отчет
с информацией о количестве уникальных покупателей
и выручке, которую они принесли.
Данные сгруппированы по дате и отсортированы
по дате по возрастанию. */

select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
group by TO_CHAR(s.sale_date, 'YYYY-MM')
order by selling_month;

/* Запрос, с помощью которого формируется отчет
о покупателях, первая покупка которых была в ходе проведения акций
(цена товара указана как равная нулю).
Данные отсортированы по id покупателя. */

select distinct on (s.customer_id)
    s.sale_date,
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    CONCAT(e.first_name, ' ', e.last_name) as seller
from sales as s
left join employees as e
    on s.sales_person_id = e.employee_id
left join customers as c
    on s.customer_id = c.customer_id
left join products as p
    on s.product_id = p.product_id
where p.price = 0
order by s.customer_id, s.sale_date;
