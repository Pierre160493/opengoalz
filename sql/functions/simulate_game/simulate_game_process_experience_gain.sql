-- DROP FUNCTION public.simulate_game(int8);

CREATE OR REPLACE FUNCTION public.simulate_game_process_experience_gain(
    inp_id_game INT8,
    inp_list_players_id_left INT8[21],
    inp_list_players_id_right INT8[21])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_list_players_id INT8[28]; -- List of players ID
    loc_experience_gain FLOAT := 0.2; -- Experience gain for each starting player
BEGIN

    ------ Merge the two lists of players ID
    FOR I IN 1..14 LOOP
        IF inp_list_players_id_left[I] IS NOT NULL THEN
            loc_list_players_id[I] := inp_list_players_id_left[I];
        END IF;
        IF inp_list_players_id_right[I] IS NOT NULL THEN
            loc_list_players_id[I + 14] := inp_list_players_id_right[I];
        END IF;
    END LOOP;

    -- Loop through the players of the left team
    FOREACH loc_id_player IN ARRAY inp_list_players_left[1:14]
    LOOP
        -- Check if the current element is not null
        IF loc_id_player IS NOT NULL THEN
            -- Process the experience gain
            UPDATE players SET experience = experience + 0.1 WHERE id = loc_id_player;
        END IF;
    END LOOP;

END;
$function$
;
