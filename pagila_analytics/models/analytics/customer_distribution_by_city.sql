select
    city_name,
    count(case when is_active = true then 1 end) as active_customers,
    count(case when is_active = false then 1 end) as inactive_customers
from {{ ref('dim_customer') }}
group by 1
order by inactive_customers desc