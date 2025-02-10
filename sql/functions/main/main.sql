CREATE OR REPLACE PROCEDURE public.main(
    is_cron BOOLEAN DEFAULT FALSE)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    loc_time_of_next_handling INTERVAL; -- Variable to store the time of the next handling
BEGIN

    IF is_cron IS TRUE THEN
        -- RAISE EXCEPTION '************ KILL THE CRON !!!';
    END IF;

    -- Acquire a SHARE lock on the multiverses table to allow reads but prevent writes
    LOCK TABLE multiverses IN SHARE MODE;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    FOR multiverse IN (
        SELECT * FROM multiverses
        -- WHERE (is_cron IS FALSE OR error IS NULL) -- When cron, do not run multiverses on error
        ORDER BY id
    )
    LOOP
        -- Start a new transaction for each multiverse
        -- BEGIN
            ------ Loop while the current date is before the next handling date
            LOOP
                ------ Refresh the multiverse record to get the updated week_number and date_handling
                SELECT *,
                    date_season_start + (INTERVAL '24 hours' * (7 * (week_number - 1) + day_number) / speed)
                        AS date_handling
                INTO multiverse
                FROM multiverses
                WHERE id = multiverse.id;

                ------ Calculate the time of the next handling of the multiverse
                loc_time_of_next_handling := multiverse.date_handling - now();

                ------ If it's in the future, exit the loop and wait for the next handling
                IF loc_time_of_next_handling > INTERVAL '0 seconds' THEN
                    RAISE NOTICE '****** MAIN: %: S%W%D%: date_handling= % (NOW()=%) NO ==> %', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.day_number, multiverse.date_handling, now(), loc_time_of_next_handling;
                    EXIT;
                ELSE
                    RAISE NOTICE '****** MAIN: %: S%W%D%: date_handling= % (NOW()=%) YES ==> %', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.day_number, multiverse.date_handling, now(), loc_time_of_next_handling;
                END IF;

                ------ Handle the transfers
                PERFORM transfers_handle_transfers(
                    inp_multiverse := multiverse
                );
                COMMIT;

                ------ Check if we can pass to the next day
                IF main_simulate_day(inp_multiverse := multiverse) = FALSE THEN
                    EXIT;
                END IF;

                IF multiverse.day_number = 7 THEN
    
                    ------ Handle the clubs (weekly finances etc...)
                    PERFORM main_handle_clubs(multiverse);

                    ------ Handle the players (stats increase etc...)
                    PERFORM main_handle_players(multiverse);

                    ------ Handle season (promotions, relegations etc...)
                    PERFORM main_handle_season(multiverse);
                END IF;

                RAISE NOTICE '**** MAIN: Multiverse [%] S%W%D%: Incrementing to next day for handling', multiverse.name, multiverse.season_number, multiverse.week_number, multiverse.day_number;
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
                WHERE id = multiverse.id;

                ------ Avoid handling more than a full week in one run
                IF multiverse.day_number = 1 THEN
                    EXIT;
                END IF;
            END LOOP; -- End of the LOOP

            ------ Handle the transfers
            PERFORM transfers_handle_transfers(
                inp_multiverse := multiverse
            );

            ------ Store the last run date of the multiverse
            UPDATE multiverses SET
                last_run = now(),
                date_next_handling = multiverse.date_handling,
                error = NULL
            WHERE id = multiverse.id;

            -- IF multiverse.id = 2 THEN
            --     RAISE NOTICE 'STOP THE SECOND MULTIVERSE';
            --     RAISE EXCEPTION 'STOP THE SECOND MULTIVERSE';
            -- END IF;

        -- EXCEPTION

        --     WHEN OTHERS THEN
        --         -- Rollback the transaction in case of an error
        --         ROLLBACK;
        --         RAISE NOTICE 'Error processing multiverse %: %', multiverse.id, SQLERRM;

        --         -- Raise exception when not in cron mode
        --         IF is_cron IS FALSE THEN
        --             RAISE EXCEPTION 'Error processing multiverse %: %', multiverse.id, SQLERRM;
        --         END IF;

        --         -- Store the error message in the multiverse record
        --         UPDATE multiverses SET
        --             error = SQLERRM
        --         WHERE id = multiverse.id;
        -- END;
        ------ Commit the transaction for the current multiverse
        COMMIT;
    END LOOP; -- End of the loop through the multiverses

    ------ Cleanup
    ---- Delete mails that must be deleted
    DELETE FROM mails WHERE now() > date_delete;

    ---- Delete mails if more than 900 mails per club
    WITH ranked_mails AS (
        SELECT
            id,
            ROW_NUMBER() OVER (PARTITION BY id_club_to ORDER BY created_at DESC) AS rn
        FROM mails
        WHERE is_favorite = FALSE
    )
    DELETE FROM mails
    WHERE id IN (
        SELECT id
        FROM ranked_mails
        WHERE rn > 900
    );    

    ------ Delete the players poaching
    DELETE FROM players_poaching
    WHERE to_delete = TRUE
    AND affinity < 0;

    RAISE NOTICE '************ END MAIN !!!';
    -- RAISE EXCEPTION '************ END MAIN !!!';
END;
$procedure$;
