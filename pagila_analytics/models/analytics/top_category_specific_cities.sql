with base_rental_hours as (
    select
        c.city_name,
        f.genre,
        -- Считаем разницу в часах между датой аренды и возврата
        datediff('hour', r.rental_at, r.returned_at) as rental_hours
    from {{ ref('fact_rental') }} r
    left join {{ ref('dim_film') }} f on r.film_id = f.film_id
    left join {{ ref('dim_customer') }} c on r.customer_id = c.customer_id
    where r.returned_at is not null
),

city_groups as (
    select
        genre,
        rental_hours,
        case 
            when lower(city_name) like 'a%' then 'Starts with A'
            when city_name like '%-%' then 'Contains hyphen (-)'
        end as city_group
    from base_rental_hours
    where lower(city_name) like 'a%' or city_name like '%-%'
),

aggregated as (
    select
        city_group,
        genre,
        sum(rental_hours) as total_rental_hours
    from city_groups
    where city_group is not null
    group by 1, 2
),

ranked as (
    select
        city_group,
        genre,
        total_rental_hours,
        row_number() over (partition by city_group order by total_rental_hours desc) as rn
    from aggregated
)

select
    city_group,
    genre,
    total_rental_hours
from ranked
where rn = 1