--alter table "mails" replica identity full;
SET statement_timeout = '600min';

SELECT main_handle_multiverse(ARRAY(SELECT id FROM multiverses));

SELECT jobid, jobname, schedule, command, username, active FROM cron.job;


select jobid, job_pid, command, username, status, return_message, start_time, end_time
from cron.job_run_details
order by start_time desc
limit 10;
 

DELETE FROM cron.job_run_details WHERE start_time IS null