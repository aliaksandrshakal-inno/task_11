select
    genre,
    count(film_id) as total_movies
from {{ ref('dim_film') }}
group by 1
order by total_movies desc