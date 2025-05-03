CREATE OR REPLACE FUNCTION public.main_handle_multiverse(
    id_multiverses BIGINT[])
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
BEGIN

    -- Acquire a SHARE lock on the multiverses table to allow reads but prevent writes
    -- LOCK TABLE multiverses IN SHARE MODE;

    RAISE NOTICE '****** START: main_handle_multiverse !';
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    FOR rec_multiverse IN (
        SELECT * FROM multiverses
        WHERE id = ANY(id_multiverses)
        AND is_active = TRUE -- Only run active multiverses
    )
    LOOP
        ------ Loop while the current date is before the next handling date
        LOOP
            ------ Refresh the multiverse record to get the updated week_number and date_handling
            SELECT *,
                date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number) / speed)
                    AS date_handling
            INTO rec_multiverse
            FROM multiverses
            WHERE id = rec_multiverse.id;

            ------ Calculate the time of the next handling of the multiverse
            -- loc_time_of_next_handling := rec_multiverse.date_handling - now();

            ------ If it's in the future, exit the loop and wait for the next handling
            -- IF (rec_multiverse.date_handling - now()) > INTERVAL '0 seconds' THEN
            IF (rec_multiverse.date_next_handling - now()) > INTERVAL '0 seconds' THEN
                RAISE NOTICE '*** %: Multiverse [%]: S%W%D%: date_handling= % (NOW()=%) ==> NOT YET', clock_timestamp() - statement_timestamp(), rec_multiverse.name, rec_multiverse.season_number, rec_multiverse.week_number, rec_multiverse.day_number, rec_multiverse.date_handling, now();
                EXIT;
            ELSE
                RAISE NOTICE '*** %: Multiverse [%]: S%W%D%: date_handling= % (NOW()=%) ==> YES SIMULATE', clock_timestamp() - statement_timestamp(), rec_multiverse.name, rec_multiverse.season_number, rec_multiverse.week_number, rec_multiverse.day_number, rec_multiverse.date_handling, now();
            END IF;

            ------ Handle the transfers
            PERFORM transfers_handle_transfers(
                inp_multiverse := rec_multiverse
            );

            ------ Check if we can pass to the next day
            IF main_simulate_day(inp_multiverse := rec_multiverse) = FALSE THEN
                EXIT;
            END IF;

            IF rec_multiverse.day_number = 7 THEN

                ------ Handle the clubs (weekly finances etc...)
                PERFORM main_handle_clubs(rec_multiverse);
                ------ Handle the players (stats increase etc...)
                PERFORM main_handle_players(rec_multiverse);
                ------ Handle season (promotions, relegations etc...)
                PERFORM main_handle_season(rec_multiverse);

            END IF;

            ------ Update the week number of the multiverse
            UPDATE multiverses SET
                day_number = CASE
                    WHEN day_number = 7 THEN 1
                    ELSE day_number + 1
                    END,
                week_number = CASE
                    WHEN day_number = 7 THEN week_number + 1
                    ELSE week_number
                    END
            WHERE id = rec_multiverse.id;

            ------ Avoid handling more than a full week in one run
            IF rec_multiverse.day_number = 1 THEN
                EXIT;
            END IF;
        END LOOP; -- End of the LOOP

        ------ Handle the transfers
        PERFORM transfers_handle_transfers(
            inp_multiverse := rec_multiverse
        );

        ------ Store the last run date of the multiverse
        UPDATE multiverses SET
            last_run = now(),
            date_next_handling = GREATEST(
                rec_multiverse.date_handling,
                date_trunc('minute', now()) + INTERVAL '1 minute'), -- Remove all the functions in queues from cron
            error = NULL
        WHERE id = rec_multiverse.id;
        
    END LOOP; -- End of the loop through the multiverses

    RAISE NOTICE '****** END: main_handle_multiverse !';
END;
$function$;
