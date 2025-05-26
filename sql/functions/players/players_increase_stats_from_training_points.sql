-- DROP FUNCTION public.players_calculate_player_best_weight(_float8);

CREATE OR REPLACE FUNCTION public.players_increase_stats_from_training_points(
    inp_id_player INT8, -- Player ID
    inp_increase_points INTEGER[7], -- Keeper, Defense, Passes, Playmaking, Winger, Scoring, Freekick
    inp_user_uuid UUID -- UUID of the user calling the functio
    )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    rec_player RECORD;
    loc_training_points_used INTEGER := 0; -- Local variable to hold the total number of points
BEGIN

    ------ Fetch the player record
    SELECT
        players.id, players.username, players.user_points_available, profiles.uuid_user
    INTO rec_player
    FROM players
    JOIN profiles ON players.username = profiles.username
    WHERE players.id = inp_id_player;
    
    ------ Check if the player exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with ID % does not exist', inp_id_player;
    END IF;

    ------ Check to ensure that the user calling the function is the owner of the player
    IF inp_user_uuid != rec_player.uuid_user THEN
        RAISE EXCEPTION 'User calling the function (%) does not match the user embodying the player (%)', inp_user_uuid, rec_player.uuid_user;
    END IF;

    ------ Check that inp_increase_points is an array of 7 integers
    IF array_length(inp_increase_points, 1) IS DISTINCT FROM 7 THEN
        RAISE EXCEPTION 'inp_increase_points must be an array of 7 integers. Got array of length %', array_length(inp_increase_points, 1);
    END IF;
    ------ Calculate the total number of points used for training
    SELECT SUM(inp_value) INTO loc_training_points_used FROM unnest(inp_increase_points) AS inp_value;
    IF loc_training_points_used <= 0 THEN
        RAISE EXCEPTION 'No training points provided or all points are zero';
    ELSEIF loc_training_points_used > rec_player.user_points_available THEN
        RAISE EXCEPTION 'Not enough training points available. Available: %, Required: %', rec_player.user_points_available, loc_training_points_used;
    END IF;

    ------ Update the stats of the player
    UPDATE players SET
        keeper = LEAST(keeper + inp_increase_points[1], 100),
        defense = LEAST(defense + inp_increase_points[2], 100),
        passes = LEAST(passes + inp_increase_points[3], 100),
        playmaking = LEAST(playmaking + inp_increase_points[4], 100),
        winger = LEAST(winger + inp_increase_points[5], 100),
        scoring = LEAST(scoring + inp_increase_points[6], 100),
        freekick = LEAST(freekick + inp_increase_points[7], 100),
        user_points_available = user_points_available - loc_training_points_used,
        user_points_used = user_points_used + loc_training_points_used
    WHERE id = inp_id_player;

    RETURN;
END;
$function$
;
