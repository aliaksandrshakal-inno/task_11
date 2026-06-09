with source as (
    select * from {{ source('pagila_raw', 'film') }}
),
renamed as (
    select
        cast(film_id as integer) as film_id,
        cast(title as varchar) as film_title,
        cast(description as varchar) as description,
        cast(release_year as integer) as release_year,
        cast(language_id as integer) as language_id,
        cast(rental_duration as integer) as rental_duration_days,
        cast(rental_rate as numeric(4,2)) as rental_rate,
        cast(length as integer) as duration_minutes,
        cast(replacement_cost as numeric(5,2)) as replacement_cost,
        cast(rating as varchar) as rating,
        cast(last_update as timestamp) as updated_at
    from source
)
select * from renamed