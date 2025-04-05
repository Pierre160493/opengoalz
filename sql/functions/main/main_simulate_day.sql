-- DROP FUNCTION public.main_simulate_day(record);

CREATE OR REPLACE FUNCTION public.main_simulate_day(inp_multiverse record)
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

    ---- Increase players energy
    UPDATE players
        SET energy = LEAST(100,
            energy + (100 - energy) / 5.0)
    WHERE id_multiverse = inp_multiverse.id
    AND date_death IS NULL;

    WITH players1 AS (
        SELECT 
            players.id,
            player_get_full_name(players.id) AS full_name,
            calculate_age(multiverses.speed, players.date_birth) AS age,
            players.id_club
        FROM players
        JOIN multiverses ON multiverses.id = players.id_multiverse
        LEFT JOIN clubs ON clubs.id = players.id_club 
        -- LEFT JOIN players_poaching ON players_poaching.id_player = players.id
        WHERE players.id_multiverse = inp_multiverse.id
        AND players.date_death IS NULL
        GROUP BY players.id, multiverses.speed, players.id_club, clubs.username
    )
    UPDATE players SET
        -- Randomly kill old players
        date_death = CASE
            WHEN random() < ((age - 70) / 100.0) THEN inp_multiverse.date_handling
            ELSE NULL END
    FROM players1
    WHERE players.id = players1.id
    AND players.id NOT IN (SELECT id_player FROM transfers_bids); -- Don't kill players that have bids on them (TO OPTIMIZE)

    ------ Handling of the day 7 ==> Game day
    IF inp_multiverse.day_number = 7 THEN

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
            WHERE id_multiverse = inp_multiverse.id
            AND is_playing <> FALSE
            AND season_number = inp_multiverse.season_number
            AND week_number = inp_multiverse.week_number) > 0
        THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    END IF; -- End of the handling of week 7

    RETURN TRUE; -- Return TRUE to say that we can pass to the next day
    
END;
$function$
;
