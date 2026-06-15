with source as (
    select * from {{ source('pagila_raw', 'city') }}
),
renamed as (
    select
        cast(city_id as integer) as city_id,
        cast(city as varchar) as city,
        cast(country_id as integer) as country_id,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed