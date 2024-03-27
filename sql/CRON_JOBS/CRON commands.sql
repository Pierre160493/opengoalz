###### List all cron runs
select *
from cron.job_run_details
order by start_time desc
limit 10;

###### List all crons
SELECT *
FROM cron.job;

###### Remove cron job
select cron.unschedule('Create-club');