with source as(
    select * from {{ source('pagila_raw', 'address') }}
),
renamed as (
    select
        
        cast(address_id as integer) as address_id,
        cast(address as varchar) as address,
        cast(address2 as varchar) as address2,
        cast(district as varchar) as district,
        cast(city_id as integer) as city_id,
        cast(postal_code as varchar) as postal_code,
        cast(phone as varchar) as phone,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed
        