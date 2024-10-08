-- DROP FUNCTION public.simulate_game_calculate_game_weights(double precision[], bigint[]);

CREATE OR REPLACE FUNCTION public.simulate_game_calculate_game_weights(inp_player_array double precision[], inp_subs bigint[])
RETURNS double precision[]
LANGUAGE plpgsql
AS $function$
DECLARE
    team_weights float8[7] := '{1000,1000,1000,1000,1000,1000,1000}'; -- Returned array holding team stats {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
    player_array float8[7]; -- Tmp array for holding player stats and weights
BEGIN
    -- Loop through the 14 positions of the team
    FOR i IN 1..14 LOOP
        -- Fetch the stats of the player playing at the position i {keeper, defense, passes, playmaking, winger, scoring, freekick}
        FOR j IN 1..7 LOOP
            player_array[j] := inp_player_array[inp_subs[i]][j];
        END LOOP;

        -- Fetch the weights of the player playing at the position i  {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
        player_array := players_calculate_player_weight(player_array, i);

        -- Add the player weights to the team weights
        FOR j IN 1..7 LOOP
            team_weights[j] := team_weights[j] + player_array[j];
        END LOOP;
    END LOOP;

    RETURN team_weights;
END;
$function$;