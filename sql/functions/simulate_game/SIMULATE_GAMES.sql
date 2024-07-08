-- DROP FUNCTION public.simulate_games();

CREATE OR REPLACE FUNCTION public.simulate_games()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_game bigint; -- Game id
    loc_week_number integer; -- Week number
    multiverse RECORD; -- Record for each multiverses
    league RECORD; -- Record for each leagues
    club RECORD; -- Record for each clubs
    pos integer; -- Position
BEGIN

    ------ Check if a league is fully played
    -- Loop throuh all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP

        -- Loop through all leagues
        FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed ORDER BY level) LOOP

            -- Loop through all games that need to be played
            FOR loc_week_number IN 1..10 LOOP
                FOR loc_id_game IN
                    (SELECT id FROM games
                        WHERE id_league = league.id
                        AND is_played = FALSE
                        AND week_number = loc_week_number)
                LOOP
                    --BEGIN
                        PERFORM simulate_game(inp_id_game := loc_id_game);
                    --EXCEPTION WHEN others THEN
                    --    RAISE NOTICE 'An error occurred while simulating game with id %: %', id_game, SQLERRM;
                    --    UPDATE games SET is_played = TRUE, error = SQLERRM WHERE id = id_game;
                    --END;

                END LOOP;

                -- Calculate rankings for each clubs in the league
                pos := 1;
                FOR club IN
                    (SELECT * FROM clubs
                        WHERE id_league = league.id
                        ORDER BY league_points DESC)
                LOOP
                    -- Update the position in the league of this club
                    UPDATE clubs
                        SET pos_league = pos
                        WHERE id = club.id;

                    -- Update the position
                    pos := pos + 1;
                END LOOP; -- End of the loop through clubs
            END LOOP; -- End of the loop through weeks
        END LOOP;  -- End of the loop through leagues
    END LOOP; -- End of the loop through multiverses

    PERFORM handle_generation_after_season_games_and_new_season();

END;
$function$
;
