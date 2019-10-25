/* análise de granularidade */
use sakila;
select 'base table', count(*) from rental
union all
select 'fact table1', count(*) from (
select    date(rental_date) as rental_date, cast(DATE_FORMAT(rental_date,  '%H') as int) as rental_hour,  film_id, store_id, r.staff_id, r.customer_id, to_days(rental_date) as age_rental,  to_days( return_date) as age_return, sum(p.amount) as amount
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id) 
left join payment p on (r.rental_id = p.rental_id) 
 group by  date(rental_date) , DATE_FORMAT(rental_date,  '%H'),  film_id, store_id, r.staff_id, r.customer_id, date(return_date)
 ) a
union all
select 'fact table2', count(*) from (
select distinct date(rental_date) as rental_date,  film_id, customer_id, staff_id 
from rental r left join inventory i
 on (r.inventory_id = i.inventory_id)) a
;
DELIMITER $$
create or replace function rental_hash(d date, id1 int, id2 int, id3 int, id4 int) returns int
begin
	return (TO_DAYS(d)+id1 +id2 +id3 + id4);
end$$
DELIMITER ;


select    rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id) as hash, date(rental_date) as rental_date, cast(DATE_FORMAT(rental_date,  '%H') as int) as rental_hour,  film_id, store_id, r.staff_id, r.customer_id, to_days(rental_date) as days_rental,  to_days( return_date) as days_return, sum(p.amount) as amount
from rental r left join inventory i
on (r.inventory_id = i.inventory_id) 
left join payment p on (r.rental_id = p.rental_id) 
group by  rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id), date(rental_date) , DATE_FORMAT(rental_date,  '%H'),  film_id, store_id, r.staff_id, r.customer_id, date(return_date)
order by customer_id

drop table rental_log ;

CREATE TABLE rental_log (
  hash int,
   processed tinyint(1)
) 

alter table rental_log add index rental_log_index ( processed);

DELIMITER $$
CREATE or replace TRIGGER `sakila`.`rental_AFTER_INSERT` AFTER INSERT ON `rental` FOR EACH ROW
BEGIN
	insert into rental_log 
	select    rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id) as hash, 0
	from rental r left join inventory i
	on (r.inventory_id = i.inventory_id) 
	where rental_id = new.rental.id;
END$$
DELIMITER ;

select * from rental_log

delete from rental_log


 
/* carga inicial */
insert into rental_log
	select    rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id) as hash, 0
	from rental r left join inventory i
	on (r.inventory_id = i.inventory_id)
    
select    rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id) as hash, date(rental_date) as rental_date, cast(DATE_FORMAT(rental_date,  '%H') as int) as rental_hour,  film_id, store_id, r.staff_id, r.customer_id, to_days(rental_date) as days_rental,  to_days( return_date) as days_return, sum(p.amount) as amount
from rental r left join inventory i
on (r.inventory_id = i.inventory_id) 
left join payment p on (r.rental_id = p.rental_id) 
where rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id) in (select hash from rental_log where processed = 1 )
group by  rental_hash(rental_date,film_id, store_id, r.staff_id, r.customer_id), date(rental_date) , DATE_FORMAT(rental_date,  '%H'),  film_id, store_id, r.staff_id, r.customer_id, date(return_date)
order by customer_id


select * from dw.fact_rental



PARTITION BY RANGE(year(rental_date)) (
    PARTITION historico VALUES LESS THAN (1999),
    PARTITION decada_200 VALUES LESS THAN (2009),
    PARTITION decada_201 VALUES LESS THAN (2018),
    PARTITION ano_corrente VALUES LESS THAN MAXVALUE
);




/* análise de consistência */
select 'base table', sum(amount) from payment
union all
select 'fact table', sum(amount) from rental r left join payment p 
on (r.rental_id = p.rental_id)

select customer_id, sum(amount) extra_amount from payment where rental_id is null 
group by customer_id
order by customer_id
 

select sum(amount) as extra_amont from sakila.payment where rental_id is null 




select customer_id, count(*) base_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by customer_id
order by customer_id

select rental_id, customer_id, 1 criterio_rateio
from rental where customer_id in 
( select customer_id from payment where rental_id is null )
group by rental_id, customer_id

 /* dimensões */
 /* customer */
 select customer_id, concat(first_name,' ', last_name) as name , city, country	
 from customer c left join address a on (c.address_id = a.address_id)
 left join city t on (a.city_id = t.city_id)
 left join country u on (u.country_id = t.country_id)
 
 /* store */
 select store_id, address from store s left join address a on (s.address_id = a.address_id)
 
 /* film */
 select f.film_id, title, category, actor from film f 
 left join (select film_id, GROUP_CONCAT(y.name) as category from film_category fm left join category y on (fm.category_id = y.category_id) group by film_id) c on (f.film_id = c.film_id)
 left join (select film_id,  GROUP_CONCAT(concat(first_name,' ', last_name)) as actor from film_actor fa left join actor t on (fa.actor_id = t.actor_id) group by film_id) a on  (f.film_id = a.film_id) 
  
 /* staff */
 select staff_id, concat(first_name,' ', last_name) as name  from staff
 
 /* date */
 select  distinct date(rental_date) from rental 
 
 /* hour */
 select distinct DATE_FORMAT(rental_date,  '%H') as hour from rental
 
 
 
 


