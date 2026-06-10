select
    customer_id,
    store_id,
    full_name,
    email,
    is_active,
    address,
    district,
    postal_code,
    phone,
    city_name,
    created_date,
    updated_at
from {{ ref('int_customer_enriched') }}