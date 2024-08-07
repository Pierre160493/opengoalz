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
    bool_week_advanced bool := FALSE; -- If the the function has to be called again because a full week has being played and so passed to the next one
    bool_league_game_played bool; -- If a game from the league was played, recalculate the rankings
    pos integer; -- Position in the league
BEGIN

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
RAISE NOTICE '****** HANDLE SEASON MAIN: Start multiverse % season % week number %', multiverse.speed, multiverse.season_number, multiverse.week_number;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------ Loop through all leagues
        FOR league IN (
            SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed)
        LOOP

            -- Set to FALSE by default
            bool_league_game_played := FALSE;

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Loop through the games that need to be played for the current week
            FOR game IN
                (SELECT id FROM games
                    WHERE id_league = league.id
                    AND date_end IS NULL
                    AND season_number = multiverse.season_number
                    AND week_number = multiverse.week_number
                    AND now() > date_start
                    ORDER BY id)
            LOOP
                --BEGIN
                    PERFORM simulate_game_main(inp_id_game := game.id);
                --EXCEPTION WHEN others THEN
                --    RAISE NOTICE 'An error occurred while simulating game with id %: %', id_game, SQLERRM;
                --    UPDATE games SET date_end = date_start, error = SQLERRM WHERE id = id_game;
                --END;

                -- Say that a game from the league was simulated
                bool_league_game_played := TRUE;

            END LOOP; -- End of the loop of the games simulation

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------ If a game from the league was played, recalculate the rankings
            IF bool_league_game_played = TRUE THEN

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

        -- Interval of 1 week for this multiverse
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------ If all games from the current week have been played
        IF NOT EXISTS (
            SELECT 1 FROM games
            WHERE multiverse_speed = multiverse.speed
            AND season_number = multiverse.season_number
            AND week_number = multiverse.week_number
            AND date_end IS NULL
        ) THEN
        -- AND if at least 3 hours have passed since the start of the last game (TODO)

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Handle revenues, expanses (tax, salaries, staff)
            -- Calculate the expanses and revenues of the clubs
            UPDATE clubs SET
                lis_tax = lis_tax ||
                    FLOOR(lis_cash[array_length(lis_cash, 1)] * 0.01),
                lis_players_expanses = lis_players_expanses || 
                    (SELECT COALESCE(SUM(expanses), 0)
                        FROM players 
                        WHERE id_club = clubs.id),
                lis_staff_expanses = lis_staff_expanses ||
                    staff_expanses,
                staff_weight = (staff_weight + staff_expanses) * 0.5
            WHERE multiverse_speed = multiverse.speed;

            -- Update the clubs revenues and expanses in the list
            UPDATE clubs SET
                lis_revenues = lis_revenues ||
                    revenues,
                lis_expanses = lis_expanses || (
                    lis_tax[array_length(lis_expanses, 1)] +
                    lis_players_expanses[array_length(lis_players_expanses, 1)] +
                    lis_staff_expanses[array_length(lis_staff_expanses, 1)]
                    )
            WHERE multiverse_speed = multiverse.speed;

            -- Update the clubs cash
            UPDATE clubs SET
                lis_cash = lis_cash ||
                    lis_cash[array_length(lis_cash, 1)] +
                    lis_revenues[array_length(lis_revenues, 1)] -
                    lis_expanses[array_length(lis_expanses, 1)]
            WHERE multiverse_speed = multiverse.speed;

            -- Update the leagues cash by paying club expanses and players salaries and cash last season
            UPDATE leagues SET
                cash = cash + (
                    SELECT SUM(lis_expanses[array_length(lis_expanses, 1)])
                    FROM clubs WHERE id_league = leagues.id
                    ),
                cash_last_season = cash_last_season - (
                    SELECT SUM(lis_revenues[array_length(lis_revenues, 1)])
                    FROM clubs WHERE id_league = leagues.id
                    )
            WHERE multiverse_speed = multiverse.speed
            AND level > 0;

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Update players training points
            UPDATE players SET training_points = training_points + 1 WHERE multiverse_speed = multiverse.speed;

            -- No need to populate the games if the season is not over yet
            IF multiverse.week_number >= 10 THEN

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Handle the 10th week of the season
                IF multiverse.week_number = 10 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;
                    -- Update the normal leagues to say that they are finished
                    UPDATE leagues SET is_finished = TRUE
                        WHERE multiverse_speed = multiverse.speed
                        AND level > 0;
/*
                    -- Update the clubs from the top level leagues that finished 1st, 2nd and 3rd (they stay in the same position)
                    UPDATE clubs SET
                        pos_league_next_season = pos_league,
                        id_league_next_season = id_league
                        WHERE id_league IN (
                            SELECT id FROM leagues
                                WHERE multiverse_speed = multiverse.speed
                                AND level = 1
                        )
                        AND pos_league <= 3;

                    -- Update the clubs from the lowest level leagues that finished 4th, 5th and 6th (they stay in the same position)
                    UPDATE clubs SET
                        pos_league_next_season = pos_league,
                        id_league_next_season = id_league
                        WHERE id_league NOT IN ( -- Exclude the leagues that are the upper leagues
                            SELECT id_upper_league FROM leagues WHERE multiverse_speed = 1
                            AND id_upper_league IS NOT NULL
                        )
                        AND pos_league >= 4;*/

                    -- Update each clubs by default staying at their position
                    UPDATE clubs SET
                        pos_league_next_season = pos_league,
                        id_league_next_season = id_league
                        WHERE multiverse_speed = multiverse.speed;

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Handle the 13th week of the season ==> Intercontinental Cup Leagues are finished
                ELSEIF multiverse.week_number = 13 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;

                    -- Update the normal leagues to say that they are finished
                    UPDATE leagues SET is_finished = TRUE
                        WHERE multiverse_speed = multiverse.speed
                        AND level = 0;

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Handle the 15th week of the season ==> Season is over, start a new one
                ELSEIF multiverse.week_number = 14 THEN
RAISE NOTICE '**** HANDLE SEASON MAIN: Multiverse [%] week_number % handling', multiverse.speed, multiverse.week_number;

                    -- Generate the games_teamcomp and the games of the next season
                    PERFORM handle_season_generate_games_and_teamcomps(
                        inp_multiverse_speed := multiverse.speed,
                        inp_season_number := multiverse.season_number + 2,
                        inp_date_start := multiverse.date_season_end + loc_interval_1_week * 14);

                    -- Update multiverses table for starting next season
                    UPDATE multiverses SET
                        date_season_start = date_season_end,
                        date_season_end = date_season_end + loc_interval_1_week * 14,
                        season_number = season_number + 1,
                        week_number = 0
                    WHERE speed = multiverse.speed;

                    -- Update leagues
                    UPDATE leagues SET
                        season_number = season_number + 1,
                        is_finished = FALSE,
                        cash_last_season = (cash / 1400) * 1400,
                        cash = cash - (cash / 1400) * 1400
                        WHERE multiverse_speed = multiverse.speed;

                    -- Update clubs
                    UPDATE clubs SET
                        season_number = season_number + 1,
                        id_league = id_league_next_season,
                        id_league_next_season = NULL,
                        revenues = (
                            (SELECT cash_last_season FROM leagues WHERE id = id_league) * 
                            CASE 
                                WHEN pos_league = 1 THEN 0.20
                                WHEN pos_league = 2 THEN 0.18
                                WHEN pos_league = 3 THEN 0.17
                                WHEN pos_league = 4 THEN 0.16
                                WHEN pos_league = 5 THEN 0.15
                                WHEN pos_league = 6 THEN 0.14
                                ELSE 0
                            END
                        ) / 14,
                        pos_league = pos_league_next_season,
                        pos_league_next_season = NULL,
                        league_points = 0
                        WHERE multiverse_speed = multiverse.speed;

                    -- Update players
                    UPDATE players SET
                        expanses = FLOOR(expanses + 100 + (keeper + defense + playmaking + passes + winger + scoring + freekick) * 0.5)
                        WHERE multiverse_speed = multiverse.speed;

                END IF;

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------ Loop through the list of games that need to be played in the coming weeks
                FOR game IN (
                    SELECT * FROM games
                        WHERE multiverse_speed = multiverse.speed
                        AND season_number = (SELECT season_number FROM multiverses WHERE speed = multiverse.speed)
                        AND week_number >= (SELECT week_number FROM multiverses WHERE speed = multiverse.speed)
                        AND (id_club_left IS NULL OR id_club_right IS NULL)
                        ORDER BY id
                ) LOOP

                    -- Try to populate the game with the clubs id
                    PERFORM handle_season_populate_game(game.id);
                END LOOP; -- End of the game loop

            END IF; -- End of the week_number check

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------ Update the week number of the multiverse and call the function again
            UPDATE multiverses SET week_number = week_number + 1 WHERE speed = multiverse.speed;

            -- Set this to TRUE to run another loop of simulate_games at the end of this function
            bool_week_advanced := TRUE;

        END IF; -- End if all games of the current week have been played

    END LOOP; -- End of the loop through the multiverses

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------ If the week has been advanced, call this function again
    IF bool_week_advanced IS TRUE THEN
        PERFORM handle_season_main();
    END IF;

END;
$function$
;
