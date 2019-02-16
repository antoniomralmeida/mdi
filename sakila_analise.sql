/* análise de granularidade */
use sakila;
select 'base table', count(*) from rental
union all
select 'fact table1', count(*) from (
select  date(rental_date) as rental_date, DATE_FORMAT(rental_date,  '%H') as rental_hour,  film_id, store_id, r.staff_id, r.customer_id, sum(amount) 
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id) left join payment p on (r.rental_id = p.rental_id)
 group by date(rental_date) , DATE_FORMAT(rental_date,  '%H'),  film_id, store_id, r.staff_id, r.customer_id) a
union all
select 'fact table2', count(*) from (
select distinct date(rental_date) as rental_date,  film_id, customer_id 
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id)) a


/* análise de consistência */
select 'base table', sum(amount) from payment
union all
select 'fact table', sum(amount) from rental r left join payment p 
on (r.rental_id = p.rental_id)


select customer_id, sum(amount) from payment where rental_id is null 
group by customer_id

select customer_id, count(*) base_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by customer_id

select rental_id, customer_id, 1 criterio_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by rental_id, customer_id

 /* dimensões */
 select customer_id, concat(first_name,' ', last_name) as name , city, country	
 from customer c left join address a on (c.address_id = a.address_id)
 left join city t on (a.city_id = t.city_id)
 left join country u on (u.country_id = t.country_id)
 
 select store_id, address from store s left join address a on (s.address_id = a.address_id)
 
 select f.film_id, title, GROUP_CONCAT(name) as category from film f 
 left join film_category fm on (f.film_id = fm.film_id)
 left join category c on (fm.category_id = c.category_id)
 group by f.film_id, title
 
 
 select staff_id, concat(first_name,' ', last_name) as name  from staff
 
 
 
 
 select * from category
 
 
 
 


