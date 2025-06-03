select cron.schedule (
    'Main', -- name of the cron job
    '* * * * *',
    $$ CALL main_cron() $$
    -- $$SET statement_timeout = '5min'; CALL public.main_cron()$$
);

select cron.schedule (
    'Clean', -- name of the cron job
    '55 * * * *',
    $$ CALL clean_data() $$
);

select cron.unschedule('Main');

select jobid, job_pid, command, username, status, return_message, start_time, end_time
from cron.job_run_details
order by start_time desc
limit 10;

SELECT jobid, jobname, schedule, command, username, active FROM cron.job;
