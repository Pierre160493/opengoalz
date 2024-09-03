-- DROP FUNCTION public.players_create_player(int8, int8, int8, _float8, float8, int8, text);

CREATE OR REPLACE FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision DEFAULT NULL::double precision, inp_shirt_number bigint DEFAULT NULL::bigint, inp_notes text DEFAULT NULL::text)
 RETURNS bigint
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
raise notice 'test in players_create_player';
    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Create player
    INSERT INTO players (
        id_multiverse, multiverse_speed, id_club, id_country, first_name, last_name,
        date_birth, experience,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        expanses,
        notes, shirt_number
    ) VALUES (
        inp_id_multiverse, (SELECT speed FROM multiverses WHERE id = inp_id_multiverse), inp_id_club, inp_id_country, loc_first_name, loc_last_name,
--        players_calculate_date_birth(inp_id_multiverse := inp_id_multiverse, inp_age := inp_age), 2 * (inp_age - 15),
        CURRENT_DATE, 2 * (inp_age - 15),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        FLOOR((100 + inp_stats[1]+inp_stats[2]+inp_stats[3]+inp_stats[4]+inp_stats[5]+inp_stats[6]+inp_stats[7]) * 0.75),
        inp_notes, inp_shirt_number)
    RETURNING id INTO loc_new_player_id;
raise notice 'test in loc_new_player_id=%',loc_new_player_id;
    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description) VALUES (loc_new_player_id, inp_id_club, 'Joined a club as a free player');
raise notice 'test in players_create_player2';
    RETURN loc_new_player_id;
END;
$function$
;
