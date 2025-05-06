-- DROP FUNCTION public.reset_project();

CREATE OR REPLACE FUNCTION public.reset_project()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    table_name TEXT;
    multiverse RECORD; -- Record of the multiverse
    loc_date_start timestamp with time zone;
    loc_interval_1_week INTERVAL; -- Time for a week in a given multiverse
BEGIN

    PERFORM set_config('statement_timeout', '5min', true);

    -- List of table names to alter sequences
    FOR table_name IN
        SELECT unnest(ARRAY[
        'multiverses'
        ,'leagues'
        ,'clubs', 'clubs_history', 'clubs_history_weekly'
        ,'players', 'players_history', 'players_history_stats', 'players_favorite', 'players_poaching'
        ,'games', 'game_events', 'games_teamcomp', 'game_orders', 'game_stats', 'game_player_stats_all', 'game_player_stats_best'
        ,'finances'
        ,'mails'
        ]) -- Add your table names here
    LOOP
	    -- Delete tables
	    EXECUTE 'TRUNCATE TABLE ' || quote_ident(table_name) || ' CASCADE;';
	    
        -- Construct and execute the ALTER SEQUENCE command for each table
        EXECUTE 'ALTER SEQUENCE ' || pg_get_serial_sequence(table_name, 'id') || ' RESTART WITH 1';
    END LOOP;

    --UPDATE profiles SET id_default_club = NULL;

    INSERT INTO public.multiverses (id, date_season_start, speed, name) VALUES 
    (1, date_trunc('week', NOW()) + INTERVAL '5 days 20 hours', 1, 'The Original'), -- 1 game per week
    (2, date_trunc('week', NOW()) + INTERVAL '5 days 20 hours', 2, 'The Second'), -- 2 games per week
    (3, date_trunc('week', NOW()) + INTERVAL '20 hours', 7, 'The Lucky Seven'), -- 1 game per day
    (4, date_trunc('week', NOW()) + INTERVAL '20 hours', 14, 'The Double Seven'), -- 2 games per day
    (5, date_trunc('day', NOW()), 168, 'The Very Fast'), -- Every hour
    (6, date_trunc('hour', NOW()), 1008, 'The Ultra Fast'); -- Every 10 minutes

--     FOR multiverse IN (
--         SELECT * FROM multiverses
--         --WHERE speed = 1
--         )
--     LOOP
        
--         -- Multiverse interval for 1 week
--         loc_interval_1_week := INTERVAL '7 days' / multiverse.speed;
        
--         -- When the season starts (TWEAK HERE FOR MODIFING GAMES ORGANIZATION)
-- --        loc_date_start := date_trunc('week', current_date) + INTERVAL '5 days 20 hours' - (loc_interval_1_week * 5);
--         --loc_date_start := date_trunc('week', current_date) + INTERVAL '20 hours' - (loc_interval_1_week * 12);
--         --loc_date_start := date_trunc('hour', CURRENT_TIMESTAMP) - (loc_interval_1_week * 15);
--         loc_date_start := date_trunc('hour', CURRENT_TIMESTAMP); -- + INTERVAL '1 hour';

--         -- Update multiverse row
--         UPDATE multiverses SET
--             date_season_start = loc_date_start,
--             date_season_end = loc_date_start + (loc_interval_1_week * 14),
--             season_number = 1, week_number = 1, day_number = 1,
--             cash_printed = 0,
--             last_run = now(), error = NULL
--             WHERE speed = multiverse.speed;
        
--         -- Generate leagues, clubs and players
--         PERFORM multiverse_initialize_leagues_teams_and_players(multiverse.id);

--     END LOOP;

    --INSERT INTO game_orders (id_teamcomp, id_player_out, id_player_in, minute)
    --VALUES (1, 1, 2, 40);

    --UPDATE clubs SET cash = 100000 WHERE id IN (1,2);
    --UPDATE clubs SET cash = -100000 WHERE id = 3;

    -- Set clubs to test user
    --update clubs set id_country = 83, username='zOuateRabbit' WHERE id IN (44);
    --update clubs set id_country = 83, username='Mathiasdelabitas', name = 'Mat FC' WHERE id in (43);
    --update clubs set username='Mathiasdelabitas' WHERE id IN(2,3,4,5,6);
    --update players set username='zOuateRabbit' where id in (1,2,3);
    --update players set username='Mathiasdelabitas' where id in (4,5,6);

    -- Simulate games
    --CALL main();

END $function$
;
