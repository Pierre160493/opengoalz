-- DROP FUNCTION public.main();

CREATE OR REPLACE FUNCTION public.main()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    bool_week_finished BOOLEAN;
    start_time TIMESTAMP;
BEGIN

    ------ Check if the function is alreay running
    IF (SELECT is_running FROM multiverses WHERE id = 1) IS TRUE THEN
        RAISE NOTICE 'Function is already running';
        RETURN;
    END IF;

    ------ Store that the multiverses are being handled
    UPDATE multiverses SET is_running = TRUE WHERE id = 1;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    RAISE NOTICE '************ MAIN: Now()= %', now();
    FOR multiverse IN (SELECT * FROM multiverses ORDER BY id) LOOP
        RAISE NOTICE '****** MAIN: Multiverse [%] S%W%: date_now= %', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.date_now;
        
        ------ Loop through all the weeks of the current multiverse that need to be simulated
        --WHILE now() > multiverse.date_season_start + (INTERVAL '7 days' * (multiverse.week_number - 1) / multiverse.speed) LOOP
        WHILE now() > multiverse.date_now LOOP
            RAISE NOTICE '****** MAIN: Multiverse [%] Handling S% WEEK %: date_now= %', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.date_now;

            ------ Handle the transfers
            PERFORM transfers_handle_transfers(
                rec_multiverse := multiverse
            );
        
            -- Measure time for simulate_week_games
--RAISE NOTICE '*** MAIN: Running Simulate Games...';
start_time := clock_timestamp();
            bool_week_finished := simulate_week_games(
                multiverse := multiverse,
                inp_season_number := multiverse.season_number,
                inp_week_number := multiverse.week_number);
--RAISE NOTICE '=> Took: % seconds', EXTRACT(EPOCH FROM (clock_timestamp() - start_time));
        
            if bool_week_finished = FALSE THEN
                RAISE NOTICE '****** MAIN: Multiverse [%] S% WEEK % is not finished yet', multiverse.name, multiverse.season_number, multiverse.week_number;
                EXIT;
            END IF;
        
            -- Measure time for main_handle_clubs
--RAISE NOTICE '*** MAIN: Running Handle Clubs...';
start_time := clock_timestamp();
            PERFORM main_handle_clubs(multiverse);
--RAISE NOTICE 'XXXXXX => Took: % seconds', EXTRACT(EPOCH FROM (clock_timestamp() - start_time));

            -- Measure time for main_handle_players
--RAISE NOTICE '*** MAIN: Running Handle Players...';
start_time := clock_timestamp();
            PERFORM main_handle_players(multiverse);
--RAISE NOTICE '=> Took: % seconds', EXTRACT(EPOCH FROM (clock_timestamp() - start_time));

            -- Measure time for main_handle_season
-- RAISE NOTICE '*** MAIN: Running Handle Season...';
start_time := clock_timestamp();
            PERFORM main_handle_season(multiverse);
--RAISE NOTICE '=> Took: % seconds', EXTRACT(EPOCH FROM (clock_timestamp() - start_time));

            ------ Update the week number of the multiverse
            UPDATE multiverses SET
                date_now = date_season_start + (INTERVAL '7 days' * week_number / speed),
                week_number = week_number + 1
            WHERE id = multiverse.id;

            -- Refresh the multiverse record to get the updated week_number
            SELECT * INTO multiverse FROM multiverses WHERE id = multiverse.id;

        END LOOP; -- End of the WHILE loop

        ------ Handle the transfers
        PERFORM transfers_handle_transfers(
            rec_multiverse := multiverse
        );

    END LOOP; -- End of the loop through the multiverses
    RAISE NOTICE '****** END MAIN: Multiverse [%] S% WEEK %', multiverse.name, multiverse.season_number, multiverse.week_number;

    ------ Reset the is_running boolean
    UPDATE multiverses SET is_running = FALSE WHERE id = 1;

END;
$function$
;