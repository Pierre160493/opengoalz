CREATE OR REPLACE FUNCTION public.simulate_game_calculate_game_weights(inp_player_stats float8[21][6], inp_subs bigint[7])
 RETURNS float8[7]
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_matrix_player_stats float8[14][6] := '
{{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},
{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}}
'; -- Matrix to hold player stats [14 starters x 6 player stats]
    CoefMatrix float8[14][7][6] := '
{{{0.25,0.1,0,0,0,0},{0.5,0.2,0,0,0,0},{0.25,0.1,0,0,0,0},{0,0,0.1,0.2,0,0},{0,0,0,0.1,0,0},{0,0,0,0.1,0,0},{0,0,0,0.1,0,0}},
{{0,0.6,0,0,0,0},{0,0.3,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.3,0.3,0,0},{0,0,0,0.2,0.2,0.6},{0,0,0,0.1,0.1,0.1},{0,0,0,0,0,0}},
{{0,0.3,0,0,0,0},{0,0.8,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.3,0.2,0,0},{0,0,0,0.2,0.1,0.2},{0,0,0,0.1,0.2,0},{0,0,0,0.1,0,0}},
{{0,0.2,0,0,0,0},{0,0.8,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.3,0.2,0,0},{0,0,0,0.1,0,0},{0,0,0,0.2,0.3,0},{0,0,0,0.1,0,0}},
{{0,0.2,0,0,0,0},{0,0.8,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.3,0.2,0,0},{0,0,0,0.1,0,0},{0,0,0,0.2,0.3,0},{0,0,0,0.1,0,0}},
{{0,0.1,0,0,0,0},{0,0.8,0,0,0,0},{0,0.3,0,0,0,0},{0,0,0.3,0.2,0,0},{0,0,0,0.1,0,0},{0,0,0,0.1,0.2,0},{0,0,0,0.2,0.1,0.2}},
{{0,0.4,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0.5,0.3,0,0},{0,0,0,0.3,0.5,0.7},{0,0,0,0.2,0.3,0.2},{0,0,0,0,0,0.1}},
{{0,0.2,0,0,0,0},{0,0.4,0,0,0,0},{0,0,0,0,0,0},{0,0,0.6,0.3,0,0},{0,0,0,0.2,0.2,0.3},{0,0,0,0.4,0.3,0.2},{0,0,0,0,0.1,0.1}},
{{0,0.1,0,0,0,0},{0,0.5,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.6,0.3,0,0},{0,0,0,0.1,0.1,0.1},{0,0,0,0.4,0.4,0.3},{0,0,0,0.1,0.1,0.1}},
{{0,0,0,0,0,0},{0,0.4,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.6,0.3,0,0},{0,0,0,0,0.1,0.1},{0,0,0,0.4,0.3,0.2},{0,0,0,0.2,0.2,0.3}},
{{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0.4,0,0,0,0},{0,0,0.5,0.3,0,0},{0,0,0,0,0,0.1},{0,0,0,0.2,0.3,0.2},{0,0,0,0.3,0.5,0.7}},
{{0,0.2,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0,0,0,0},{0,0,0.4,0.3,0,0},{0,0,0,0.3,0.4,0.4},{0,0,0,0.3,0.4,0.3},{0,0,0,0.1,0.1,0.1}},
{{0,0.1,0,0,0,0},{0,0.2,0,0,0,0},{0,0.1,0,0,0,0},{0,0,0.3,0.3,0,0},{0,0,0,0.2,0.2,0.2},{0,0,0,0.3,0.6,0.3},{0,0,0,0.2,0.2,0.2}},
{{0,0,0,0,0,0},{0,0.1,0,0,0,0},{0,0.2,0,0,0,0},{0,0,0.4,0.3,0,0},{0,0,0,0.1,0.1,0.1},{0,0,0,0.3,0.4,0.3},{0,0,0,0.3,0.4,0.4}}}
'; -- 3D Matrix to calculate team stats [14 starters x 7 game weights x 6 player stats]
    team_stats float8[7] := '{0,0,0,0,0,0,0}'; -- Array to hold team stats
    i INT;
    j INT;
    k INT;
BEGIN
    -- Initialize the loc_matrix_player_stats array with zeros
    FOR i IN 1..14 LOOP
        FOR j IN 1..6 LOOP
            loc_matrix_player_stats[i][j] := 0;
        END LOOP;
    END LOOP;

    -- Loop through the 13 starters players
    FOR i IN 1..13 LOOP
        -- Loop through the 6 player stats (Keeper, Defense, Playmaking, Passes, Scoring, Winger)
        FOR j IN 1..6 LOOP
            -- Assign player stats to loc_matrix_player_stats matrix
            loc_matrix_player_stats[i][j] := inp_player_stats[i][j];
        END LOOP;
    END LOOP;

    -- Check if there were any substitutions made
    FOR i IN 1..7 LOOP
        -- If a substitution was made
        IF inp_subs[i] IS NOT NULL AND inp_subs[i] != 0 THEN
            -- Input validation
            IF inp_subs[i] > 13 OR inp_subs[i] < 1 THEN
                RAISE EXCEPTION 'Invalid player position for substitution, must be between 1 and 13, found: %', inp_subs[i];
            END IF;

            -- Loop through the 6 player stats (Keeper, Defense, Playmaking, Passes, Scoring, Winger)
            FOR j IN 1..6 LOOP
                -- Assign player stats to loc_matrix_player_stats matrix
                loc_matrix_player_stats[inp_subs[i]][j] := inp_player_stats[i+14][j];
            END LOOP;
        END IF;
    END LOOP;

    -- Loop through the 14 positions of the team
    FOR i IN 1..14 LOOP
        -- Loop through the 7 team stats (LeftDefense, CentralDefense, RightDefense, MidField, LeftAttack, CentralAttack, RightAttack)
        FOR j IN 1..7 LOOP
            -- Loop through the 6 player stats (Keeper, Defense, Playmaking, Passes, Scoring, Winger)
            FOR k IN 1..6 LOOP
                team_stats[j] := team_stats[j] + loc_matrix_player_stats[i][k] * CoefMatrix[i][j][k];
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN team_stats;
END;
$function$
;