select cron.schedule (
    'Main', -- name of the cron job
    '* * * * *',
    $$ CALL main_cron() $$
);

select cron.schedule (
    'Clean', -- name of the cron job
    '55 * * * *',
    $$ CALL clean_data() $$
);


select cron.unschedule('Main');

select cron.schedule (
    'Handle transfers', -- name of the cron job
    '* * * * *', -- Every minute
    $$ select cron_handle_transfers() $$
);

select *
from cron.job_run_details
order by start_time desc
limit 10;

SELECT * FROM cron.job;
