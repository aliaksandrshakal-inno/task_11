with actor_movie_counts as (
    select
        b.actor_full_name,
        count(b.film_id) as movie_count
    from {{ ref('int_film_actor_bridge') }} b
    left join {{ ref('dim_film') }} f on b.film_id = f.film_id
    where lower(f.genre) = 'children'
    group by 1
),

ranked_actors as (
    select
        actor_full_name,
        movie_count,
        -- DENSE_RANK выведет ВСЕХ актеров с одинаковым количеством фильмов, если они делят топ
        dense_rank() over (order by movie_count desc) as actor_rank
    from actor_movie_counts
)

select
    actor_full_name,
    movie_count
from ranked_actors
where actor_rank <= 3
order by movie_count desc