with rental_shares as (
    select
        r.rental_id,
        b.actor_full_name
    from {{ ref('fact_rental') }} r
    -- Используем наш промежуточный мост между актерами и фильмами
    inner join {{ ref('int_film_actor_bridge') }} b on r.film_id = b.film_id
)

select
    actor_full_name,
    count(rental_id) as total_rentals
from rental_shares
group by 1
order by total_rentals desc
limit 10