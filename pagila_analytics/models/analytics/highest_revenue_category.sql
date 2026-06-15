select
    f.genre,
    sum(r.amount_paid) as total_revenue
from {{ ref('fact_rental') }} r
left join {{ ref('dim_film') }} f on r.film_id = f.film_id
group by 1
order by total_revenue desc
limit 1