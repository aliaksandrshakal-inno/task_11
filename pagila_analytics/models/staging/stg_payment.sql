with source as (
    select * from {{ source('pagila_raw', 'payment') }}
),
renamed as (
    select
        cast(payment_id as integer) as payment_id,
        cast(customer_id as integer) as customer_id,
        cast(staff_id as integer) as staff_id,
        cast(rental_id as integer) as rental_id,
        cast(amount as numeric(5,2)) as amount,
        cast(payment_date as timestamp) as payment_at
    from source
)
select * from renamed