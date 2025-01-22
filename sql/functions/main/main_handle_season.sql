-- DROP FUNCTION public.main_handle_season(record);

CREATE OR REPLACE FUNCTION public.main_handle_season(
    inp_multiverse record)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_record RECORD; -- Record for the game loop
    loc_id_player bigint; -- Variable to store the inserted player's ID
BEGIN

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------------ Handle the weeks of the season
    CASE
        ---- Handle the 10th week of the season
        WHEN inp_multiverse.week_number = 10 THEN
RAISE NOTICE '*** MAIN: Multiverse [%] S%W%D%: HANDLE SEASON: WEEK10', inp_multiverse.name, inp_multiverse.season_number, inp_multiverse.week_number, inp_multiverse.day_number;
            -- Update the normal leagues to say that they are finished
            UPDATE leagues SET is_finished = TRUE
            WHERE id_multiverse = inp_multiverse.id
            AND level > 0;

            -- Update each club by default staying at their position
            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league,
                pos_last_season = pos_league
            WHERE id_multiverse = inp_multiverse.id;

            ------ Send mail to each club indicating their position in the league
            WITH club_league_info AS (
                SELECT 
                    clubs.id,
                    clubs.id_multiverse,
                    clubs.continent,
                    clubs.id_country,
                    clubs.id_league,
                    leagues.season_number,
                    leagues.id_upper_league,
                    leagues.id_lower_league,
                    -- Calculate overall points
                    (10000000 - (leagues.level * 100000)) + ((7 - clubs.pos_league) * 10000) + (clubs.league_points * 1000) + clubs.league_goals_for - clubs.league_goals_against AS overall_points,
                    leagues.level,
                    clubs.pos_league,
                    clubs.league_points,
                    clubs.league_goals_for - clubs.league_goals_against AS goal_diff,
                    -- Calculate overall ranking
                    ROW_NUMBER() OVER (ORDER BY (10000000 - (leagues.level * 100000)) + ((7 - clubs.pos_league) * 10000) + (clubs.league_points * 1000) + clubs.league_goals_for - clubs.league_goals_against DESC) AS overall_ranking
                FROM clubs
                JOIN leagues ON leagues.id = clubs.id_league
                WHERE clubs.id_multiverse = inp_multiverse.id
                ORDER BY overall_points DESC
            )
            -- Send mail to each club indicating their position in the league
            INSERT INTO messages_mail (id_club_to, sender_role, title, message)
            SELECT 
                id AS id_club_to, 'Coach' AS sender_role,
                -- inp_multiverse.date_handling + INTERVAL '1 second' * EXTRACT(SECOND FROM CURRENT_TIMESTAMP) + INTERVAL '1 millisecond' * EXTRACT(MILLISECOND FROM CURRENT_TIMESTAMP),
                'Finished ' || 
                CASE 
                    WHEN pos_league = 1 THEN '1st'
                    WHEN pos_league = 2 THEN '2nd'
                    WHEN pos_league = 3 THEN '3rd'
                    ELSE pos_league || 'th'
                END
                || ' of ' || string_parser(id_league, 'idLeague') || ' in season ' || inp_multiverse.season_number AS title,
                CASE
                    -- 1st place
                    WHEN pos_league = 1 THEN
                        -- Highest league plays international games
                        CASE WHEN id_upper_league IS NULL THEN
                            'We are the champions of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 1st international league during the interseason ! That''s fantastic !'
                        -- Other leagues play barrages to win promotion
                        ELSE
                            'We are the champions of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 1st barrage to try and win our promotion to the upper league ! Let''s do it !'
                        END
                    WHEN pos_league = 2 THEN
                        -- Highest league plays international games
                        CASE WHEN id_upper_league IS NULL THEN
                            'We finished 2nd of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 2nd international league during the interseason ! That''s fantastic !'
                        -- Other leagues play barrages to win promotion
                        ELSE
                            'We finished 2nd of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 2nd barrage to try and win our promotion to the upper league ! Let''s do it !'
                        END
                    WHEN pos_league = 3 THEN
                        -- Highest league plays international games
                        CASE WHEN id_upper_league IS NULL THEN
                            'We finished 3rd of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 3rd international league during the interseason ! That''s fantastic !'
                        -- Other leagues play barrages to win promotion
                        ELSE
                            'We finished 3rd of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play the 2nd barrage to try and win our promotion to the upper league ! Let''s do it !'
                        END
                    WHEN pos_league = 4 THEN
                        -- Lowest league plays friendly games during interseason
                        CASE WHEN id_lower_league IS NULL THEN
                            'We finished 4th of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play some friendly games during the interseason ! It''s a good opportunity to test new tactics for the next season !'
                        -- Other leagues play barrages to avoid relegation
                        ELSE
                            'We finished 4th of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play against the winner of the 2nd barrage in order to avoid demotion ! The season is not over yet, keep the players focused !'
                        END
                    WHEN pos_league = 5 THEN
                        -- Lowest league plays friendly games during interseason
                        CASE WHEN id_lower_league IS NULL THEN
                            'We finished 5th of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play some friendly games during the interseason ! It''s a good opportunity to test new tactics for the next season !'
                        -- Other leagues play barrages to avoid relegation
                        ELSE
                            'We finished 5th of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play against the team from the 1st barrage in order to avoid demotion ! The season is not over yet, keep the players focused !'
                        END
                    WHEN pos_league = 6 THEN
                        -- Lowest league plays friendly games during interseason
                        CASE WHEN id_lower_league IS NULL THEN
                            'Rough season... We finished last of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will play some friendly games during the interseason ! It''s a good opportunity to test new tactics for the next season !'
                        -- Other leagues play barrages to avoid relegation
                        ELSE
                            'Rough season... We finished last of ' || string_parser(id_league, 'idLeague') || ' for season ' || inp_multiverse.season_number || ' ! We will be demoted to the lower league... But don''t give up, we will come back stronger next season !'
                        END
                END AS message
            FROM club_league_info;

            ------ Insert into clubs_history table
            INSERT INTO clubs_history (id_club, description)
            SELECT
                clubs.id AS id_club,
                'Season ' || inp_multiverse.season_number || 'Finished ' ||
                CASE
                    WHEN pos_league = 1 THEN '1st'
                    WHEN pos_league = 2 THEN '2nd'
                    WHEN pos_league = 3 THEN '3rd'
                    ELSE pos_league || 'th'
                END
                || ' of ' || string_parser(leagues.id, 'idLeague') || ' of ' || leagues.continent AS description
            FROM clubs
            JOIN leagues ON clubs.id_league = leagues.id
            WHERE clubs.id_multiverse = inp_multiverse.id;

            -- Insert into players_history table
            INSERT INTO players_history (id_player, id_club, description, is_ranking_description)
            SELECT
                players.id AS id_player, players.id_club AS id_club,
                'Season ' || inp_multiverse.season_number || ': ' || 
                CASE
                    WHEN clubs.pos_league = 1 THEN 'Champions'
                    WHEN clubs.pos_league = 2 THEN '2nd'
                    WHEN clubs.pos_league = 3 THEN '3rd'
                    WHEN clubs.pos_league = 4 THEN '4th'
                    WHEN clubs.pos_league = 5 THEN '5th'
                    WHEN clubs.pos_league = 6 THEN '6th'
                END
                || ' of ' || string_parser(clubs.id_league, 'idLeague') || '
                with ' || string_parser(clubs.id, 'idClub') || ' in ' || clubs.continent AS description,
                TRUE AS is_ranking_description
            FROM players
            JOIN clubs ON players.id_club = clubs.id
            JOIN leagues ON leagues.id = clubs.id_league
            WHERE clubs.id_multiverse = inp_multiverse.id
            AND id_club IS NOT NULL;

        ---- Handle the 13th week of the season ==> Intercontinental Cup Leagues are finished
        WHEN inp_multiverse.week_number = 13 THEN
RAISE NOTICE '*** MAIN: Multiverse [%] S%W%D%: HANDLE SEASON: WEEK13', inp_multiverse.name, inp_multiverse.season_number, inp_multiverse.week_number, inp_multiverse.day_number;
            -- Update the special leagues to say that they are finished
            UPDATE leagues SET is_finished = TRUE
            WHERE id_multiverse = inp_multiverse.id AND level = 0;

        ---- Handle the 14th week of the season ==> Season is over, start a new one
        WHEN inp_multiverse.week_number = 14 THEN
RAISE NOTICE '*** MAIN: Multiverse [%] S%W%D%: HANDLE SEASON: WEEK14', inp_multiverse.name, inp_multiverse.season_number, inp_multiverse.week_number, inp_multiverse.day_number;

            -- Generate the games_teamcomp and the games of the next season
            PERFORM main_generate_games_and_teamcomps(
                inp_id_multiverse := inp_multiverse.id,
                inp_season_number := inp_multiverse.season_number + 2,
                inp_date_start := inp_multiverse.date_season_end + (14 * INTERVAL '7 days' / inp_multiverse.speed)
            );

            -- Update multiverses table for starting next season
            UPDATE multiverses SET
                date_season_start = date_season_end,
                date_season_end = date_season_end + (14 * INTERVAL '7 days' / inp_multiverse.speed),
                season_number = season_number + 1,
                week_number = 0
            WHERE id = inp_multiverse.id;

            -- Update leagues
            UPDATE leagues SET
                season_number = season_number + 1,
                is_finished = NULL,
                cash_last_season = (cash / 1400) * 1400,
                cash = cash - (cash / 1400) * 1400
            WHERE id_multiverse = inp_multiverse.id;

            -- Update clubs
            UPDATE clubs SET
                season_number = season_number + 1,
                id_league = id_league_next_season,
                -- id_league_next_season = NULL,
                revenues_sponsors_last_season = revenues_sponsors,
                revenues_sponsors = (SELECT cash_last_season FROM leagues WHERE id = id_league) * 
                    CASE 
                        WHEN pos_league = 1 THEN 0.20
                        WHEN pos_league = 2 THEN 0.18
                        WHEN pos_league = 3 THEN 0.17
                        WHEN pos_league = 4 THEN 0.16
                        WHEN pos_league = 5 THEN 0.15
                        WHEN pos_league = 6 THEN 0.14
                        ELSE 0
                    END
                / 14,
                pos_league = pos_league_next_season,
                pos_league_next_season = NULL,
                league_points = 0,
                league_goals_for = 0,
                league_goals_against = 0
            WHERE id_multiverse = inp_multiverse.id;

            -- Ensure there are always 6 clubs per league
            FOR loc_record IN (
                SELECT leagues.id AS league_id, array_agg(clubs.id) AS club_ids
                FROM leagues
                JOIN clubs ON clubs.id_league = leagues.id
                WHERE leagues.id_multiverse = inp_multiverse.id
                AND LEVEL > 0
                GROUP BY leagues.id
                HAVING count(leagues.id) <> 6
            ) LOOP
                RAISE EXCEPTION 'League % does not contain exactly 6 clubs. Clubs: %', loc_record.league_id, loc_record.club_ids;
            END LOOP;

            WITH club_expenses AS (
                SELECT 
                    id_club,
                    SUM(expenses_expected) AS total_player_expenses
                FROM players
                GROUP BY id_club
            )
            -- Send mail to each club indicating their position in the league
            INSERT INTO messages_mail (id_club_to, sender_role, title, message)
                SELECT 
                    id AS id_club_to, 'Treasurer' AS sender_role,
                    -- inp_multiverse.date_season_start + (INTERVAL '7 days' * inp_multiverse.week_number / inp_multiverse.speed),
                    'New season ' || inp_multiverse.season_number + 1 || ' starts for league ' || string_parser(clubs.id_league, 'idLeague') AS title,
                    string_parser(clubs.id_league, 'idLeague') || ' season ' || inp_multiverse.season_number + 1 || ' is ready to start. This season we managed to secure ' || revenues_sponsors || ' per week from sponsors (this season we had ' || revenues_sponsors_last_season || '). The players salary will amount for ' || COALESCE(club_expenses.total_player_expenses, 0) || ' per week and the targeted staff expenses is ' || expenses_staff_target AS message
                FROM clubs
                LEFT JOIN club_expenses ON club_expenses.id_club = clubs.id
            WHERE clubs.id_multiverse = inp_multiverse.id;

            -- Update players
            UPDATE players SET
                -- expenses_expected = FLOOR(
                --     (expenses_expected * 0.75 + 
                --     (100 +
                --     GREATEST(keeper, defense, playmaking, passes, winger, scoring, freekick) +
                --     (keeper + defense + playmaking + passes + winger + scoring + freekick) / 3
                --     ) * 0.25)),
                expenses_expected = FLOOR(
                    (expenses_expected * 0.75 + 
                    expenses_target * 0.25)),
                training_points_used = 0
            WHERE id_multiverse = inp_multiverse.id;

        ELSE
    END CASE;

    ------------------------------------------------------------------------
    ------------------------------------------------------------------------
    ------------ Try to populate the games for weeks greater than 10
    IF inp_multiverse.week_number >= 10 THEN
        ------ Loop through the list of games that can be populated
        FOR loc_record IN (
            SELECT games.* FROM games
            JOIN games_description ON games.id_games_description = games_description.id
            WHERE id_multiverse = inp_multiverse.id
            AND season_number = (SELECT season_number FROM multiverses WHERE id = inp_multiverse.id)
            AND games_description.week_set_up = (SELECT week_number FROM multiverses WHERE id = inp_multiverse.id)
            AND (id_club_left IS NULL OR id_club_right IS NULL)
            ORDER BY games.id
        ) LOOP
--RAISE NOTICE '*** MAIN: Populating games for Multiverse [%] S% WEEK % ==> id_game = %', inp_multiverse.name, inp_multiverse.season_number, inp_multiverse.week_number, loc_record.id;
            PERFORM main_populate_game(loc_record);
        END LOOP; --- End of the game loop
    END IF; -- End of the week_number check

END;
$function$
;
