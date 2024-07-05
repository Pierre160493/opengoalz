CREATE OR REPLACE FUNCTION public.simulate_games()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    id_game bigint;
BEGIN
    ------ Loop through the list of games that need to be played
    FOR id_game IN
        SELECT id FROM games
        WHERE is_played = FALSE AND date_start < now()
    LOOP
        ---- Check that the clubs id are correctly set

        ------ Simulate the game
        BEGIN
            PERFORM simulate_game(inp_id_game := id_game);
        EXCEPTION WHEN others THEN
            -- Do something
            RAISE NOTICE 'An error occurred while simulating game with id %: %', id_game, SQLERRM;
            UPDATE games SET is_played = TRUE, error = SQLERRM WHERE id = id_game;
        END;
    END LOOP;

END;
$function$
;