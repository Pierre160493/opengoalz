-- DROP FUNCTION public.players_create_player(int8, int8, int8, _float8, float8, int8, text);

CREATE OR REPLACE FUNCTION public.players_create_player(inp_id_multiverse bigint, inp_id_club bigint, inp_id_country bigint, inp_stats double precision[], inp_age double precision DEFAULT NULL::double precision, inp_shirt_number bigint DEFAULT NULL::bigint, inp_notes text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_new_player_id bigint; -- Variable to store the inserted player's ID
BEGIN


    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------ Create player
    INSERT INTO players (
        id_multiverse, id_club, id_country,
        date_birth,
        keeper, defense, passes, playmaking, winger, scoring, freekick,
        notes, shirt_number
    ) VALUES (
        inp_id_multiverse, inp_id_club, inp_id_country,
        players_calculate_date_birth(inp_id_multiverse := inp_id_multiverse, inp_age := inp_age),
        inp_stats[1], inp_stats[2], inp_stats[3], inp_stats[4], inp_stats[5], inp_stats[6], inp_stats[7],
        inp_notes, inp_shirt_number)
    RETURNING id INTO loc_new_player_id;

    ------ Calculate the performance score
    PERFORM players_calculate_performance_score(inp_id_player := loc_new_player_id);

    ------ Log player history
    INSERT INTO players_history (id_player, id_club, description) VALUES (loc_new_player_id, inp_id_club, 'Joined a club as a free player');

    RETURN loc_new_player_id;
END;
$function$
;
