with actor as (
    select * from {{ ref('stg_actor') }}
)

select
    actor_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as actor_full_name,
    updated_at
from actor