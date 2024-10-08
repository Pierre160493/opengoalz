-- DROP FUNCTION public.players_calculate_player_best_weight(_float8);

CREATE OR REPLACE FUNCTION public.players_calculate_player_best_weight(inp_player_stats double precision[])
 RETURNS double precision
 LANGUAGE plpgsql
AS $function$
DECLARE
    player_weight_array float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold player weights on the team (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
    player_weight float8 := 0; -- Weight of the player
    player_max_weight float8 := 0; -- Maximum weight of the player
BEGIN

    -- Loop through the 14 available positions of the team
    FOR i IN 1..14 LOOP
        -- Calculate the weight of the player for the given position
        player_weight_array := players_calculate_player_weight(inp_player_stats, i);
        -- Calculate the sum of the weights
        FOR j IN 1..7 LOOP
            player_weight := player_weight + player_weight_array[j];
        END LOOP;
        -- Check if the weight is higher than the maximum weight
        IF player_weight > player_max_weight THEN
            player_max_weight := player_weight;
        END IF;
    END LOOP;

    RETURN player_max_weight;
END;
$function$
;
