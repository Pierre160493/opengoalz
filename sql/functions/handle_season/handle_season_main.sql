-- DROP FUNCTION public.handle_season_main();

CREATE OR REPLACE FUNCTION public.handle_season_main()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    league RECORD; -- Record for the leagues loop
    club RECORD; -- Record for the clubs loop
    game RECORD; -- Record for the game loop
    loc_interval_1_week INTERVAL; -- Interval time for a week in this multiverse
    bool_week_advanced bool := FALSE; -- If the the simulate_games function has to be called again
    pos integer; -- Position in the league
BEGIN
RAISE NOTICE '****** HANDLE SEASON MAIN: Start';
    -- Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP

        -- Loop through all leagues
        FOR league IN (
            SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed)
        LOOP

            -- Loop through the games that need to be played for the current week
            FOR game IN
                (SELECT id FROM games
                    WHERE id_league = league.id
                    AND is_played = FALSE
                    AND week_number = multiverse.week_number
                    AND now() > date_start
                    ORDER BY id)
            LOOP
                --BEGIN
                    PERFORM simulate_game(inp_id_game := game.id);
                --EXCEPTION WHEN others THEN
                --    RAISE NOTICE 'An error occurred while simulating game with id %: %', id_game, SQLERRM;
                --    UPDATE games SET is_played = TRUE, error = SQLERRM WHERE id = id_game;
                --END;

                -- Calculate rankings for normal leagues
                IF league.LEVEL > 0 THEN
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
                END IF; -- End of the calculation of the rankings of the normal leagues

            END LOOP; -- End of the loop of the games simulation

        END LOOP; -- End of the loop through leagues

        -- Interval of 1 week for this multiverse
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed;

        -- If the current week is over, update the week number
        IF NOT EXISTS (
            SELECT 1 FROM games
            WHERE multiverse_speed = multiverse.speed
            AND season_number = multiverse.season_number
            AND week_number = multiverse.week_number
            AND is_played = FALSE
        ) THEN
        -- AND if at least 3 hours have passed since the start of the last game

            -- No need to populate the games if the season is not over yet
            IF multiverse.week_number >= 10 THEN
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Handle the 10th week of the season
                IF multiverse.week_number = 10 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;
                    -- Update the normal leagues to say that they are finished
                    UPDATE leagues SET is_finished = TRUE
                        WHERE multiverse_speed = multiverse.speed
                        AND level > 0;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Handle the 13th week of the season ==> Intercontinental Cup Leagues are finished
                ELSEIF multiverse.week_number = 13 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;

                    -- Update the normal leagues to say that they are finished
                    UPDATE leagues SET is_finished = TRUE
                        WHERE multiverse_speed = multiverse.speed
                        AND level = 0;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Handle the 15th week of the season ==> Season is over, start a new one
                ELSEIF multiverse.week_number = 14 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;

                    -- Update multiverses table for starting next season
                    UPDATE multiverses SET
                        date_season_start = date_season_end,
                        date_season_end = date_season_end + loc_interval_1_week * 14,
                        season_number = season_number + 1,
                        week_number = 1
                    WHERE speed = multiverse.speed;

                    -- Update leagues
                    UPDATE leagues SET
                        season_number = season_number + 1,
                        is_finished = FALSE
                        WHERE multiverse_speed = multiverse.speed;

                    -- Update clubs
                    UPDATE clubs SET
                        season_number = season_number + 1,
                        id_league = id_league_next_season,
                        id_league_next_season = NULL,
                        pos_league = pos_league_next_season,
                        pos_league_next_season = NULL,
                        league_points = 0
                        WHERE multiverse_speed = multiverse.speed;

                END IF;

                -- Loop through the list of games that need to be played in the coming weeks
                FOR game IN (
                    SELECT * FROM games
                        WHERE multiverse_speed = multiverse.speed
                        AND season_number = (SELECT season_number FROM multiverses WHERE speed = multiverse.speed)
                        AND week_number >= (SELECT week_number FROM multiverses WHERE speed = multiverse.speed)
                        AND (id_club_left IS NULL OR id_club_right IS NULL)
                        ORDER BY id
                ) LOOP
--RAISE NOTICE 'game.id= %', game.id;
                    -- Try to populate the game with the clubs id
                    PERFORM handle_season_populate_game(game.id);
                END LOOP; -- End of the game loop

            END IF; -- End of the week_number check

            -- Update the week number of the multiverse
            UPDATE multiverses SET week_number = week_number + 1 WHERE speed = multiverse.speed;

            -- Set this to TRUE to run another loop of simulate_games at the end of this function
            bool_week_advanced := TRUE;

        END IF; -- End if all games of the current week have been played

    END LOOP; -- End of the loop through the multiverses

    -- If the week has been advanced, call this function again
    IF bool_week_advanced IS TRUE THEN
        PERFORM handle_season_main();
    END IF;

END;
$function$
;
