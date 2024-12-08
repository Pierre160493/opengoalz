-- DROP FUNCTION public.players_calculate_player_best_weight(_float8);

CREATE OR REPLACE FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[])
 RETURNS double precision
 LANGUAGE plpgsql
AS $function$
DECLARE
    player_weight_array float8[7];
    player_max_weight float8 := 0;
    current_weight float8;
BEGIN
    -- Loop through the 14 available positions of the team
    FOR i IN 1..14 LOOP
        -- Calculate the weight of the player for the given position
        player_weight_array := players_calculate_player_weight(inp_player_stats, i);
        -- Calculate the sum of the weights
        current_weight := (SELECT SUM(UNNEST(player_weight_array)));
        -- Check if the weight is higher than the maximum weight
        IF current_weight > player_max_weight THEN
            player_max_weight := current_weight;
        END IF;
    END LOOP;
    RETURN player_max_weight;
END;
$function$
;
