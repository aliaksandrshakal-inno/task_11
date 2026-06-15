with customer as (
    select * from {{ ref('stg_customer') }}
),

address as (
    select * from {{ ref('stg_address') }}
),

city as (
    select * from {{ ref('stg_city') }}
),

enriched as (
    select
        c.customer_id,
        c.store_id,
        c.first_name,
        c.last_name,
        -- Объединяем имя и фамилию для удобства аналитиков
        c.first_name || ' ' || c.last_name as full_name,
        c.email,
        c.is_active,
        c.created_date,
        
        -- Вытаскиваем гео-данные из связанных таблиц
        a.address,
        a.district,
        a.postal_code,
        a.phone,
        coalesce(ci.city, 'Unknown') as city_name,
        
        c.updated_at
    from customer c
    left join address a on c.address_id = a.address_id
    left join city ci on a.city_id = ci.city_id
)

select * from enriched