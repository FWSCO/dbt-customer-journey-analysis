/*

a decision is made to treat two events, for the same user, that are separated by 30 minutes or more - as belonging to two different user sessions. the choice of 30 minutes is arbitrary and can be modified as per requirements. sequence number is assigned to each event within a particular session. also, the timestamp for the first event in the session is considered as session start time. start time of the next session is also calculated.

*/

{{ config(materialized='table') }}

select
    concat(cast(row_number() over (partition by dbt_visitor_id order by timestamp) as string), ' - ', dbt_visitor_id) as session_id,
    dbt_visitor_id,
    timestamp as session_start_at,
    row_number() over (partition by dbt_visitor_id order by timestamp) as session_sequence_number,
    lead(timestamp) over (partition by dbt_visitor_id order by timestamp) as next_session_start_at
from {{ ref('dbt_mapped_tracks') }}
where (idle_time_minutes > 30 or idle_time_minutes is null)
