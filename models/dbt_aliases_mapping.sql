/*

The first intent is to be able to link all events from the same user via some common identifier. Rudder data payload contains two fields anonymous_id and user_id. The first is device specific and generated by the Rudder SDK, the second is the user identifier that can be assigned by application code depending on a user’s registration or login. 

Typically a user would login to an application at least once while using the application on a particular device. The user_id should then become available and be included in event messages. Below code creates a unique identifier dbt_visitor_id that links the user_id to the anonymous_id. The analytic function first_value has been used here

*/

{{ config(materialized='table') }}

  with
      dbt_all_mappings as (
        select anonymous_id
          , user_id
          , timestamp as timestamp 
        from {{ source("schema","tracks")}}

        union distinct

        select user_id
          , null
          , timestamp 
        from {{ source("schema","tracks")}}

      )

      select
          distinct anonymous_id as alias
          ,coalesce(first_value(user_id IGNORE NULLS)
              over(
                partition by anonymous_id
                order by timestamp desc
                rows between unbounded preceding and unbounded following), user_id, anonymous_id) as dbt_visitor_id
        from dbt_all_mappings
