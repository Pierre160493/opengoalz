-- DROP FUNCTION public.players_create_player(int8, int8, int8, _float8, float8, int8, text);

CREATE OR REPLACE FUNCTION public.players_create_player(
    inp_id_multiverse bigint,
    inp_id_club bigint,
    inp_id_country bigint,
    inp_stats double precision[],
    inp_age double precision,
    inp_shirt_number bigint DEFAULT NULL::bigint,
    inp_notes text DEFAULT NULL::text)
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
        shirt_number, notes, notes_small
    ) VALUES (
        inp_id_multiverse, inp_id_club, inp_id_country,
        players_calculate_date_birth(inp_id_multiverse := inp_id_multiverse, inp_age := inp_age), 3.0 * (inp_age - 15.0),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        loc_training_coef,
        inp_shirt_number, inp_notes,
        -- Small notes
        CASE
            WHEN inp_notes = 'Experienced GoalKeeper' THEN 'GK1'
            WHEN inp_notes = 'Young GoalKeeper' THEN 'GK2'
            WHEN inp_notes = 'Experienced Back Winger' THEN 'BW1'
            WHEN inp_notes = 'Intermediate Age Back Winger' THEN 'BW2'
            WHEN inp_notes = 'Young Back Winger' THEN 'BW3'
            WHEN inp_notes = 'Experienced Central Back' THEN 'CB1'
            WHEN inp_notes = 'Intermediate Age Central Back' THEN 'CB2'
            WHEN inp_notes = 'Young Central Back' THEN 'CB3'
            WHEN inp_notes = 'Experienced Midfielder' THEN 'MF1'
            WHEN inp_notes = 'Intermediate Age Midfielder' THEN 'MF2'
            WHEN inp_notes = 'Young Midfielder' THEN 'MF3'
            WHEN inp_notes = 'Experienced Winger' THEN 'WG1'
            WHEN inp_notes = 'Intermediate Age Winger' THEN 'WG2'
            WHEN inp_notes = 'Young Winger' THEN 'WG3'
            WHEN inp_notes = 'Experienced Striker' THEN 'ST1'
            WHEN inp_notes = 'Intermediate Age Striker' THEN 'ST2'
            WHEN inp_notes = 'Young Striker' THEN 'ST3'
            WHEN inp_notes = 'Old Experienced player' THEN 'OLDXP'
            WHEN inp_notes = 'Youngster 1' THEN 'YOUNG1'
            WHEN inp_notes = 'Youngster 2' THEN 'YOUNG2'
            WHEN inp_notes = 'Young Scouted' THEN 'YOUNG'
            ELSE 'None'
        END)
    RETURNING id INTO loc_new_player_id;

    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (loc_new_player_id, inp_id_club,
    'Joined ' || string_parser(inp_id_club, 'club') ||
    CASE
        WHEN inp_notes = 'Young Scouted' THEN ' as a young scouted player'
        WHEN inp_notes = 'Old Experienced player' THEN ' as an old experienced player'
        ELSE ' as a free player'
    END);

    ------ Return the new player's ID
    RETURN loc_new_player_id;
END;
$function$
;
