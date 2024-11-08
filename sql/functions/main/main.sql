-- DROP FUNCTION public.main;

CREATE OR REPLACE FUNCTION public.main()
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
BEGIN
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses ORDER BY id) LOOP
        ------ Loop through all the weeks of the current multiverse
        WHILE now() > multiverse.date_season_start + (INTERVAL '7 days' * multiverse.week_number / multiverse.speed) LOOP

RAISE NOTICE '****** MAIN: Multiverse [%] S% WEEK %', multiverse.name, multiverse.season_number, multiverse.week_number;

            --- Simulate all the games of the current week of the current multiverse
            PERFORM simulate_week_games(
                multiverse := multiverse,
                inp_season_number := multiverse.season_number,
                inp_week_number := multiverse.week_number);

            ------ Handle club finances
            PERFORM main_handle_clubs(multiverse);

            ------ Handle players training points
            PERFORM main_handle_players(multiverse);

            ------ Handle season by populating the games
            PERFORM main_handle_season(multiverse);

            ------ Update the week number of the multiverse
            UPDATE multiverses SET week_number = week_number + 1 WHERE id = multiverse.id;

            -- Refresh the multiverse record to get the updated week_number
            SELECT * INTO multiverse FROM multiverses WHERE id = multiverse.id;

        END LOOP; -- End of the WHILE loop
    END LOOP; -- End of the loop through the multiverses
END;
$function$;