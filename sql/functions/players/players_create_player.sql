-- DROP FUNCTION public.players_create_player(int8, int8, int8, text, text, float8, int4);

CREATE OR REPLACE FUNCTION public.players_create_player(
    inp_multiverse_speed bigint, 
    inp_id_club bigint, 
    inp_id_country bigint,
    inp_stats float[7],
    inp_age double precision DEFAULT NULL::double precision,
    inp_shirt_number int8 DEFAULT NULL::int8,
    inp_notes TEXT DEFAULT NULL::TEXT,
    )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID
    loc_first_name TEXT;
    loc_last_name TEXT;
BEGIN

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Set input variables when NULL
    -- Handle first and last name random selection
    WITH country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country = inp_id_country 
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != inp_id_country 
        LIMIT (100 - (SELECT COUNT(*) FROM country_query))
    ),
    combined_query AS (
        SELECT * FROM country_query
        UNION ALL
        SELECT * FROM other_country_query
    )
    SELECT first_name INTO loc_first_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random first name

        WITH country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country = inp_id_country 
        LIMIT 100
    ),
    other_country_query AS (
        SELECT first_name, last_name
        FROM players_names 
        WHERE id_country != inp_id_country 
        LIMIT (100 - (SELECT COUNT(*) FROM country_query))
    ),
    combined_query AS (
        SELECT * FROM country_query
        UNION ALL
        SELECT * FROM other_country_query
    )
    SELECT last_name INTO loc_last_name FROM combined_query ORDER BY RANDOM() LIMIT 1; -- Fetch a random first name

    IF inp_age IS NULL THEN -- IF NULL
        SELECT 17 + (random() * (32 - 17)) INTO inp_age; -- Generate a random age
    END IF;

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Create player
    INSERT INTO players (
        multiverse_speed, id_club, id_country, first_name, last_name,
        date_birth, experience,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        expanses
    ) VALUES (
        inp_multiverse_speed, inp_id_club, inp_id_country, loc_first_name, loc_last_name,
        players_calculate_date_birth(inp_multiverse_speed := inp_multiverse_speed, inp_age := inp_age), 2 * (inp_age - 15),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        FLOOR((100 + inp_stats[1]+inp_stats[2]+inp_stats[3]+inp_stats[4]+inp_stats[5]+inp_stats[6]+inp_stats[7]) * 0.75))
    RETURNING id INTO loc_new_player_id;

    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description) VALUES (loc_new_player_id, inp_id_club, 'Joined new club as a free player');

END;
$function$
;
