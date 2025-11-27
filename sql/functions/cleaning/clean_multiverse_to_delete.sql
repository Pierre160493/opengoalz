CREATE OR REPLACE PROCEDURE public.clean_multiverse_to_delete()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_multiverse_record RECORD;
    v_rows_deleted INT;
    v_batch_size INT := 1000; -- Adjust batch size based on your IO limits
    v_start_time TIMESTAMP;
    v_step_start_time TIMESTAMP;
BEGIN
    FOR v_multiverse_record IN SELECT id FROM multiverses WHERE date_delete < NOW() LOOP
        v_start_time := clock_timestamp();
        RAISE WARNING '%: Starting deletion of multiverse %', clock_timestamp(), v_multiverse_record.id;

        ---------------------------------------------------------------------------
        -- 1. Delete Games (and cascading game_events, stats, etc.)
        ---------------------------------------------------------------------------
        v_step_start_time := clock_timestamp();
        RAISE WARNING '%: Deleting games...', clock_timestamp();
        
        -- 1a. Break self-references to avoid FK violations during batch deletion
        RAISE WARNING '%: Breaking self-references in games...', clock_timestamp();
        UPDATE games
        SET id_game_club_left = NULL,
            id_game_club_right = NULL,
            is_return_game_id_game_first_round = NULL
        WHERE id_multiverse = v_multiverse_record.id;
        COMMIT;
        
        -- 1b. Delete all games
        RAISE WARNING '%: Deleting all games...', clock_timestamp();
        LOOP
            DELETE FROM games
            WHERE id IN (
                SELECT id FROM games
                WHERE id_multiverse = v_multiverse_record.id
                LIMIT v_batch_size
            );
            
            GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
            RAISE WARNING '%: Deleted % games', clock_timestamp(), v_rows_deleted;
            
            -- Exit if no more rows to delete
            EXIT WHEN v_rows_deleted = 0;
            
            COMMIT; -- Commit each batch to free up resources
        END LOOP;
        RAISE WARNING '%: Games deletion completed in %', clock_timestamp(), clock_timestamp() - v_step_start_time;

        ---------------------------------------------------------------------------
        -- 2. Delete Players (and cascading history, stats, etc.)
        ---------------------------------------------------------------------------
        v_step_start_time := clock_timestamp();
        RAISE WARNING '%: Deleting players...', clock_timestamp();
        LOOP
            DELETE FROM players
            WHERE id IN (
                SELECT id FROM players
                WHERE id_multiverse = v_multiverse_record.id
                LIMIT v_batch_size
            );
            
            GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
            RAISE WARNING '%: Deleted % players', clock_timestamp(), v_rows_deleted;
            
            EXIT WHEN v_rows_deleted = 0;
            COMMIT;
        END LOOP;
        RAISE WARNING '%: Players deletion completed in %', clock_timestamp(), clock_timestamp() - v_step_start_time;

        ---------------------------------------------------------------------------
        -- 3. Delete Clubs (and cascading history, finances, etc.)
        ---------------------------------------------------------------------------
        v_step_start_time := clock_timestamp();
        RAISE WARNING '%: Deleting clubs...', clock_timestamp();
        LOOP
            DELETE FROM clubs
            WHERE id IN (
                SELECT id FROM clubs
                WHERE id_multiverse = v_multiverse_record.id
                LIMIT v_batch_size
            );
            
            GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
            RAISE WARNING '%: Deleted % clubs', clock_timestamp(), v_rows_deleted;
            
            EXIT WHEN v_rows_deleted = 0;
            COMMIT;
        END LOOP;
        RAISE WARNING '%: Clubs deletion completed in %', clock_timestamp(), clock_timestamp() - v_step_start_time;

        ---------------------------------------------------------------------------
        -- 4. Delete Multiverse
        ---------------------------------------------------------------------------
        v_step_start_time := clock_timestamp();
        RAISE WARNING '%: Deleting multiverse record...', clock_timestamp();
        DELETE FROM multiverses WHERE id = v_multiverse_record.id;
        RAISE WARNING '%: Multiverse record deletion completed in %', clock_timestamp(), clock_timestamp() - v_step_start_time;
        
        RAISE WARNING '%: Multiverse % deleted successfully. Total duration: %', clock_timestamp(), v_multiverse_record.id, clock_timestamp() - v_start_time;
    END LOOP;
END;
$procedure$;
