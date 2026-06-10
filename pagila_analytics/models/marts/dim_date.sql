with rental_dates as (

    select cast(rental_at as date) as date_day
    from {{ ref('stg_rental') }}

    union

    select cast(returned_at as date) as date_day
    from {{ ref('stg_rental') }}
    where returned_at is not null

),

calendar as (

    select distinct date_day
    from rental_dates

)

select
    date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(quarter from date_day) as quarter,
    extract(week from date_day) as week_number,
    dayname(date_day) as day_name
from calendar