with source as (
    select * from {{ source('pagila_raw', 'actor') }}
),
renamed as (
    select
        cast(actor_id as integer) as actor_id,
        cast(first_name as varchar) as first_name,
        cast(last_name as varchar) as last_name,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed