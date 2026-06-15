with source as (
    select * from {{ source('pagila_raw', 'inventory') }}
),
renamed as (
    select
        cast(inventory_id as integer) as inventory_id,
        cast(film_id as integer) as film_id,
        cast(store_id as integer) as store_id,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed