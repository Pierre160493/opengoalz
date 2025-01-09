-- DROP FUNCTION public.simulate_game_calculate_game_weights(_float8, _int8);

CREATE OR REPLACE FUNCTION public.simulate_game_calculate_game_weights(
    inp_player_array float4[],
    inp_subs bigint[])
 RETURNS double precision[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- team_weights float8[7] := '{1000,1000,1000,1000,1000,1000,1000}'; -- Returned array holding team stats {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
    team_weights float4[7] := '{100,100,100,100,100,100,100}'; -- Returned array holding team stats {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
    player_stats float4[12]; -- Players stats array {keeper, defense, passes, playmaking, winger, scoring, freekick, motivation, form, experience, stamina, energy}
    player_weights float4[7]; -- Tmp array for holding player stats and weights
    loc_energy_coefficient float4;
BEGIN
    -- Loop through the 14 positions of the team
    FOR i IN 1..14 LOOP
        -- Fetch the stats of the player playing at the position i {keeper, defense, passes, playmaking, winger, scoring, freekick}
        FOR j IN 1..12 LOOP
            player_stats[j] := inp_player_array[inp_subs[i]][j];
        END LOOP;

        -- Fetch the weights of the player playing at the position i  {LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack}
        -- player_weights := players_calculate_player_weight(player_stats, i);
        player_weights := players_calculate_player_weight(player_stats, i);

        -- Calculate the energy coefficient of the player
        loc_energy_coefficient := player_stats[12] / 100.0;

        -- Add the player weights to the team weights
        FOR j IN 1..7 LOOP
            team_weights[j] := team_weights[j] + player_weights[j] * loc_energy_coefficient;
        END LOOP;
    END LOOP;

    RETURN team_weights;
END;
$function$
;
