with rental_facts as (
    select * from {{ ref('int_rental_facts') }}
),

inventory as (
    select
        inventory_id,
        film_id
    from {{ ref('stg_inventory') }}
)

select
    r.rental_id,
    r.customer_id,
    i.film_id,
    r.first_payment_at as payment_at,
    cast(r.first_payment_at as date) as payment_date,
    r.amount_paid as revenue_amount,
    r.updated_at
from rental_facts r
left join inventory i
    on r.inventory_id = i.inventory_id
where r.amount_paid > 0