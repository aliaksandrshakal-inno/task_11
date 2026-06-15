with film_actor as (
    select * from {{ ref('stg_film_actor') }}
),

film as (
    select film_id, film_title from {{ ref('stg_film') }}
),

actor as (
    select actor_id, first_name, last_name from {{ ref('stg_actor') }}
),

bridge as (
    select
        fa.film_id,
        fa.actor_id,
        f.film_title,
        a.first_name || ' ' || a.last_name as actor_full_name,
        fa.updated_at
    from film_actor fa
    left join film f on fa.film_id = f.film_id
    left join actor a on fa.actor_id = a.actor_id
)

select * from bridge