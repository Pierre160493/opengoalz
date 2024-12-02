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
BEGIN

    -- Check if the position is between 1 and 14
    IF inp_position < 1 OR inp_position > 14 THEN
        RAISE EXCEPTION 'Position must be between 1 and 14';
    END IF;

    ------ If inp_player_stats is null, raise an exception
    IF array_length(inp_player_stats, 1) IS NULL THEN
        RAISE EXCEPTION 'inp_player_stats must be an array of 6 elements';
    ------ If inp_player_stats is is an array of 6 elements, calculate the player weight for game (array of 7 elements[LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack])
    ELSEIF array_length(inp_player_stats, 1) = 6 THEN

        -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
        FOR I IN 1..7 LOOP
            -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
            FOR J IN 1..6 LOOP
                player_weight[I] := player_weight[I] + inp_player_stats[J] * CoefMatrix[inp_position][I][J];
            END LOOP;
        END LOOP;

    ------ If inp_player_stats is is an array of 1 element, calculate the player weight for training (array of 7 elements[keeper, defense, passes, playmaking, winger, scoring, freekick])
    ELSEIF array_length(inp_player_stats, 1) = 1 THEN

        -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
        FOR I IN 1..7 LOOP
            -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
            FOR J IN 1..6 LOOP
                player_weight[J] := player_weight[J] + inp_player_stats[1] * CoefMatrix[inp_position][I][J];
            END LOOP;
        END LOOP;
        player_weight[7] := 0.1 * inp_player_stats[1];
RAISE NOTICE 'player_weight: % [SUM= %]', player_weight, array_sum(player_weight);
    ELSE
        RAISE EXCEPTION 'inp_player_stats [%] input is not valid', inp_player_stats;
    END IF;

    RETURN player_weight;
END;
$function$
;
