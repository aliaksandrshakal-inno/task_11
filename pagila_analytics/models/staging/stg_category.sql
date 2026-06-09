with source as (
    select * from {{ source('pagila_raw', 'category') }}
),
renamed as (
    select
        cast(category_id as integer) as category_id,
        cast(name as varchar) as name,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed