CREATE OR REPLACE FUNCTION public.simulate_game_process_experience_gain(
    inp_id_game INT8,
    inp_list_players_id_left INT8[21],
    inp_list_players_id_right INT8[21])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_experience_gain FLOAT;
BEGIN
    -- Check if the game is friendly, league or cup
    SELECT CASE
        WHEN is_cup THEN 0.3
        WHEN is_league THEN 0.22
        ELSE 0.05
    END INTO loc_experience_gain
    FROM games
    WHERE id = inp_id_game;

    -- Loop through the players
    FOR i IN 1..21 LOOP
        -- Check if the current element is not null
        IF inp_list_players_id_left[i] IS NOT NULL THEN
            -- Process the experience gain
            UPDATE players SET experience = experience + 
                CASE WHEN i <= 14 THEN loc_experience_gain
                ELSE loc_experience_gain / 2
                END
            WHERE id = inp_list_players_id_left[i];
        END IF;
        IF inp_list_players_id_right[i] IS NOT NULL THEN
            -- Process the experience gain
            UPDATE players SET experience = experience + 
                CASE WHEN i <= 14 THEN loc_experience_gain
                ELSE loc_experience_gain / 2
                END
            WHERE id = inp_list_players_id_right[i];
        END IF;
    END LOOP;
END;
$function$
;