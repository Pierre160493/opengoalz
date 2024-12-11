-- DROP FUNCTION public.players_create_player(int8, int8, int8, _float8, float8, int8, text);

CREATE OR REPLACE FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision, inp_shirt_number bigint DEFAULT NULL::bigint, inp_notes text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID
    loc_top_two_stats double precision[];
    loc_training_coef double precision[];
BEGIN

    -- Find the two highest values in inp_stats
    loc_top_two_stats := (
        SELECT ARRAY(
            SELECT val
            FROM unnest(inp_stats) AS val
            ORDER BY val DESC
            LIMIT 2
        )
    );

    -- Create the training_coef array with 1 for the two highest stats and 0 for the others
    loc_training_coef := ARRAY[
        CASE WHEN inp_stats[1] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[2] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[3] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[4] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[5] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[6] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END,
        CASE WHEN inp_stats[7] = ANY(loc_top_two_stats) THEN 1 ELSE 0 END
    ];

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Create player
    INSERT INTO players (
        id_multiverse, id_club, id_country,
        date_birth, experience,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        training_coef,
        notes, shirt_number
    ) VALUES (
        inp_id_multiverse, inp_id_club, inp_id_country,
        players_calculate_date_birth(inp_id_multiverse := inp_id_multiverse, inp_age := inp_age), 3.0 * (inp_age - 15.0),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        ARRAY[
            FLOOR(inp_stats[1]),
            FLOOR(inp_stats[2]),
            FLOOR(inp_stats[3]),
            FLOOR(inp_stats[4]),
            FLOOR(inp_stats[5]),
            FLOOR(inp_stats[6]),
            FLOOR(inp_stats[7])],
        inp_notes, inp_shirt_number)
    RETURNING id INTO loc_new_player_id;

    ------ Calculate the performance score
    PERFORM players_calculate_performance_score(inp_id_player := loc_new_player_id);

    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (loc_new_player_id, inp_id_club, 'Joined a club as a free player');

    ------ Store player's stats in the history
    INSERT INTO players_history_stats
        (id_player, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, experience, training_points_used)
    SELECT
        id, performance_score,
        expenses_payed, expenses_expected, expenses_missed,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        motivation, form, stamina, experience, training_points_used
    FROM players
    WHERE id = loc_new_player_id;

    ------ Return the new player's ID
    RETURN loc_new_player_id;
END;
$function$
;
