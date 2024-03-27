select cron.schedule (
    'simulate all games', -- name of the cron job
    '*/15 * * * *', -- Saturday at 3:30am (GMT)
    $$ select simulate_games() $$
);