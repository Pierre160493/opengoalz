CREATE OR REPLACE FUNCTION public.simulate_game_fetch_player_stats(inp_player_ids bigint[21])
 RETURNS float8[21][6]
 LANGUAGE plpgsql
AS $function$
DECLARE
    player_stats float8[21][6] := '{
        {0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},
        {0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},
        {0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}}'; -- Matrix to hold player stats
    temp_stats float8[6]; -- Temporary array to hold stats for a single player
    i INT;
    j INT;
BEGIN

    -- Loop through the input player IDs and fetch their stats
    FOR i IN 1..21 LOOP
        IF inp_player_ids[i] IS NOT NULL THEN
            -- Select player stats into temp_stats
            SELECT ARRAY[keeper, defense, playmaking, passes, scoring, winger]
            INTO temp_stats
            FROM players
            WHERE id = inp_player_ids[i];

            IF FOUND THEN
                FOR j IN 1..6 LOOP
                    player_stats[i][j] := temp_stats[j];
                END LOOP;
            ELSE
                RAISE EXCEPTION 'Player with ID % not found', inp_player_ids[i];
            END IF;
        END IF;
    END LOOP;

    RETURN player_stats;

END;
$function$;