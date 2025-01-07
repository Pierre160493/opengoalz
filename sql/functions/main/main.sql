-- DROP FUNCTION public.main();

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
    FOR multiverse IN (
        SELECT * FROM multiverses)
    LOOP
        
        ------ Loop while the current date is before the next handling date
        LOOP

            ------ Refresh the multiverse record to get the updated week_number and date_handling
            SELECT *,
                date_season_start + (INTERVAL '24 hours' * (7 * (week_number-1) + day_number) / speed)
                    AS date_handling
             INTO multiverse
             FROM multiverses
             WHERE id = multiverse.id;
RAISE NOTICE '****** MAIN: Multiverse [%] S%W%D%: date_handling= % (NOW()=%)', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.day_number, multiverse.date_handling, now();

            ------ Exit the loop if the current date is after the next handling date
            EXIT WHEN multiverse.date_handling >= NOW();

            ------ Handle the transfers
            PERFORM transfers_handle_transfers(
                rec_multiverse := multiverse
            );

RAISE NOTICE '**** Debut Simulate Day %', multiverse.day_number;
            ------ Check if we can pass to the next day
            IF main_simulate_day(inp_multiverse := multiverse) = FALSE THEN
                EXIT;
            END IF;
RAISE NOTICE '**** Fin Simulate Day %', multiverse.day_number;
        
            IF multiverse.day_number = 7 THEN

                ------ Handle the clubs (weekly finances etc...)
                PERFORM main_handle_clubs(multiverse);

                ------ Handle the players (stats increase etc...)
                PERFORM main_handle_players(multiverse);

                ------ Handle season (promotions, relegations etc...)
                PERFORM main_handle_season(multiverse);

            END IF;

            ------ Update the week number of the multiverse
            UPDATE multiverses SET
                -- date_handling = date_season_start + (INTERVAL '1 day' * (7 * week_number + day_number) / speed),
                day_number = CASE 
                    WHEN day_number = 7 THEN 1
                    ELSE day_number + 1
                    END,
                week_number = CASE
                    WHEN day_number = 7 THEN week_number + 1
                    ELSE week_number
                    END
            WHERE id = multiverse.id;

            ------ Check if the multiverse is at a new season
            -- IF multiverse.week_number = 1 THEN
        --    IF multiverse.day_number = 1 THEN
        --    IF multiverse.week_number IN (10,2) AND multiverse.day_number = 1 THEN
        --        EXIT;
        --    END IF;

        END LOOP; -- End of the LOOP

        ------ Handle the transfers
        PERFORM transfers_handle_transfers(
            rec_multiverse := multiverse
        );

    END LOOP; -- End of the loop through the multiverses

RAISE NOTICE '************ END MAIN !!!';
-- RAISE EXCEPTION '************ END MAIN !!!';
END;
$function$
;