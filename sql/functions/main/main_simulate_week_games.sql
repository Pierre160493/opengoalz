CREATE OR REPLACE FUNCTION public.main_simulate_week_games(
    inp_multiverse RECORD)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
    league RECORD;
    game RECORD;
    club RECORD;
    pos INT;
    is_league_game_finished BOOLEAN;

    -- Add execution time tracking
    loc_start_time TIMESTAMP := clock_timestamp();
    loc_end_time TIMESTAMP;
BEGIN

    -- Loop through all leagues of the multiverse
    FOR league IN (
        SELECT * FROM leagues WHERE id_multiverse = inp_multiverse.id)
    LOOP
        -- Loop through the games that need to be played for the current week of the current league
        FOR game IN (
            SELECT
                id,
                (date_start < now() - INTERVAL '1 day') AS is_running_late
            FROM games
            WHERE id_league = league.id
            AND date_end IS NULL
            AND season_number <= inp_multiverse.season_number
            AND week_number <= inp_multiverse.week_number
            AND now() > date_start
            ORDER BY season_number, week_number, id)
        LOOP
            -- Simulate the game
            IF game.is_running_late = TRUE THEN
                -- RAISE NOTICE 'Game %: Simulate game main (SPEEDY)', game.id;
                PERFORM simulate_game_speedy(inp_id_game := game.id);
            ELSE
                PERFORM simulate_game_main(inp_id_game := game.id);
            END IF;
        END LOOP;

        -- Set to FALSE by default
        is_league_game_finished := FALSE;

        -- Loop through the games that are finished for the current week of the current league
        FOR game IN (
            SELECT id FROM games
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
        END LOOP;

        -- If a game from the league was played, recalculate the rankings
        IF is_league_game_finished = TRUE THEN
            -- Calculate rankings for normal leagues
            IF league.LEVEL > 0 AND inp_multiverse.week_number <= 10 THEN
                -- Calculate rankings for each club in the league
                pos := 1;
                FOR club IN (
                    SELECT * FROM clubs
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
                END LOOP;
            END IF;
        END IF;
    END LOOP;

    -- Calculate execution time at the end of the function
    loc_end_time := clock_timestamp();

    -- Log the execution time
    RAISE NOTICE 'Execution time for main_simulate_week_games: %', loc_end_time - loc_start_time;
    -- RAISE EXCEPTION 'Execution time for main_simulate_week_games: %', loc_end_time - loc_start_time;
END;
$function$;
