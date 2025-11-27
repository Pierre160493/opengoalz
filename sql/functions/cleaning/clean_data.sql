CREATE OR REPLACE PROCEDURE public.clean_data()
LANGUAGE plpgsql
AS $procedure$
BEGIN

    -- Clean the old games
    DELETE FROM games g
    WHERE g.season_number < (
        SELECT m.season_number - 30 FROM multiverses m WHERE m.id = g.id_multiverse
    );

    -- Delete the game_player_stats_all because it takes too much space
    DELETE FROM game_player_stats_all gpsa
    WHERE gpsa.id_game IN (
        SELECT g.id FROM games g
        WHERE g.season_number < (
            SELECT m.season_number FROM multiverses m WHERE m.id = g.id_multiverse
        )
    );

    -- Delete old data from clubs
    DELETE FROM clubs_history_weekly chw
    WHERE chw.season_number < (
        SELECT m.season_number - 30
        FROM clubs c
        JOIN multiverses m ON c.id_multiverse = m.id
        WHERE c.id = chw.id_club
    );

    -- Delete old data from players
    DELETE FROM players_history_stats phs
    WHERE phs.season_number < (
        SELECT m.season_number - 30
        FROM players p
        JOIN multiverses m ON p.id_multiverse = m.id
        WHERE p.id = phs.id_player
    );

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

    ------ Delete the players poaching
    DELETE FROM players_poaching
    WHERE to_delete = TRUE
    AND affinity < 0;

    ------ Delete users scheduled for deletion
    DELETE FROM auth.users
    WHERE id IN (
        SELECT uuid_user
        FROM public.profiles
        WHERE NOW() >= date_delete
    );

    ------ Delete multiverses scheduled for deletion
    CALL clean_multiverse_to_delete();

END;
$procedure$;