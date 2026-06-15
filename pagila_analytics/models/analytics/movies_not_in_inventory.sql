select
    f.film_title
from {{ ref('dim_film') }} f
-- Изящно обходим IN через LEFT JOIN + проверку на NULL
left join {{ ref('stg_inventory') }} i on f.film_id = i.film_id
where i.inventory_id is null