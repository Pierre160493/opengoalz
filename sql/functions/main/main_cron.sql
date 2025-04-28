CREATE OR REPLACE PROCEDURE public.main_cron()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
    lock_exists BOOLEAN;   -- Variable to check if the lock exists
BEGIN

    ------ Uncomment the following line to deactivate the cron
    RAISE EXCEPTION '************ KILL THE CRON !!!';

    -- Acquire a SHARE lock on the multiverses table to allow reads but prevent writes
    LOCK TABLE multiverses IN SHARE MODE;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    FOR rec_multiverse IN (
        SELECT * FROM multiverses
        WHERE error IS NULL -- Do not run multiverses on error to save time and resources
        ORDER BY id
    )
    LOOP
        -- Start a new transaction for each multiverse
        BEGIN
            ---- Handle the multiverse
            PERFORM main_handle_multiverse(ARRAY[rec_multiverse.id]);

        EXCEPTION
            WHEN OTHERS THEN
                -- Rollback the transaction in case of an error
                ROLLBACK;
                RAISE NOTICE 'Error processing multiverse %: %', rec_multiverse.id, SQLERRM;

                -- Store the error message in the multiverse record
                UPDATE multiverses SET
                    error = SQLERRM
                WHERE id = rec_multiverse.id;
        END;
        
        ------ Commit the transaction for the current multiverse
        COMMIT;
    END LOOP; -- End of the loop through the multiverses

END;
$procedure$;
