CREATE OR REPLACE FUNCTION public.simulate_game_set_is_played(
    inp_id_game bigint
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    rec_game RECORD; -- Record to store the game data
    text_title_left TEXT; -- Title of the message for the left club
    text_title_right TEXT; -- Title of the message for the right club
    text_message_left TEXT; -- Message of the message for the left club
    text_message_right TEXT; -- Message of the message for the right club
    text_title_winner TEXT; -- Title of the message for the left club
    text_title_loser TEXT; -- Title of the message for the right club
    text_message_winner TEXT; -- Message of the message for the left club
    text_message_loser TEXT; -- Message of the message for the right club
    tmp_text1 TEXT; -- Tmp text 1
    tmp_text2 TEXT; -- Tmp text 2
BEGIN

    ------ Store the game record
    SELECT games.*,
        ---- Handle forfeited games (WHEN score = -1)
        (CASE WHEN score_left = -1 THEN 0 ELSE score_left END) - (CASE WHEN score_right = -1 THEN 0 ELSE score_right END) AS score_diff,
        score_cumul_with_penalty_left - score_cumul_with_penalty_right AS score_diff_total,
        ---- Game presentation
        CASE
            WHEN is_friendly THEN 'friendly '
            WHEN is_barrage THEN 'barrage '
            WHEN is_cup THEN 'cup '
            WHEN is_league THEN ''
            ELSE 'ERROR '
        END || string_parser(games.id, 'game') || ' of ' || string_parser(games.id_league, 'league') AS game_presentation,
        ---- Score of the game
        CASE WHEN score_left = -1 THEN '0F' ELSE score_left::TEXT END ||
        CASE WHEN score_penalty_left IS NOT NULL THEN ' [' || score_penalty_left || '] ' ELSE '' END ||
        '-' ||
        CASE WHEN score_penalty_right IS NOT NULL THEN ' [' || score_penalty_right || '] ' ELSE '' END ||
        CASE WHEN score_right = -1 THEN '0F' ELSE score_right::TEXT END
        AS text_score_game,
        ----Issue of the game for left club
        CASE
            WHEN score_left > score_right THEN 'Victory'
            WHEN score_left < score_right THEN 'Defeat'
            ELSE 'Draw' END AS result_game_left,
        ----Issue of the game for right club
        CASE
            WHEN score_left > score_right THEN 'Defeat'
            WHEN score_left < score_right THEN 'Victory'
            ELSE 'Draw' END AS result_game_right,
        ---- Overall result of the game
        CASE
            WHEN score_cumul_with_penalty_left > score_cumul_with_penalty_right THEN 'Victory'
            WHEN score_cumul_with_penalty_left < score_cumul_with_penalty_right THEN 'Defeat'
            ELSE 'Draw' END AS result_overall_left,
        CASE
            WHEN score_cumul_with_penalty_left > score_cumul_with_penalty_right THEN 'Defeat'
            WHEN score_cumul_with_penalty_left < score_cumul_with_penalty_right THEN 'Victory'
            ELSE 'Draw' END AS result_overall_right,
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
        club_left.id_league AS id_league_club_left2, club_right.id_league AS id_league_club_right2,
        leagues.level AS league_level,
        leagues.number AS league_number,
        leagues.id_lower_league AS id_lower_league
    INTO rec_game
    FROM games
    JOIN clubs AS club_left ON club_left.id = games.id_club_left
    JOIN clubs AS club_right ON club_right.id = games.id_club_right
    JOIN leagues ON leagues.id = games.id_league
    WHERE games.id = inp_id_game;

    ------ Start writing the messages to be sent to the clubs
    tmp_text1 := ' ' || rec_game.text_score_game || ' in ' ||  rec_game.game_presentation || ' against ';
    text_title_left := rec_game.overall_text || rec_game.result_overall_left || tmp_text1 || string_parser(rec_game.id_club_right, 'club');
    text_title_right := rec_game.overall_text || rec_game.result_overall_right || tmp_text1 || string_parser(rec_game.id_club_left, 'club');
    text_message_left := text_title_left;
    text_message_right := text_title_right;

    tmp_text1 := rec_game.text_score_game || ' in ' ||  rec_game.game_presentation || ' against ';
    text_title_winner := rec_game.overall_text || ' victory ' || tmp_text1 || string_parser(rec_game.id_club_loser, 'club');
    text_title_loser := rec_game.overall_text || ' defeat ' || tmp_text1 || string_parser(rec_game.id_club_loser, 'club');
    text_message_winner := text_title_winner;
    text_message_loser := text_title_loser;

    ------ Update message and league position for specific games
    ---- Handling of the international cup games (1st place game)
    IF rec_game.id_games_description = 131 THEN
        -- Left club won
        IF rec_game.score_diff > 0 THEN

            -- Send messages
            text_title_left := text_title_left || ': International Cup Victory';
            text_title_right := text_title_right || ': 2nd Place in International Cup';
            text_message_left := text_message_left || '. This great victory in the International Cup means that we are the champions of the competition. Congratulations to you and all the players, we made it !';
            text_message_right := text_message_right || '. This defeat in the International Cup means that we are the 2nd of the competition. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        ELSE

            ---- Message construction
            text_title_left := text_title_left || ': 2nd Place in International Cup';
            text_title_right := text_title_right || ': International Cup Victory';
            text_message_left := text_message_left || '. This defeat in the International Cup means that we are the 2nd of the competition. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_right := text_message_right || '. This great victory in the International Cup means that we are the champions of the competition. Congratulations to you and all the players, we made it !';

        END IF; -- End of the handling of the different games

        ---- Insert into clubs_history table
        INSERT INTO clubs_history (id_club, is_ranking_description, description)
        VALUES (
            rec_game.id_club_overall_winner, TRUE,
            'Season ' || rec_game.season_number || ': Finished 1st of ' || string_parser(rec_game.id_league, 'league')),
        (
            rec_game.id_club_overall_loser, TRUE,
            'Season ' || rec_game.season_number || 'Finished 2nd of ' || string_parser(rec_game.id_league, 'league'));

        ---- Insert into the players_history table for winning club
        INSERT INTO players_history (id_player, id_club, description, is_ranking_description)
            SELECT
                id AS id_player, id_club AS id_club,
                'Season ' || rec_game.season_number || ': Victory in International League'
                || ' of ' || string_parser(rec_game.id_league, 'league') || ' with ' || string_parser(id_club, 'club'),
                TRUE AS is_ranking_description
            FROM players
            WHERE id_club = rec_game.id_club_overall_winner;

        ---- Insert into the players_history table for losing club
        INSERT INTO players_history (id_player, id_club, description, is_ranking_description)
            SELECT
                id AS id_player, id_club AS id_club,
                'Season ' || rec_game.season_number || ': 2nd Place in International League'
                || ' of ' || string_parser(rec_game.id_league, 'league') || ' with ' || string_parser(id_club, 'club'),
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
        
        -- Left club won
        IF rec_game.score_diff > 0 THEN

            -- Send messages
            text_title_left := text_title_left || ': Victory in ' || tmp_text1;
            text_title_right := text_title_right || ': Defeat in ' || tmp_text1;
            text_message_left := text_message_left || '. This is a great victory in the ' || tmp_text1 || ' ! Next season let''s try to make it to the very top !';
            text_message_right := text_message_right || '. Sad defeat in the ' || tmp_text1 || ' ... It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        ELSE

            ---- Message construction
            text_title_left := text_title_left || ': Defeat in ' || tmp_text1;
            text_title_right := text_title_right || ': Victory in ' || tmp_text1;
            text_message_left := text_message_left || '. Sad defeat in the ' || tmp_text1 || ' ... It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_right := text_message_right || '. This is a great victory in the ' || tmp_text1 || ' ! Next season let''s try to make it to the very top !';

        END IF; -- End of the handling of the different games

        ---- Insert into clubs_history table
        INSERT INTO clubs_history (id_club, is_ranking_description, description)
        VALUES (rec_game.id_club_overall_winner, TRUE,
            'Season ' || rec_game.season_number || ': Finished 3rd of ' || string_parser(rec_game.id_league, 'league')),
        (
            rec_game.id_club_overall_loser, TRUE,
            'Season ' || rec_game.season_number || 'Finished 4th of ' || string_parser(rec_game.id_league, 'league'));

        ---- Insert into the players_history table for winning club
        INSERT INTO players_history (id_player, id_club, is_ranking_description, description)
            SELECT
                id AS id_player, id_club AS id_club, TRUE AS is_ranking_description,
                'Season ' || rec_game.season_number || ': Victory in ' || tmp_text1
                || ' of ' || string_parser(rec_game.id_league, 'league') || ' with ' || string_parser(id_club, 'club')
            FROM players
            WHERE id_club = rec_game.id_club_overall_winner;

        ---- Insert into the players_history table for losing club
        INSERT INTO players_history (id_player, id_club, is_ranking_description, description)
            SELECT
                id AS id_player, id_club AS id_club, TRUE AS is_ranking_description,
                'Season ' || rec_game.season_number || ': Defeat in ' || tmp_text1
                || ' of ' || string_parser(rec_game.id_league, 'league') || ' with ' || string_parser(id_club, 'club')
            FROM players
            WHERE id_club = rec_game.id_club_overall_loser;

    -- First leg games of barrage 1 games
    ELSEIF rec_game.id_games_description = 211 THEN
        IF rec_game.score_diff_total > 0 THEN
        -- Left club won
            text_title_left := text_title_left || ': Leg 1 Victory';
            text_title_right := text_title_right || ': Leg 1 Defeat';
            text_message_left := text_message_left || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
            text_message_right := text_message_right || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
        -- Right club won
        ELSIF rec_game.score_diff_total < 0 THEN
            text_title_left := text_title_left || ': Leg 1 Defeat';
            text_title_right := text_title_right || ': Leg 1 Victory';
            text_message_left := text_message_left || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_right := text_message_right || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
        ELSE
            text_title_left := text_title_left || ': Leg 1 Draw';
            text_title_right := text_title_right || ': Leg 1 Draw';
            text_message_left := text_message_left || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_right := text_message_right || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
        END IF; --End right club won

    -- Return game of the first barrage (between firsts of opposite leagues)
    ELSIF rec_game.id_games_description = 212 THEN

        -- Left club won
        IF rec_game.score_diff_total > 0 THEN

-- RAISE NOTICE 'Club % (from league= %) who finished 6th will go down to league: %', (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.id_league, rec_game.id_league_club_left2;
            -- Send messages
            text_title_left := text_title_left || ': promotion to ' || string_parser(rec_game.id_league, 'league');
            text_title_right := text_title_right || ': no direct promotion to ' || string_parser(rec_game.id_league, 'league');
            text_message_left := text_message_left || '. This overall victory means that we will be playing in the upper league ' || string_parser(rec_game.id_league, 'league') || ' next season. Congratulations to you and all the players, it''s time to party !';
            text_message_right := text_message_right || '. This overall defeat means that we will have to play another barrage against the 5th of the upper league ' || string_parser(rec_game.id_league, 'league') || ' in order to take his place. We can do it, let''s go !';

        -- Right club won
        ELSE

-- RAISE NOTICE 'Club % (from league= %) who finished 6th will go down to league: %', (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.id_league, rec_game.id_league_club_right2;
            -- Send messages
            text_title_right := text_title_right || ': BARRAGE1 Victory => PROMOTION to upper league';
            text_title_left := text_title_left || ': BARRAGE1 Defeat => BARRAGE 2 to get promotion';
            text_message_right := text_message_right || '. This overall victory in the BARRAGE 1 means that we will be playing in the upper league next season. Congratulations to you and all the players, it''s time to party !';
            text_message_left := text_message_left || '. This overall defeat in the BARRAGE 1 means that we will have to play the BARRAGE 2 to get promoted to the upper league next season. We can do it, let''s go !';

        END IF; --End right club won

        -- Right club won barrage 1, he is promoted to the upper league
        -- Winner of the barrage 1 is promoted to the upper league
        UPDATE clubs SET
            pos_league_next_season = 6,
            id_league_next_season = rec_game.id_league
        WHERE id = rec_game.id_club_overall_winner;

        -- 6th of the upper league is automatically droped down to the league of the winner of barrage 1
        UPDATE clubs SET
            pos_league_next_season = 3,
            id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner)
        WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);

        -- Send message to the club going down
        INSERT INTO messages_mail (id_club_to, sender_role, title, message) 
        VALUES
            ((SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), 'Coach',
            rec_game.game_presentation || ' of barrage 1 played ==> DEMOTED to ' ||
                string_parser((SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner),'league'),
            string_parser(rec_game.id_club_overall_winner,'club') || ' won the barrage 1 ' || rec_game.game_presentation || ' against ' || string_parser(rec_game.id_club_overall_loser, 'club') ||
            '. Next season we will play in ' || string_parser((SELECT id_league FROM clubs WHERE id = rec_game.id_club_overall_winner),'league'));


    -- First leg games of barrage 1 games
    ELSIF rec_game.id_games_description = 213 THEN
        -- Draw
        IF rec_game.score_diff_total > 0 THEN
        -- Left club won
            text_title_left := text_title_left || ': Leg 1 Victory';
            text_title_right := text_title_right || ': Leg 1 Defeat';
            text_message_left := text_message_left || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
            text_message_right := text_message_right || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
        -- Right club won
        ELSIF rec_game.score_diff_total < 0 THEN
            text_title_left := text_title_left || ': Leg 1 Defeat';
            text_title_right := text_title_right || ': Leg 1 Victory';
            text_message_left := text_message_left || '. Unfortunately we have lost the first leg of the barrage. Nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_right := text_message_right || '. Great victory in the first leg of the barrage, we are so close to promotion, keep the team focused !';
        ELSE
            text_title_left := text_title_left || ': Leg 1 Draw';
            text_title_right := text_title_right || ': Leg 1 Draw';
            text_message_left := text_message_left || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
            text_message_right := text_message_right || '. The first leg of the barrage ended in a draw, nothing is lost, we can still make it in the second leg, let''s go !';
        END IF; --End right club won

    -- Return game of the first barrage (between firsts of opposite leagues)

    -- 4th and final game of the barrage 2 (week 14) between 5th of the upper league and loser of the barrage 1
    ELSEIF rec_game.id_games_description = 214 THEN
        
        -- Left club (5th of upper league) won so both clubs stay in their league
        IF rec_game.score_diff > 0 THEN
            -- 5th of upper league won, both clubs stay at their place and league
-- RAISE NOTICE '*** 2A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_left2;
-- RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_right2;

            -- Send messages
            text_title_left := text_title_left || ': BARRAGE2 Victory => We avoided relegation';
            text_title_right := text_title_right || ': BARRAGE2 Defeat => We failed to get promoted';
            text_message_left := text_message_left || '. This overall victory in the 2nd barrage means that we avoided relegation in a lower league. Congratulations to you and all the players, what a relief !';
            text_message_right := text_message_right || '. This overall defeat in the 2nd barrage means that we failed to get promoted to the upper league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        -- Right club (loser of barrage 1) won so he is promoted to the league of the 5th of the upper league
        ELSE

-- RAISE NOTICE '*** 2B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_right2;
-- RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_left2;
            -- 5th of upper league lost, 5th of upper league will be demoted to the league of the winner of the game (loser of barrage 1)
            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                pos_league_next_season = 1,
                id_league_next_season = rec_game.id_league_club_right2
            WHERE id = rec_game.id_club_left;

            -- Loser of barrage 1 won, he will be promoted to the league of the 5th of the upper league
            UPDATE clubs SET
                pos_league_next_season = 5,
                id_league_next_season = rec_game.id_league_club_left2
            WHERE id = rec_game.id_club_right;

            -- Send messages
            text_title_left := text_title_left || ': BARRAGE2 Defeat => We are demoted...';
            text_title_right := text_title_right || ': BARRAGE2 Victory => We are promoted !';
            text_message_left := text_message_left || '. This overall defeat in the 2nd barrage means that we are relegated to a lower league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_right := text_message_right || '. This overall victory in the 2nd barrage means that we are promoted to the upper league next season. Congratulations to you and all the players, we made it !';

        END IF;

    ELSEIF rec_game.id_games_description IN (311, 312) THEN
    -- IF rec_game.id_games_description IN (311, 312, 331) THEN
        -- Left club won
        IF rec_game.score_diff_total > 0 THEN
            text_title_left := text_title_left || ': BARRAGE2 Game1 Victory';
            text_title_right := text_title_right || ': BARRAGE2 Defeat';
            text_message_left := text_message_left || '. Great victory in the first game of the barrage2, we are so close to promotion, keep the team focused !';
            text_message_right := text_message_right || '. Unfortunately we have lost the first game of the barrage. We won''t go up this season but we can make it next season ! Next week we''ll play a friendly game against the loser of the other BARRAGE2 game.';
        -- Right club won
        ELSE
            text_title_left := text_title_left || ': BARRAGE2 Defeat';
            text_title_right := text_title_right || ': BARRAGE2 Game1 Victory';
            text_message_left := text_message_left || '. Unfortunately we have lost the first game of the barrage. We won''t go up this season but we can make it next season ! Next week we''ll play a friendly game against the loser of the other BARRAGE2 game.';
            text_message_right := text_message_right || '. Great victory in the first game of the barrage2, we are so close to promotion, keep the team focused !';
        END IF;

    -- Return game of the barrage 3 (week 14) between the 4th of the upper league and the winner of the 2nd round of the barrage 3
    ELSEIF rec_game.id_games_description = 332 THEN
        -- Left club (4th of upper league) won, both clubs stay in their league
        IF rec_game.score_diff > 0 THEN

-- RAISE NOTICE '*** 3A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_left2;
-- RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_right2;

            -- Send messages
            text_title_left := text_title_left || ': BARRAGE3 Victory => We avoided relegation';
            text_title_right := text_title_right || ': BARRAGE3 Defeat => We failed to get promoted';
            text_message_left := text_message_left || '. This overall victory in the 3rd barrage means that we avoided relegation in a lower league. Congratulations to you and all the players, what a relief !';
            text_message_right := text_message_right || '. This overall defeat in the 3rd barrage means that we failed to get promoted to the upper league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';

        -- Right club (winner of the 2nd round of the barrage 2) won
        ELSE

-- RAISE NOTICE '*** 3B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.id_league_club_left2, rec_game.id, rec_game.id_league_club_right2;
-- RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.id_league_club_right2, rec_game.id, rec_game.id_league_club_left2;

            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                pos_league_next_season = 4,
                -- id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
                id_league_next_season = rec_game.id_league_club_right2
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                pos_league_next_season = 1,
                -- id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
                id_league_next_season = rec_game.id_league_club_left2
            WHERE id = rec_game.id_club_right;

            -- Send messages
            text_title_left := text_title_left || ': BARRAGE3 Defeat => We are demoted...';
            text_title_right := text_title_right || ': BARRAGE3 Victory => We are promoted !';
            text_message_left := text_message_left || '. This overall defeat in the 3rd barrage means that we are relegated to a lower league. It''s a disappointment but we''ll come back stronger next season, I''m sure we can make it !';
            text_message_right := text_message_right || '. This overall victory in the 3rd barrage means that we are promoted to the upper league next season. Congratulations to you and all the players, we made it !';

        END IF; -- End right club won
    END IF; -- End of the handling of the different games

    ------ Send messages
    INSERT INTO messages_mail (id_club_to, created_at, sender_role, title, message)
    VALUES
        (rec_game.id_club_left, rec_game.date_end, 'Coach', text_title_left, text_message_left),
        (rec_game.id_club_right, rec_game.date_end, 'Coach', text_title_right, text_message_right);

    ------ Set the game as played
    UPDATE games SET
        is_playing = FALSE
    WHERE id = rec_game.id;

    ------ Update player to say they are not playing anymore
    UPDATE players SET
        is_playing = FALSE
    WHERE id_club IN (rec_game.id_club_left, rec_game.id_club_right);

    ------ Update clubs results
    UPDATE clubs SET
        lis_last_results = lis_last_results || 
            CASE 
                WHEN rec_game.score_diff > 0 THEN CASE WHEN id = rec_game.id_club_left THEN 3 ELSE 0 END
                WHEN rec_game.score_diff < 0 THEN CASE WHEN id = rec_game.id_club_right THEN 3 ELSE 0 END
                ELSE 1
            END
    WHERE id IN (rec_game.id_club_left, rec_game.id_club_right);

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