with source as (
    select * from {{ source('pagila_raw', 'film_category') }}
),
renamed as (
    select
        cast(film_id as integer) as film_id,
        cast(category_id as integer) as category_id,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed