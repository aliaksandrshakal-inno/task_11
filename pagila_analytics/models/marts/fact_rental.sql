with rental_facts as (
    select * from {{ ref('int_rental_facts') }}
),

inventory as (
    select inventory_id, film_id from {{ ref('stg_inventory') }}
)

select
    r.rental_id,
    r.customer_id,
    i.film_id, -- Теперь мы знаем, какой именно фильм был арендован!
    r.staff_id,
    r.rental_at,
    r.returned_at,
    r.actual_rental_duration_days,
    r.amount_paid,
    r.is_returned,
    r.updated_at
from rental_facts r
left join inventory i on r.inventory_id = i.inventory_id