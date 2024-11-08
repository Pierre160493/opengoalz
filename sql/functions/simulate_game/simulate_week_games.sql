CREATE OR REPLACE FUNCTION public.simulate_week_games(
    multiverse RECORD,
    inp_season_number int8,
    inp_week_number int8
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    league RECORD; -- Record for the leagues loop
    club RECORD; -- Record for the clubs loop
    game RECORD; -- Record for the game loop
    is_league_game_played bool; -- If a game from the league was played, recalculate the rankings
    pos integer; -- Position in the league
BEGIN

    -- Loop through all leagues
    FOR league IN (
        SELECT * FROM leagues WHERE id_multiverse = multiverse.id)
    LOOP
        -- Set to FALSE by default
        is_league_game_played := FALSE;

        -- Loop through the games that need to be played for the current week
        FOR game IN
            (SELECT id FROM games
                WHERE id_league = league.id
                AND date_end IS NULL
                AND season_number = inp_season_number
                AND week_number = inp_week_number
                --AND now() > date_start
                ORDER BY id)
        LOOP
            PERFORM simulate_game_main(inp_id_game := game.id);

            -- Say that a game from the league was simulated
            is_league_game_played := TRUE;
        
        END LOOP; -- End of the loop of the games simulation

        -- If a game from the league was played, recalculate the rankings
        IF is_league_game_played = TRUE THEN
            -- Calculate rankings for normal leagues
            IF league.LEVEL > 0 AND multiverse.week_number <= 10 THEN
                -- Calculate rankings for each clubs in the league
                pos := 1;
                FOR club IN
                    (SELECT * FROM clubs
                        WHERE id_league = league.id
                        ORDER BY league_points DESC, pos_last_season, created_at ASC)
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
        END IF;
    END LOOP; -- End of the loop through leagues

END;
$function$;