-- DROP FUNCTION public.players_calculate_player_best_weight(_float8);

CREATE OR REPLACE FUNCTION public.players_handle_embodied_player(
    inp_id_player INT8, -- Player ID
    inp_username TEXT, -- Username of the user
    inp_start_embody BOOLEAN DEFAULT FALSE, -- Flag to start embodying the player
    inp_stop_embody BOOLEAN DEFAULT FALSE, -- Flag to stop embodying the player
    inp_retire_embodied BOOLEAN DEFAULT FALSE -- Flag to retire embodied the player
    )
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER -- Execute with the rights of the function owner
AS $function$
DECLARE
    rec_player RECORD;
    credits_for_player INTEGER := 500; -- Credits required to embody a player
BEGIN

    ------ Fetch the player record
    SELECT
        players.id, players.username, players.user_points_available,
        string_parser(inp_entity_type := 'idPlayer', inp_id := players.id) AS player_special_string,
        players.id_club,
        ARRAY(
            SELECT id_club
            FROM (
                SELECT players.id_club AS id_club
                UNION
                SELECT id_club FROM players_favorite WHERE id_player = players.id
                UNION
                SELECT id_club FROM players_poaching WHERE id_player = players.id
            ) AS clubs
        ) AS following_clubs,
        profiles.credits_available, profiles.uuid_user,
        string_parser(inp_entity_type := 'uuidUser', inp_uuid_user := profiles.uuid_user) AS uuid_user_special_string
    INTO rec_player
    FROM players
    JOIN profiles ON profiles.username = inp_username
    WHERE players.id = inp_id_player;
    
    ------ Check if the player exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with ID % does not exist', inp_id_player;
    END IF;

    ------ Start embodying the player
    IF inp_start_embody IS TRUE THEN

        ---- Check that the player is not already embodied
        IF rec_player.username IS NOT NULL THEN
            RAISE EXCEPTION 'Player with ID % is already embodied by user %', inp_id_player, rec_player.username;
        END IF;

        ---- Check that the user can have an additional embodied player
        IF rec_player.credits_available < credits_for_player THEN
            RAISE EXCEPTION 'You dont have enough credits (%) to embody a new player (needed: %)', rec_player.credits_available, credits_for_player;
        END IF;

        ---- Update the user's credits
        UPDATE profiles SET
            credits_available = credits_available - credits_for_player,
            credits_used = credits_used + credits_for_player
        WHERE uuid_user = rec_player.uuid_user;

        ---- Update the player to embody the new username
        UPDATE players SET
            username = inp_username
        WHERE id = inp_id_player;

        ---- Insert a new row in the user's history table
        INSERT INTO profile_events (uuid_user, description)
            VALUES (rec_player.uuid_user, 'Started Embodying ' || rec_player.player_special_string);

        ---- Store a new row in the player history table
        INSERT INTO players_history (id_player, id_club, is_transfer_description, description)
            VALUES (rec_player.id, rec_player.id_club, TRUE,
            'Started being embodied by ' || rec_player.uuid_user_special_string);

        ---- Send mails to the club and the clubs following the player
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        SELECT DISTINCT unnest(rec_player.following_clubs), 'Scouts', TRUE,
            rec_player.player_special_string || ' is now embodied by ' || rec_player.uuid_user_special_string,
            rec_player.player_special_string || ' is now embodied by ' || rec_player.uuid_user_special_string;

    END IF;

    ------ Retire the embodied player
    IF inp_retire_embodied IS TRUE THEN

        ---- Check to ensure that the user calling the function is embodying the player
        IF inp_username != rec_player.username THEN
            RAISE EXCEPTION 'User calling the function (%) does not match the user embodying the player (%)', inp_user_uuid, rec_player.username;
        END IF;

        ---- Retire the player from embodying
        UPDATE players SET
            date_retire = NOW()
        WHERE id = inp_id_player;

    END IF;
    
    ------ Stop embodying the player
    IF inp_stop_embody IS TRUE THEN

        ---- Check to ensure that the user calling the function is embodying the player
        IF inp_username != rec_player.username THEN
            RAISE EXCEPTION 'User calling the function (%) does not match the user embodying the player (%)', inp_user_uuid, rec_player.uuid_user;
        END IF;

        ---- Stop embodying the player
        UPDATE players SET
            username = NULL
        WHERE id = inp_id_player;

        ---- Insert a new row in the user's history table
        INSERT INTO profile_events (uuid_user, description)
            VALUES (rec_player.uuid_user, 'Stopped embodying ' || rec_player.player_special_string);

        ---- Store a new row in the player history table
        INSERT INTO players_history (id_player, id_club, is_transfer_description, description)
            VALUES (rec_player.id, rec_player.id_club, TRUE,
            'Stopped being embodied by ' || rec_player.uuid_user_special_string);

        ---- Send mails to the club and the clubs following the player
        INSERT INTO mails (id_club_to, sender_role, is_transfer_info, title, message)
        SELECT DISTINCT unnest(rec_player.following_clubs), 'Scouts', TRUE,
            rec_player.player_special_string || ' is no longer embodied by ' || rec_player.uuid_user_special_string,
            rec_player.player_special_string || ' is no longer embodied by ' || rec_player.uuid_user_special_string;

    END IF;

    RETURN;
END;
$function$
;
