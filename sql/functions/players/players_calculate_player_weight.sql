
CREATE OR REPLACE FUNCTION public.players_calculate_player_weight(
    inp_player_stats double precision[], -- Array of player stats {7 player stats}
    inp_position int -- Position of the player (1-14)
    )
 RETURNS double precision[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    CoefMatrix float8[14][7][6] := '
{{{0.25,0.1,0,0,0,0},{0.5,0.2,0,0,0,0},{0.25,0.1,0,0,0,0},{0,0,0.2,0.1,0,0},{0,0,0.1,0,0,0},{0,0,0.1,0,0,0},{0,0,0.1,0,0,0}},
{{0,0.6,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.2,0.3,0,0},{0,0,0.3,0,0.6,0.2},{0,0,0.2,0,0,0.1},{0,0,0.1,0,0.1,0}},
{{0,0.3,0,0,0,0},{0,0.8,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.2,0.3,0,0},{0,0,0.2,0,0.2,0.1},{0,0,0.1,0,0,0.2},{0,0,0.1,0,0,0}},
{{0,0.2,0,0,0,0},{0,0.8,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.2,0.3,0,0},{0,0,0.1,0,0,0},{0,0,0.2,0,0,0.3},{0,0,0.1,0,0,0}},
{{0,0.2,0,0,0,0},{0,0.8,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.2,0.3,0,0},{0,0,0.1,0,0,0},{0,0,0.2,0,0,0.3},{0,0,0.1,0,0,0}},
{{0,0.1,0,0,0,0},{0,0.8,0,0,0,0},{0,0.3,0,0,0,0},{0,0,0.2,0.3,0,0},{0,0,0.1,0,0,0},{0,0,0.1,0,0,0.2},{0,0,0.2,0,0.2,0.1}},
{{0,0.4,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0.3,0.5,0,0},{0,0,0.3,0,0.7,0.5},{0,0,0.2,0,0.2,0.3},{0,0,0,0,0.1,0}},
{{0,0.2,0,0,0,0},{0,0.4,0,0,0,0},{0,0,0,0,0,0},{0,0,0.3,0.6,0,0},{0,0,0.2,0,0.3,0.2},{0,0,0.4,0,0.2,0.3},{0,0,0,0,0.1,0.1}},
{{0,0.1,0,0,0,0},{0,0.5,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.3,0.6,0,0},{0,0,0.1,0,0.1,0.1},{0,0,0.4,0,0.3,0.4},{0,0,0.1,0,0.1,0.1}},
{{0,0,0,0,0,0},{0,0.4,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.3,0.6,0,0},{0,0,0,0,0.1,0.1},{0,0,0.4,0,0.2,0.3},{0,0,0.2,0,0.3,0.2}},
{{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0.4,0,0,0,0},{0,0,0.3,0.5,0,0},{0,0,0,0,0.1,0},{0,0,0.2,0,0.2,0.3},{0,0,0.3,0,0.7,0.5}},
{{0,0.2,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0.3,0.4,0,0},{0,0,0.3,0,0.4,0.4},{0,0,0.3,0,0.3,0.4},{0,0,0.1,0,0.1,0.1}},
{{0,0.1,0,0,0,0},{0,0.2,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.3,0.3,0,0},{0,0,0.2,0,0.2,0.2},{0,0,0.3,0,0.3,0.6},{0,0,0.2,0,0.2,0.2}},
{{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.3,0.4,0,0},{0,0,0.1,0,0.1,0.1},{0,0,0.3,0,0.3,0.4},{0,0,0.3,0,0.4,0.4}}}
'; -- 3D Matrix to calculate team stats [14 positions x 7 game weights x 6 player stats (we dont take freekick in count)]
    player_weight float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold player weights on the team (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
BEGIN

    -- Check if the position is between 1 and 14
    IF inp_position < 1 OR inp_position > 14 THEN
        RAISE EXCEPTION 'Position must be between 1 and 14';
    END IF;

    -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
    FOR i IN 1..7 LOOP
        -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
        FOR j IN 1..6 LOOP
            player_weight[i] := player_weight[i] + inp_player_stats[j] * CoefMatrix[inp_position][i][j];
        END LOOP;
    END LOOP;

    RETURN player_weight;
END;
$function$
;
