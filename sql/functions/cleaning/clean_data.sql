CREATE OR REPLACE PROCEDURE public.clean_data()
LANGUAGE plpgsql
AS $procedure$
DECLARE
    rec_multiverse RECORD; -- Record for the multiverses loop
BEGIN

    FOR rec_multiverse IN (
        SELECT * FROM multiverses
        ORDER BY id
    )
    LOOP
    
        -- Clean the old games
        DELETE FROM games WHERE id_multiverse = rec_multiverse.id AND season_number < rec_multiverse.season_number - 30;

        -- -- Delete the old games_teamcomp ==> games_orders
        -- DELETE FROM games_teamcomp
        -- USING clubs
        -- WHERE games_teamcomp.id_club = clubs.id
        -- AND clubs.id_multiverse = inp_multiverse_id
        -- AND games_teamcomp.season_number < (SELECT season_number FROM multiverses WHERE id = inp_multiverse_id) - 30
        -- AND games_teamcomp.season_number > 0;

        -- Delete the game_player_stats_all because it takes too much space
        DELETE FROM game_player_stats_all WHERE id_game IN (
            SELECT id FROM games 
            WHERE id_multiverse = rec_multiverse.id
            AND season_number < rec_multiverse.season_number); -- Keep only last season stats
    
    END LOOP;

    -- Delete mails that must be deleted
    DELETE FROM mails WHERE now() > date_delete;

    -- Delete mails if more than 900 mails per club
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

    -- Delete the players poaching
    DELETE FROM players_poaching
    WHERE to_delete = TRUE
    AND affinity < 0;

END;
$procedure$;
