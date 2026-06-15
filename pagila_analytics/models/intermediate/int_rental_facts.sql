with rental as (
    select * from {{ ref('stg_rental') }}
),

payment as (
    -- Группируем платежи, чтобы исключить дубли, если по одной аренде было несколько транзакций
    select
        rental_id,
        customer_id,
        sum(amount) as total_paid_amount,
        min(payment_at) as first_payment_at
    from {{ ref('stg_payment') }}
    group by 1, 2
),

joined as (
    select
        r.rental_id,
        r.customer_id,
        r.inventory_id,
        r.staff_id,
        r.rental_at,
        r.returned_at,
        
        -- Считаем реальную длительность аренды в днях
        datediff('day', r.rental_at, r.returned_at) as actual_rental_duration_days,
        
        -- Подтягиваем деньги
        coalesce(p.total_paid_amount, 0) as amount_paid,
        p.first_payment_at,
        
        -- Флаг: возвращен ли фильм
        case when r.returned_at is not null then true else false end as is_returned,
        
        r.updated_at
    from rental r
    left join payment p on r.rental_id = p.rental_id
)

select * from joined