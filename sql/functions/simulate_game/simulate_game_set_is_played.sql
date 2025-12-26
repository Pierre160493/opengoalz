CREATE OR REPLACE FUNCTION public.simulate_game_set_is_played(
    inp_id_game bigint
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    rec_game RECORD; -- Record to store the game data
    text_title_winner TEXT; -- Title of the message for the left club
    text_title_loser TEXT; -- Title of the message for the right club
    text_message_winner TEXT; -- Message of the message for the left club
    text_message_loser TEXT; -- Message of the message for the right club
    tmp_text1 TEXT; -- Tmp text 1
    tmp_text2 TEXT; -- Tmp text 2
BEGIN

    ------ Store the game record
    SELECT games.*,
        score_cumul_with_penalty_left - score_cumul_with_penalty_right AS score_diff,
        ---- Game presentation
        CASE
            WHEN is_friendly THEN 'friendly '
            WHEN is_relegation THEN 'relegation '
            WHEN is_cup THEN 'cup '
            WHEN is_league THEN ''
            ELSE 'ERROR '
        END || string_parser(inp_entity_type := 'idGame', inp_id := games.id) || ' of ' || string_parser(inp_entity_type := 'idLeague', inp_id := games.id_league) AS game_presentation,
        ---- Score of the game
        score_left::TEXT || CASE WHEN is_left_forfeit = TRUE THEN 'F' ELSE '' END ||
        CASE WHEN score_penalty_left IS NOT NULL THEN '[' || score_penalty_left || ']' ELSE '' END ||
        '-' ||
        CASE WHEN score_penalty_right IS NOT NULL THEN '[' || score_penalty_right || ']' ELSE '' END ||
        score_right::TEXT || CASE WHEN is_right_forfeit = TRUE THEN 'F' ELSE '' END
        AS text_score_game,
        ---- Overall text (if the game is a return game, display the overall winner etc...)
        CASE
            WHEN is_return_game_id_game_first_round IS NULL THEN
                ''
            ELSE 'Overall '
        END AS overall_text,
        ---- Id of the club who won the overall game
        CASE
            WHEN score_cumul_with_penalty_left > score_cumul_with_penalty_right THEN games.id_club_left
            ELSE games.id_club_right
        END AS id_club_overall_winner,
        ---- Id of the club who lost the overall game
        CASE
            WHEN score_cumul_with_penalty_left > score_cumul_with_penalty_right THEN games.id_club_right
            ELSE games.id_club_left
        END AS id_club_overall_loser,
        leagues.level AS league_level,
        leagues.number AS league_number,
        leagues.id_lower_league AS id_lower_league,
        games_description.description AS game_description,
        ROUND(games_description.elo_weight -- Base weight from the type of the game
            * CASE 
                WHEN ABS(score_left-score_right) = 1 THEN 1.0
                WHEN ABS(score_left-score_right) = 2 THEN 1.5
                ELSE (11 + ABS(score_left-score_right)) / 8.0
            END -- Weight multiplier based on the difference of goals
            * (CASE WHEN score_left > score_right THEN 1.0 WHEN score_left < score_right THEN 0.0 ELSE 0.5 END -- Result of the game
            - games.expected_elo_result[array_length(games.expected_elo_result, 1)])) -- Expected result of the game
            AS exchanged_elo_points
    INTO rec_game
    FROM games
    JOIN leagues ON leagues.id = games.id_league
    JOIN games_description ON games_description.id = games.id_games_description
    WHERE games.id = inp_id_game;

-- RAISE NOTICE 'expected_elo_score= % || exchanged_ranking_points= %', rec_game.expected_elo_score, rec_game.exchanged_ranking_points;

    ------ Start writing the messages to be sent to the clubs
    tmp_text1 := rec_game.text_score_game || ' in ' ||  rec_game.game_presentation || ' against ';
    text_title_winner := rec_game.overall_text || CASE
            WHEN rec_game.score_cumul_with_penalty_left = rec_game.score_cumul_with_penalty_right THEN ' Draw '
            ELSE 'Victory ' END || tmp_text1 || string_parser(inp_entity_type := 'idClub', inp_id := rec_game.id_club_overall_loser);
    text_title_loser := rec_game.overall_text || CASE
            WHEN rec_game.score_cumul_with_penalty_left = rec_game.score_cumul_with_penalty_right THEN ' Draw '
            ELSE 'Defeat ' END || tmp_text1 || string_parser(inp_entity_type := 'idClub', inp_id := rec_game.id_club_overall_winner);
    text_message_winner := text_title_winner || ' for the game: ' || rec_game.game_description;
    text_message_loser := text_title_loser || ' for the game: ' || rec_game.game_description;

    ------ Update message and league position for specific games
    ---- Handling of the international cup games (1st place game)
    IF rec_game.id_games_description = 131 THEN

        -- Send messages
        text_title_winner := text_title_winner || ': International Cup Victory';
        text_title_loser := text_title_loser || ': 2nd Place in International Cup';
        text_message_winner := text_message_winner || '. This great victory in the International Cup means that we are the champions of the competition. Congratulations to you and all the players, we made it !';
        text_message_loser := text_message_loser || '. This defeat in the International Cup means that we are the 2nd of the competition. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        ---- Insert into clubs_history table
        INSERT INTO clubs_history (id_club, is_ranking_description, description)
        VALUES (
            rec_game.id_club_overall_winner, TRUE,
            'Season ' || rec_game.season_number || ': Finished 1st of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league)),
        (
            rec_game.id_club_overall_loser, TRUE,
            'Season ' || rec_game.season_number || 'Finished 2nd of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league));

        ---- Insert into the players_history table for winning club
        INSERT INTO players_history (id_player, id_club, description, is_ranking_description)
            SELECT
                id AS id_player, id_club AS id_club,
                'Season ' || rec_game.season_number || ': Victory in International League'
                || ' of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' with ' || string_parser(inp_entity_type := 'idClub', inp_id := id_club),
                TRUE AS is_ranking_description
            FROM players
            WHERE id_club = rec_game.id_club_overall_winner;

        ---- Insert into the players_history table for losing club
        INSERT INTO players_history (id_player, id_club, description, is_ranking_description)
            SELECT
                id AS id_player, id_club AS id_club,
                'Season ' || rec_game.season_number || ': 2nd Place in International League'
                || ' of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' with ' || string_parser(inp_entity_type := 'idClub', inp_id := id_club),
                TRUE AS is_ranking_description
            FROM players
            WHERE players.id_club = rec_game.id_club_overall_loser;

    ------ Handling of the 3rd place game of the international cups
    ELSEIF rec_game.id_games_description IN (132, 133) THEN
        tmp_text1 :=
        CASE
            WHEN rec_game.id_games_description = 132 THEN '3rd Place game of the '
            ELSE '5th Place game of the '
        END ||
        CASE
            WHEN rec_game.league_number = 1 THEN ' Champions International Cup'
            WHEN rec_game.league_number = 2 THEN ' Seconds International Cup'
            ELSE ' Thirds International Cup'
        END;

        -- Send messages
        text_title_winner := text_title_winner || ': Victory in ' || tmp_text1;
        text_title_loser := text_title_loser || ': Defeat in ' || tmp_text1;
        text_message_winner := text_message_winner || '. This is a great victory in the ' || tmp_text1 || ' ! Next season let''s try to make it to the very top !';
        text_message_loser := text_message_loser || '. Sad defeat in the ' || tmp_text1 || ' ... It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        ---- Insert into clubs_history table
        INSERT INTO clubs_history (id_club, is_ranking_description, description)
        VALUES (rec_game.id_club_overall_winner, TRUE,
            'Season ' || rec_game.season_number || ': Finished 3rd of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league)),
        (
            rec_game.id_club_overall_loser, TRUE,
            'Season ' || rec_game.season_number || 'Finished 4th of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league));

        ---- Insert into the players_history table for winning club
        INSERT INTO players_history (id_player, id_club, is_ranking_description, description)
            SELECT
                id AS id_player, id_club AS id_club, TRUE AS is_ranking_description,
                'Season ' || rec_game.season_number || ': Victory in ' || tmp_text1
                || ' of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' with ' || string_parser(inp_entity_type := 'idClub', inp_id := id_club)
            FROM players
            WHERE id_club = rec_game.id_club_overall_winner;

        ---- Insert into the players_history table for losing club
        INSERT INTO players_history (id_player, id_club, is_ranking_description, description)
            SELECT
                id AS id_player, id_club AS id_club, TRUE AS is_ranking_description,
                'Season ' || rec_game.season_number || ': Defeat in ' || tmp_text1
                || ' of ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' with ' || string_parser(inp_entity_type := 'idClub', inp_id := id_club)
            FROM players
            WHERE id_club = rec_game.id_club_overall_loser;

    -- First leg games of barrage 1 games
    ELSEIF rec_game.id_games_description = 211 THEN
        -- Draw
        IF rec_game.score_diff = 0 THEN
            text_title_winner := text_title_winner || ': Leg 1 Draw';
            text_title_loser := text_title_loser || ': Leg 1 Draw';
            text_message_winner := text_message_winner || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_loser := text_message_loser || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
        ELSE
            text_title_winner := text_title_winner || ': Leg 1 Victory';
            text_title_loser := text_title_loser || ': Leg 1 Defeat';
            text_message_winner := text_message_winner || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
            text_message_loser := text_message_loser || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
        END IF; --End right club won

    -- Return game of the first barrage (between firsts of opposite leagues)
    ELSIF rec_game.id_games_description = 212 THEN

        -- Send messages
        text_title_winner := text_title_winner || ': promotion to ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league);
        text_title_loser := text_title_loser || ': no direct promotion to ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league);
        text_message_winner := text_message_winner || '. This overall victory means that we will be playing in the upper league ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' next season. Congratulations to you and all the players, it''s time to party !';
        text_message_loser := text_message_loser || '. This overall defeat means that we will have to play another barrage against the 5th of the upper league ' || string_parser(inp_entity_type := 'idLeague', inp_id := rec_game.id_league) || ' in order to take his place. We can do it, let''s go !';

        -- Winner of the barrage 1 is promoted to the upper league
        UPDATE clubs SET
            pos_league_next_season = 6,
            id_league_next_season = rec_game.id_league
        WHERE id = rec_game.id_club_overall_winner;

        -- 6th of the upper league is automatically droped down to the league of the winner of barrage 1
        UPDATE clubs SET
            pos_league_next_season = 1,
            id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner)
        WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);

        -- Send message to the club going down
        INSERT INTO mails (id_club_to, sender_role, is_season_info, title, message) 
        VALUES
            ((SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), 'Coach', TRUE,
            rec_game.game_presentation || ' of barrage 1 played ==> DEMOTED to ' ||
                string_parser(inp_entity_type := 'idLeague', inp_id := (SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner)),
            string_parser(inp_entity_type := 'idClub', inp_id := rec_game.id_club_overall_winner) || ' won the barrage 1 ' || rec_game.game_presentation || ' against ' || string_parser(inp_entity_type := 'idClub', inp_id := rec_game.id_club_overall_loser) ||
            '. Next season we will play in ' || string_parser(inp_entity_type := 'idLeague', inp_id := (SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner)));


    -- First leg games of barrage 1 games
    ELSIF rec_game.id_games_description = 213 THEN
        -- Draw
        IF rec_game.score_diff = 0 THEN
            text_title_winner := text_title_winner || ': Leg 1 Draw';
            text_title_loser := text_title_loser || ': Leg 1 Draw';
            text_message_winner := text_message_winner || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_loser := text_message_loser || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
        ELSE
            text_title_winner := text_title_winner || ': Leg 1 Victory';
            text_title_loser := text_title_loser || ': Leg 1 Defeat';
            text_message_winner := text_message_winner || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
            text_message_loser := text_message_loser || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
        END IF; --End right club won

    -- 4th and final game of the barrage 2 (week 14) between 5th of the upper league and loser of the barrage 1
    ELSEIF rec_game.id_games_description = 214 THEN
        
        -- Left club (5th of upper league) won so both clubs stay in their league
        IF rec_game.score_diff > 0 THEN
            -- 5th of upper league won, both clubs stay at their place and league
-- RAISE NOTICE '*** 2A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_left2;
-- RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_right2;

            -- Send messages
            text_title_winner := text_title_winner || ': BARRAGE2 Victory => We avoided relegation';
            text_title_loser := text_title_loser || ': BARRAGE2 Defeat => We failed to get promoted';
            text_message_winner := text_message_winner || '. This overall victory in the 2nd barrage means that we avoided relegation in a lower league. Congratulations to you and all the players, what a relief !';
            text_message_loser := text_message_loser || '. This overall defeat in the 2nd barrage means that we failed to get promoted to the upper league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        -- Right club (loser of barrage 1) won so he is promoted to the league of the 5th of the upper league
        ELSE

-- RAISE NOTICE '*** 2B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_right2;
-- RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_left2;
            -- 5th of upper league lost, 5th of upper league will be demoted to the league of the winner of the game (loser of barrage 1)
            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
            WHERE id = rec_game.id_club_left;

            -- Loser of barrage 1 won, he will be promoted to the league of the 5th of the upper league
            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
            WHERE id = rec_game.id_club_right;

            -- Send messages
            text_title_winner := text_title_winner || ': BARRAGE2 Defeat => We are demoted...';
            text_title_loser := text_title_loser || ': BARRAGE2 Victory => We are promoted !';
            text_message_winner := text_message_winner || '. This overall defeat in the 2nd barrage means that we are relegated to a lower league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_loser := text_message_loser || '. This overall victory in the 2nd barrage means that we are promoted to the upper league next season. Congratulations to you and all the players, we made it !';

        END IF;

    ELSEIF rec_game.id_games_description IN (311, 312) THEN
    -- IF rec_game.id_games_description IN (311, 312, 331) THEN
        text_title_winner := text_title_winner || ': BARRAGE2 Game1 Victory';
        text_title_loser := text_title_loser || ': BARRAGE2 Defeat';
        text_message_winner := text_message_winner || '. Great victory in the first game of the barrage2, we are so close to promotion, keep the team focused !';
        text_message_loser := text_message_loser || '. Unfortunately we have lost the first game of the barrage. We won''t go up this season but we can make it next season ! We will play some friendly games for the rest of the interseason, use this time to prepare for the next season and try out new tactics and players !';

    -- Return game of the barrage 3 (week 14) between the 4th of the upper league and the winner of the 2nd round of the barrage 3
    ELSEIF rec_game.id_games_description = 332 THEN
        -- Left club (4th of upper league) won, both clubs stay in their league
        IF rec_game.score_diff > 0 THEN

-- RAISE NOTICE '*** 3A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_left2;
-- RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_right2;

            -- Send messages
            text_title_winner := text_title_winner || ': BARRAGE3 Victory => We avoided relegation';
            text_title_loser := text_title_loser || ': BARRAGE3 Defeat => We failed to get promoted';
            text_message_winner := text_message_winner || '. This overall victory in the 3rd barrage means that we avoided relegation in a lower league. Congratulations to you and all the players, what a relief !';
            text_message_loser := text_message_loser || '. This overall defeat in the 3rd barrage means that we failed to get promoted to the upper league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        -- Right club (winner of the 2nd round of the barrage 2) won
        ELSE

-- RAISE NOTICE '*** 3B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_right2;
-- RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_left2;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
            WHERE id = rec_game.id_club_right;

            -- Send messages
            text_title_winner := text_title_winner || ': BARRAGE3 Defeat => We are demoted...';
            text_title_loser := text_title_loser || ': BARRAGE3 Victory => We are promoted !';
            text_message_winner := text_message_winner || '. This overall defeat in the 3rd barrage means that we are relegated to a lower league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_loser := text_message_loser || '. This overall victory in the 3rd barrage means that we are promoted to the upper league next season. Congratulations to you and all the players, we made it !';

        END IF; -- End right club won
    END IF; -- End of the handling of the different games

    ------ Send messages
    INSERT INTO mails (id_club_to, sender_role, is_game_result, title, message)
    VALUES
        (rec_game.id_club_overall_winner, 'Coach', TRUE, text_title_winner, text_message_winner),
        (rec_game.id_club_overall_loser, 'Coach', TRUE, text_title_loser, text_message_loser);


    ------ Set the game as played
    UPDATE games SET
        is_playing = FALSE,
        elo_exchanged_points = rec_game.exchanged_elo_points
    WHERE id = rec_game.id;

    ------ Update player to say they are not playing anymore
    UPDATE players SET
        id_game_currently_playing = NULL
    WHERE id_club IN (rec_game.id_club_left, rec_game.id_club_right);

    ------ Insert a new row in the table game_player_stats_best
    WITH ranked_stats AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY id_player ORDER BY sum_weights DESC) AS rn
        FROM game_player_stats_all
        WHERE id_game = inp_id_game
    )
    INSERT INTO game_player_stats_best (id_game, id_player, is_left_club_player, weights, position, sum_weights, stars)
    SELECT id_game, id_player, is_left_club_player ,weights, position, sum_weights, CEIL(sum_weights / 20)
    FROM ranked_stats
    WHERE rn = 1;

    ------ Delete the old rows in the table game_player_stats_all (stoareg problem)
    DELETE FROM game_player_stats_all WHERE id_game = inp_id_game;

    ------ Update left club
    UPDATE clubs SET
        lis_last_results = lis_last_results || 
            CASE 
                WHEN rec_game.score_diff > 0 THEN 3
                WHEN rec_game.score_diff < 0 THEN 0
                ELSE 1
            END,
        number_fans = CASE
            WHEN rec_game.score_diff > 0 THEN number_fans + 1
            WHEN rec_game.score_diff < 0 THEN number_fans - 1
            ELSE number_fans END,
        elo_points = elo_points + rec_game.exchanged_elo_points
    WHERE id = rec_game.id_club_left;

    ------ Update right club
    UPDATE clubs SET
        lis_last_results = lis_last_results || 
            CASE 
                WHEN rec_game.score_diff > 0 THEN 0
                WHEN rec_game.score_diff < 0 THEN 3
                ELSE 1
            END,
        number_fans = CASE
            WHEN rec_game.score_diff > 0 THEN number_fans - 1
            WHEN rec_game.score_diff < 0 THEN number_fans + 1
            ELSE number_fans END,
        elo_points = elo_points - rec_game.exchanged_elo_points
    WHERE id = rec_game.id_club_right;

    ------ Update the league points for games before week 10
    IF rec_game.week_number <= 10 THEN
        UPDATE clubs SET
            league_points = league_points + 
                CASE 
                    WHEN rec_game.score_diff > 0 THEN 3
                    WHEN rec_game.score_diff < 0 THEN 0
                    ELSE 1
                END,
            league_goals_for = league_goals_for + CASE WHEN rec_game.score_left = -1 THEN 0 ELSE rec_game.score_left END,
            league_goals_against = league_goals_against + CASE WHEN rec_game.score_right = -1 THEN 0 ELSE rec_game.score_right END
        WHERE id = rec_game.id_club_left;

        UPDATE clubs SET
            league_points = league_points + 
                CASE 
                    WHEN rec_game.score_diff > 0 THEN 0
                    WHEN rec_game.score_diff < 0 THEN 3
                    ELSE 1
                END,
            league_goals_for = league_goals_for + CASE WHEN rec_game.score_right = -1 THEN 0 ELSE rec_game.score_right END,
            league_goals_against = league_goals_against + CASE WHEN rec_game.score_left = -1 THEN 0 ELSE rec_game.score_left END
        WHERE id = rec_game.id_club_right;
    END IF;

END;
$$;