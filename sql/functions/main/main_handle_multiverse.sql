CREATE OR REPLACE FUNCTION public.main_handle_multiverse(
    id_multiverses BIGINT[])
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
BEGIN

    RAISE NOTICE '****** START: main_handle_multiverse !';

    -- Loop through all multiverses that need handling
    FOR rec_multiverse IN (
        SELECT *,
            date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number) / speed) AS date_handling
        FROM multiverses
        WHERE id = ANY(id_multiverses)
        AND is_active = TRUE
        AND date_next_handling <= now() -- Only process due multiverses
    )
    LOOP
        RAISE NOTICE '*** Processing Multiverse [%]: S%W%D%: date_next_handling= % (NOW()=%)', rec_multiverse.name, rec_multiverse.season_number, rec_multiverse.week_number, rec_multiverse.day_number, rec_multiverse.date_next_handling, now();

        -- Handle the transfers
        PERFORM transfers_handle_transfers(
            inp_multiverse := rec_multiverse
        );

        -- Simulate the day
        IF main_simulate_day(inp_multiverse := rec_multiverse) = FALSE THEN
            RAISE NOTICE '*** Multiverse [%]: Simulation stopped for today.', rec_multiverse.name;
            CONTINUE;
        END IF;

        -- Handle weekly and seasonal updates if it's the end of the week
        IF rec_multiverse.day_number = 7 THEN
            PERFORM main_handle_clubs(rec_multiverse);
            PERFORM main_handle_players(rec_multiverse);
            PERFORM main_handle_season(rec_multiverse);
        END IF;

        -- Update the multiverse's day and week
        UPDATE multiverses SET
            day_number = CASE
                WHEN day_number = 7 THEN 1
                ELSE day_number + 1
                END,
            week_number = CASE
                WHEN day_number = 7 THEN week_number + 1
                ELSE week_number
                END,
            date_next_handling =
                GREATEST(
                    date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number + 1) / speed),
                    date_trunc('minute', now()) + INTERVAL '1 minute'),
            last_run = now(),
            error = NULL
        WHERE id = rec_multiverse.id;

        RAISE NOTICE '*** Multiverse [%]: Successfully processed.', rec_multiverse.name;
    END LOOP;

    RAISE NOTICE '****** END: main_handle_multiverse !';
END;
$function$;
