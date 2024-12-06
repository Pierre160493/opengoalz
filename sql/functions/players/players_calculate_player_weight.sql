-- DROP FUNCTION public.players_calculate_player_weight(_float8, int4);

CREATE OR REPLACE FUNCTION public.players_calculate_player_weight(
    inp_player_stats double precision[],
    inp_position integer)
 RETURNS double precision[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    CoefMatrix float8[14][7][6] := 
    '{{{0.125,0.05,0,0,0,0},{0.25,0.1,0,0,0,0},{0.125,0.05,0,0,0,0},{0,0,0.05,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.05,0,0,0},{0,0,0.05,0,0,0}},
      {{0,0.2,0,0,0,0},{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.05,0.1,0,0},{0,0,0.1,0,0.25,0.05},{0,0,0.05,0,0,0},{0,0,0,0,0,0}},
      {{0,0.15,0,0,0,0},{0,0.3,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.1,0,0.05,0},{0,0,0.1,0,0,0.05},{0,0,0,0,0,0}},
      {{0,0.1,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.05,0,0,0}},
      {{0,0.1,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0.05,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.05,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.3,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0.1,0.1,0,0},{0,0,0,0,0,0},{0,0,0.1,0,0,0.05},{0,0,0.1,0,0.05,0}},
      {{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.1,0,0.15,0.1},{0,0,0.05,0,0.05,0.1},{0,0,0,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.3,0,0},{0,0,0.05,0,0.1,0},{0,0,0.2,0,0,0.1},{0,0,0,0,0,0}},
      {{0,0.05,0,0,0,0},{0,0.1,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.1,0.3,0,0},{0,0,0.1,0,0,0},{0,0,0.1,0,0,0.1},{0,0,0.1,0,0,0}},
      {{0,0,0,0,0,0},{0,0.15,0,0,0,0},{0,0.05,0,0,0,0},{0,0,0.05,0.3,0,0},{0,0,0,0,0,0},{0,0,0.2,0,0,0.1},{0,0,0.05,0,0.1,0}},
      {{0,0,0,0,0,0},{0,0.05,0,0,0,0},{0,0.15,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0,0,0,0},{0,0,0.05,0,0.05,0.1},{0,0,0.1,0,0.15,0.1}},
      {{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.1,0,0.05,0.1},{0,0,0.05,0,0.05,0.3},{0,0,0,0,0,0}},
      {{0,0.025,0,0,0,0},{0,0.05,0,0,0,0},{0,0.025,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0.05,0,0.05,0.05},{0,0,0.05,0,0.1,0.2},{0,0,0.05,0,0.05,0.05}},
      {{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.05,0.2,0,0},{0,0,0,0,0,0},{0,0,0.05,0,0.05,0.3},{0,0,0.1,0,0.05,0.1}}}';
    player_weight float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold player weights on the team (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
    player_coef float4; -- Coefficient of the player stats
BEGIN

    -- Check if the position is between 1 and 14
    IF inp_position < 1 OR inp_position > 14 THEN
        RAISE EXCEPTION 'Position must be between 1 and 14';
    END IF;

    -- Calculate the coefficient of the player stats (motiation, form, experiennce, energy)
    player_coef := 1 + ((inp_player_stats[8] + inp_player_stats[9] + inp_player_stats[10] + inp_player_stats[12]) / 400.0);

    -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
    FOR i IN 1..7 LOOP
        -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
        FOR j IN 1..6 LOOP
            player_weight[i] := player_weight[i] + inp_player_stats[j] * CoefMatrix[inp_position][i][j];
        END LOOP;

        -- Add the coefficients of the player stats
        player_weight[i] := player_weight[i] * player_coef;
    END LOOP;

    RETURN player_weight;
END;
$function$
;
