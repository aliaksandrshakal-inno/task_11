with film as (
    select * from {{ ref('stg_film') }}
),

film_category as (
    select * from {{ ref('stg_film_category') }}
),

category as (
    select * from {{ ref('stg_category') }}
)

select
    f.film_id,
    f.film_title,
    f.description,
    f.release_year,
    f.rental_duration_days,
    f.rental_rate,
    f.duration_minutes,
    f.replacement_cost,
    f.rating,
    coalesce(c.name, 'Unknown') as genre,
    f.updated_at
from film f
left join film_category fc on f.film_id = fc.film_id
left join category c on fc.category_id = c.category_id