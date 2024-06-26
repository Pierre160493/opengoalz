-- DROP FUNCTION public.create_player(int8, int8, text, text, float8, int4);

CREATE OR REPLACE FUNCTION public.create_player(
    inp_multiverse_speed bigint, -- Speed of the multiverse
    inp_id_club bigint, -- Id of the club
    inp_id_country bigint, -- Id of the country
    inp_first_name text DEFAULT NULL::text, -- First name of the player
    inp_last_name text DEFAULT NULL::text, -- Last name of the player
    inp_age double precision DEFAULT NULL::double precision, -- Age of the player
    inp_stats integer DEFAULT 1 -- Stats of the player (default 25)
    )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID
BEGIN

    ------ Set input variables when NULL
    IF inp_first_name IS NULL THEN -- If NULL
        SELECT players_names.first_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_first_name; -- Fetch a random first name
    END IF;
    IF inp_last_name IS NULL THEN -- IF NULL
        SELECT players_names.last_name FROM players_names ORDER BY RANDOM() LIMIT 1 INTO inp_last_name; -- Fetch a random last name
    END IF;
    IF inp_age IS NULL THEN -- IF NULL
        SELECT 17 + (random() * (32 - 17)) INTO inp_age; -- Generate a random age
    END IF;

    ------ Create player
    INSERT INTO players (
        multiverse_speed, id_club, id_country, first_name, last_name, date_birth,
        keeper, defense, playmaking, passes, winger, scoring, freekick)
    VALUES (
        inp_multiverse_speed, inp_id_club, inp_id_country, inp_first_name, inp_last_name, calculate_date_birth(inp_age),
        random() * 100, random() * 100, random() * 100, random() * 100, random() * 100, random() * 100, random() * 100)
    RETURNING id INTO loc_new_player_id;

    ------ To Delete !!!
    --UPDATE players SET first_name = loc_new_player_id::text, last_name = loc_new_player_id::text WHERE id = loc_new_player_id;

    ------ Write player history (TO DELETE !!!)
    INSERT INTO players_history (id_player, id_club, description) VALUES (loc_new_player_id, inp_id_club, 'Joined new club as a free player');

END;
$function$
;
