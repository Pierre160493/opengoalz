select cron.schedule (
  'Create-club', -- name of the cron job
  '0 * * * *', -- Saturday at 3:30am (GMT)
  $$ INSERT INTO clubs DEFAULT VALUES; $$
);

select *
from cron.job_run_details
order by start_time desc
limit 10;