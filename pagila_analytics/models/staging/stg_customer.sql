with source as (
    select * from {{ source('pagila_raw', 'customer') }}
),
renamed as (
    select
        cast(customer_id as integer) as customer_id,
        cast(store_id as integer) as store_id,
        cast(first_name as varchar) as first_name,
        cast(last_name as varchar) as last_name,
        cast(email as varchar) as email,
        cast(address_id as integer) as address_id,
        cast(activebool as boolean) as is_active,
        cast(create_date as date) as created_date,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed