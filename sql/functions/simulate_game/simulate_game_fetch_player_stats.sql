-- DROP FUNCTION public.simulate_game_fetch_player_stats(_int8);

CREATE OR REPLACE FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[])
 RETURNS double precision[]
 LANGUAGE plpgsql
AS $function$
DECLARE
    player_stats float8[21][12] := array_fill(0::float8, ARRAY[21,12]);
    temp_stats float8[10]; -- Temporary array to hold stats for a single player
    i INT;
    j INT;
BEGIN

    ------ Loop through the input player IDs and fetch their stats
    FOR i IN 1..21 LOOP -- 21 players per game per team
        IF inp_player_ids[i] IS NOT NULL THEN
            -- Select player stats into temp_stats
            SELECT ARRAY[keeper, defense, passes, playmaking, winger, scoring, freekick,
                motivation, form, experience, stamina, energy]
            INTO temp_stats
            FROM players
            WHERE id = inp_player_ids[i];

            IF FOUND THEN
                FOR j IN 1..12 LOOP -- Loop through the 12 player stats
                    player_stats[i][j] := temp_stats[j];
                END LOOP;
            ELSE
                RAISE EXCEPTION 'Player with ID % not found', inp_player_ids[i];
            END IF;
        END IF;
    END LOOP;

    ------ Return the player stats array
    RETURN player_stats;

END;
$function$
;
