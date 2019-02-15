use sakila;


/* análise de granularidade */
select 'rental/inventory' as dimensions ,count(*) as granalarity  from rental r inner join inventory i on (r.inventory_id = i.inventory_id)
union all
select 'rental_datetime',count(*) from (
select  rental_date  from rental group by rental_date) a
union all
select 'rental_hour',count(*) from (
select  DATE_FORMAT(rental_date,  '%H')  from rental group by DATE_FORMAT(rental_date,  '%H')) a
union all
select 'rental_date',count(*) from (
select  date(rental_date)  from rental group by date(rental_date)) a
union all
select 'rental_date/hour, customer, film, store',count(*) as granalarity from (
select  date(rental_date), DATE_FORMAT(rental_date,  '%H'), first_name || last_name as customer, film_id, i.store_id from rental r inner join customer c on (r.customer_id = c.customer_id) inner join inventory i on (r.inventory_id = i.inventory_id) group by date(rental_date), DATE_FORMAT(rental_date,  '%H'),first_name || last_name) a

/* análise de consistência */
select sum(amount) as consitency from payment
union all
select  sum(amount) from rental r left join customer c on (r.customer_id = c.customer_id) 
left join inventory i on (r.inventory_id = i.inventory_id) 
left join payment p on (r.rental_id = p.rental_id) 

select * from payment p where not exists (select 1 from rental r where r.rental_id = p.rental_id)


