-- DROP FUNCTION public.simulate_game_calculate_game_weights(_float8, _int8);

CREATE OR REPLACE FUNCTION public.simulate_game_calculate_game_weights(inp_player_stats double precision[], inp_subs bigint[])
 RETURNS double precision[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_matrix_player_stats float8[14][7] := array_fill(0::float8, ARRAY[14,7]); -- Matrix to hold player stats [14 starters x 6 player stats]
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
'; -- 3D Matrix to calculate team stats [14 starters x 7 game weights x 6 player stats (we dont take freekick in count)]
    team_stats float8[7] := '{1000,1000,1000,1000,1000,1000,1000}'; -- Array to hold team stats
    i INT;
    j INT;
    k INT;
BEGIN

    -- Loop through the 14 available positions of the team
    FOR i IN 1..14 LOOP
        -- Loop through the 7 player stats (Keeper, Defense, Playmaking, Passes, Scoring, Winger)
        FOR j IN 1..7 LOOP
            -- Assign player stats to loc_matrix_player_stats matrix
            -- loc_matrix_player_stats[i][j] := inp_player_stats[i][j];
            loc_matrix_player_stats[i][j] := inp_player_stats[inp_subs[i]][j];
        END LOOP;
    END LOOP;

    -- Loop through the 14 available positions of the team
    FOR i IN 1..14 LOOP
        -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
        FOR j IN 1..7 LOOP
            -- Loop through the 6 player stats (keeper, defense, passes, playmaking, winger, scoring, NO FREEKINK !)
            FOR k IN 1..6 LOOP
                team_stats[j] := team_stats[j] + loc_matrix_player_stats[i][k] * CoefMatrix[i][j][k];
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN team_stats;
END;
$function$
;
