-- DROP FUNCTION public.simulate_week_games(record, int8, int8);

CREATE OR REPLACE FUNCTION public.main_simulate_day(
    inp_multiverse RECORD)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    league RECORD; -- Record for the leagues loop
    club RECORD; -- Record for the clubs loop
    game RECORD; -- Record for the game loop
    is_league_game_finished bool; -- If a game from the league was played, recalculate the rankings
    pos integer; -- Position in the league
BEGIN

    ------ Check if the week is not too early to simulate
    IF inp_multiverse.day_number < 7 THEN

        ---- Increase players energy
        UPDATE players
            SET energy = LEAST(100,
                energy + 10)
        WHERE id_multiverse = inp_multiverse.id;

        RETURN TRUE; -- Return TRUE to say that the day was correctly simulated

    END IF;

    ------------ Loop through all leagues of the multiverse
    FOR league IN (
        SELECT * FROM leagues WHERE id_multiverse = inp_multiverse.id)
    LOOP

        ------ Loop through the games that need to be played for the current week of the current league
        FOR game IN
            (SELECT id FROM games
                WHERE id_league = league.id
                AND date_end IS NULL
                AND season_number <= inp_multiverse.season_number
                AND week_number <= inp_multiverse.week_number
                AND now() > date_start
                ORDER BY season_number, week_number, id)
        LOOP

            -- Simulate the game
            PERFORM simulate_game_main(inp_id_game := game.id);
        
        END LOOP; -- End of the loop of the games simulation

        -- Set to FALSE by default
        is_league_game_finished := FALSE;

        ------ Loop through the games that are finished for the current week of the current league
        FOR game IN
            (SELECT id FROM games
                WHERE id_league = league.id
                AND now() >= date_end
                AND is_playing = TRUE
                AND season_number <= inp_multiverse.season_number
                AND week_number <= inp_multiverse.week_number
                ORDER BY id)
        LOOP
            PERFORM simulate_game_set_is_played(inp_id_game := game.id);

            -- Say that a game from the league was finished
            is_league_game_finished := TRUE;
        
        END LOOP; -- End of the loop of the games simulation

        -- If a game from the league was played, recalculate the rankings
        IF is_league_game_finished = TRUE THEN
            -- Calculate rankings for normal leagues
            IF league.LEVEL > 0 AND inp_multiverse.week_number <= 10 THEN
                -- Calculate rankings for each clubs in the league
                pos := 1;
                FOR club IN
                    (SELECT * FROM clubs
                        WHERE id_league = league.id
                        ORDER BY league_points DESC,
                            (league_goals_for - league_goals_against) DESC,
                            pos_last_season,
                            created_at ASC)
                LOOP
                    -- Update the position in the league of this club
                    UPDATE clubs
                        SET pos_league = pos
                        WHERE id = club.id;

                    -- Update the leagues rankings
                    UPDATE leagues
                        SET id_clubs[pos] = club.id,
                        points[pos] = club.league_points
                        WHERE id = league.id;

                    -- Update the position
                    pos := pos + 1;
                    
                END LOOP; -- End of the loop through clubs
            END IF; -- End of the calculation of the rankings of the normal leagues
        END IF; -- End of the check if a game from the league was played
    END LOOP; -- End of the loop through leagues

    ------ If all games of the week are finished, return TRUE
    IF (
        -- Check if there are games from the current week that are not finished
        SELECT COUNT(id)
        FROM games
        WHERE is_playing <> FALSE
        AND season_number = inp_multiverse.season_number
        AND week_number = inp_multiverse.week_number) > 0
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
    
END;
$function$
;
