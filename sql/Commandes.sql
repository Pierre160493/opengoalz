--alter table "mails" replica identity full;
SET statement_timeout = '600min';

SELECT main_handle_multiverse(ARRAY(SELECT id FROM multiverses));

CALL clean_data();

SELECT jobid, jobname, schedule, command, username, active FROM cron.job;


select jobid, job_pid, command, username, status, return_message, start_time, end_time
from cron.job_run_details order by start_time DESC limit 120;



SELECT * FROM players WHERE expenses_target = 0


UPDATE multiverses m SET is_active = true WHERE id = 2