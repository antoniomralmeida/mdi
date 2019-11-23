/* análise de granularide */

use sakila;

select count(*) from rental;

select count(*) from (
select rental_hash(r.customer_id, r.staff_id, to_days(rental_date), 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED), i.film_id, i.store_id) as hash,
r.customer_id, r.staff_id, to_days(rental_date) as date_id, 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) as hour_id, i.film_id, i.store_id,
sum(amount) as amount, max(to_days(rental_date)) as rental_days, max(to_days(return_date)) as return_days
from rental r left join inventory i on (r.inventory_id = i.inventory_id)
left join payment p on (r.rental_id = p.rental_id)
group by r.customer_id, r.staff_id, to_days(rental_date) , 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) , i.film_id, i.store_id
) x

/* análise de consistência */
select sum(amount) from payment

select sum(amount) from (
select rental_hash(r.customer_id, r.staff_id, to_days(rental_date), 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED), i.film_id, i.store_id) as hash,
r.customer_id, r.staff_id, to_days(rental_date) as date_id, 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) as hour_id, i.film_id, i.store_id,
sum(amount) as amount, max(to_days(rental_date)) as rental_days, max(to_days(return_date)) as return_days
from rental r left join inventory i on (r.inventory_id = i.inventory_id)
left join payment p on (r.rental_id = p.rental_id)
group by r.customer_id, r.staff_id, to_days(rental_date) , 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) , i.film_id, i.store_id
) x




/* dim Customer */
select customer_id, concat(first_name, ' ', last_name) as name, address, city, country
from customer c left join address a on (c.address_id = a.address_id) 
left join city y on (a.city_id =y.city_id)
left join country t on (y.country_id = t.country_id)

/* dim Store */
select store_id, address, city, country
from store s left join address a on (s.address_id = a.address_id) 
left join city y on (a.city_id =y.city_id)
left join country t on (y.country_id = t.country_id)

/* dim Staff */
select staff_id, concat(first_name, ' ', last_name) as name
from staff

/* dim rental_date */
select distinct to_days(rental_date) as date_id, date(rental_date) as rental_date, 
DATE_FORMAT(rental_date,  '%Y') as year
from rental

/* dim rental_hour */
select distinct CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) as hour_id,
DATE_FORMAT(rental_date,  '%H') as hour
from rental

/* dim film */
select f.film_id, title, category, actor
from film f left join
(select film_id, GROUP_CONCAT(y.name) as category 
from film_category fm left join category y on (fm.category_id = y.category_id)
group by film_id) c
on (f.film_id  = c.film_id)
left join
(select film_id, GROUP_CONCAT(concat(a.first_name, ' ', a.last_name)) as actor 
from film_actor fa left join actor a on (fa.actor_id = a.actor_id)
group by film_id) a
on (f.film_id  = a.film_id)

/* fact rental */
select count(*) from (
select rental_hash(r.customer_id, r.staff_id, to_days(rental_date), 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED), i.film_id, i.store_id) as hash,
r.customer_id, r.staff_id, to_days(rental_date) as date_id, 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) as hour_id, i.film_id, i.store_id,
sum(amount) as amount, max(to_days(rental_date)) as rental_days, max(to_days(return_date)) as return_days
from rental r left join inventory i on (r.inventory_id = i.inventory_id)
left join payment p on (r.rental_id = p.rental_id)
group by r.customer_id, r.staff_id, to_days(rental_date) , 
CAST(DATE_FORMAT(rental_date,  '%H') AS UNSIGNED) , i.film_id, i.store_id
) x

/* base do rateio */ 
select customer_id, sum(amount)
from payment
where rental_id is null
group by customer_id

/* critério de rateio */
select customer_id, count(*) as criterio
from rental
group by customer_id






