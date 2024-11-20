CREATE OR REPLACE FUNCTION public.simulate_game_set_is_played(
    inp_id_game bigint
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    rec_game RECORD;
BEGIN

    ------ Store the game record
    SELECT games.*,
    score_cumul_left - score_cumul_right AS score_diff,
    club_left.id_league AS club_left_league,
    club_right.id_league AS club_right_league,
    club_left.name AS club_left_name,
    club_right.name AS club_right_name
    INTO rec_game
    FROM games
    JOIN clubs AS club_left ON club_left.id = games.id_club_left
    JOIN clubs AS club_right ON club_right.id = games.id_club_right
    WHERE games.id = inp_id_game;

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

    ------ Update the league points
    -- Only for league games before week 10
    IF rec_game.week_number <= 10 THEN
        UPDATE clubs SET
            league_points = league_points + 
                CASE 
                    WHEN rec_game.score_diff > 0 THEN 3
                    WHEN rec_game.score_diff < 0 THEN 0
                    ELSE 1
                END,
            league_goals_for = league_goals_for + rec_game.score_left,
            league_goals_against = league_goals_against + rec_game.score_right
        WHERE id = rec_game.id_club_left;

        UPDATE clubs SET
            league_points = league_points + 
                CASE 
                    WHEN rec_game.score_diff > 0 THEN 0
                    WHEN rec_game.score_diff < 0 THEN 3
                    ELSE 1
                END,
            league_goals_for = league_goals_for + rec_game.score_right,
            league_goals_against = league_goals_against + rec_game.score_left
        WHERE id = rec_game.id_club_right;
    END IF;

    ------ Update league position for specific games
    -- Return game of the first barrage (between firsts of opposite leagues)
    IF rec_game.id_games_description = 212 THEN

        -- Left club won
        IF rec_game.score_diff > 0 THEN
            
RAISE NOTICE '*** 1A: Left Club % (from league= %) won the game % (type= 212) and will be promoted to league: %', rec_game.id_club_left, rec_game.club_left_league, rec_game.id, rec_game.id_league;
RAISE NOTICE '*** 1A: Right Club % (from league= %) lost the game % (type= 212) and will play barrage game against 5th of upper league', rec_game.id_club_right, rec_game.club_right_league, rec_game.id;
            -- Left club won barrage 1, he is promoted to the upper league
            UPDATE clubs SET
                pos_league_next_season = 6,
                -- pos_league_next_season = 5,
                id_league_next_season = rec_game.id_league
            WHERE id = rec_game.id_club_left;

RAISE NOTICE 'Club % (from league= %) who finished 6th will go down to league: %', (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.id_league, rec_game.club_left_league;
            -- 6th of the upper league is automatically droped down to the league of the winner of barrage 1
            UPDATE clubs SET
                pos_league_next_season = 3,
                -- pos_league_next_season = 2,
                id_league_next_season = rec_game.club_left_league
            WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'We did it! Our Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' will make us play in the upper league next season. Congratulations', 'Coach'),
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'So sorry! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' will make us play the second barrage if we want to be promoted this season', 'Coach'),
                ((SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1 Played: Next season we will play in league ' || rec_game.id_league_club_left,
                'The Club ' || rec_game.club_left_name || ' won the barrage 1 ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || '. Next season we will play in league ' || rec_game.id_league_club_left, 'Coach');

        -- Right club won
        ELSE

RAISE NOTICE '*** 1B: Left Club % (from league= %) lost the game % (type= 212) and will play barrage game against 5th of upper league', rec_game.id_club_left, rec_game.club_left_league, rec_game.id;
RAISE NOTICE '*** 1B: Right Club % (from league= %) won the game % (type= 212) and will be promoted to league: %', rec_game.id_club_right, rec_game.club_right_league, rec_game.id, rec_game.id_league;
            -- Right club won barrage 1, he is promoted to the upper league
            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = rec_game.id_league
            WHERE id = rec_game.id_club_right;

RAISE NOTICE 'Club % (from league= %) who finished 6th will go down to league: %', (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.id_league, rec_game.club_right_league;

            -- 6th of the upper league is automatically droped down to the league of the winner of barrage 1
            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = rec_game.club_right_league
            WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'We did it! Our Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' will make us play in the upper league next season. Congratulations', 'Coach'),
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'So sorry! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' will make us play the second barrage if we want to be promoted this season', 'Coach'),
                ((SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6), rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1 Played: Next season we will play in league ' || rec_game.id_league_club_right,
                'The Club ' || rec_game.club_right_name || ' won the barrage 1 ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || '. Next season we will play in league ' || rec_game.id_league_club_right, 'Coach');

        END IF; --End right club won

    -- 4th and final game of the barrage 1 (week 14) between 5th of the upper league and loser of the barrage 1
    ELSEIF rec_game.id_games_description = 214 THEN
        
        -- Left club (5th of upper league) won so both clubs stay in their league
        IF rec_game.score_diff > 0 THEN
            -- 5th of upper league won, both clubs stay at their place and league
RAISE NOTICE '*** 2A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.club_left_league, rec_game.id, rec_game.club_left_league;
RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.club_right_league, rec_game.id, rec_game.club_right_league;

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'We made it ! Our Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' saved our season and we will stay in this league', 'Coach'),
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'What a disapointment ! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' ruined our possibilities of going up, we will stay in our current league next season, but dont give up, we can make it', 'Coach');

        -- Right club (loser of barrage 1) won so he is promoted to the league of the 5th of the upper league
        ELSE

RAISE NOTICE '*** 2B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.club_left_league, rec_game.id, rec_game.club_right_league;
RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.club_right_league, rec_game.id, rec_game.club_left_league;
            -- 5th of upper league lost, 5th of upper league will be demoted to the league of the winner of the game (loser of barrage 1)
            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                pos_league_next_season = 1,
                id_league_next_season = rec_game.club_right_league
            WHERE id = rec_game.id_club_left;

            -- Loser of barrage 1 won, he will be promoted to the league of the 5th of the upper league
            UPDATE clubs SET
                pos_league_next_season = 5,
                id_league_next_season = rec_game.club_left_league
            WHERE id = rec_game.id_club_right;

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'Sorry boss ! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' means that we will be demoted for the next season to the lower league ' || rec_game.club_right_league, 'Coach'),
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 1: Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'We did it ! Our victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' means that next season we will be playing in the upper league ' || rec_game.club_left_league, 'Coach');

        END IF;

    -- Return game of the barrage 2 (week 14) between the 4th of the upper league and the winner of the 2nd round of the barrage 2
    ELSEIF rec_game.id_games_description = 332 THEN
        -- Left club (4th of upper league) won, both clubs stay in their league
        IF rec_game.score_diff > 0 THEN

RAISE NOTICE '*** 3A: Left Club % (from league= %) won the game % (type= 214) and will stay in current league %', rec_game.id_club_left, rec_game.club_left_league, rec_game.id, rec_game.club_left_league;
RAISE NOTICE 'Right Club % (from league= %) lost the game % (type= 214) and will stay in current league %', rec_game.id_club_right, rec_game.club_right_league, rec_game.id, rec_game.club_right_league;

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 2: Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'We made it ! Our Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' saved our season and we will stay in this league', 'Coach'),
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 2: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'What a disapointment ! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' ruined our possibilities of going up, we will stay in our current league next season, but dont give up, we can make it', 'Coach');

        -- Right club (winner of the second round of the barrage 2) won
        ELSE

RAISE NOTICE '*** 3B: Left Club % (from league= %) lost the game % (type= 214) and will be demoted to league %', rec_game.id_club_left, rec_game.club_left_league, rec_game.id, rec_game.club_right_league;
RAISE NOTICE 'Right Club % (from league= %) won the game % (type= 214) and will be promoted to league %', rec_game.id_club_right, rec_game.club_right_league, rec_game.id, rec_game.club_left_league;

            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                pos_league_next_season = 4,
                -- id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
                id_league_next_season = rec_game.club_right_league
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                -- pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                pos_league_next_season = 1,
                -- id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
                id_league_next_season = rec_game.club_left_league
            WHERE id = rec_game.id_club_right;

            -- Send messages
            INSERT INTO messages_mail (id_club_to, created_at, title, message, sender_role) 
            VALUES
                (rec_game.id_club_left, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 2: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name,
                'What a disapointment ! The defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name || ' means that we are demoted to the league ' || rec_game.club_right_league, 'Coach'),
                (rec_game.id_club_right, rec_game.date_end, 
                'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Barrage 2: Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name,
                'We made it ! Our Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name || ' means that we are promoted to the upper league ' || rec_game.club_left_league, 'Coach');

        END IF;

    ------ Normal games
    ELSE
        INSERT INTO messages_mail (id_club_to, title, message, sender_role) 
        VALUES
            (rec_game.id_club_left, 
             CASE 
                WHEN rec_game.score_diff > 0 THEN 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name
                WHEN rec_game.score_diff < 0 THEN 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name
                ELSE 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Draw ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name
             END,
             CASE 
                WHEN rec_game.score_diff > 0 THEN 'Great news! We have won the game against ' || rec_game.club_right_name || ' with ' || rec_game.score_left || '-' || rec_game.score_right
                WHEN rec_game.score_diff < 0 THEN 'Unfortunately we have lost the game against ' || rec_game.club_right_name || ' with ' || rec_game.score_left || '-' || rec_game.score_right
                ELSE 'We drew the game against ' || rec_game.club_right_name || ' with ' || rec_game.score_left || '-' || rec_game.score_right
             END,
             'Coach'),
            (rec_game.id_club_right, 
             CASE 
                WHEN rec_game.score_diff > 0 THEN 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Defeat ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name
                WHEN rec_game.score_diff < 0 THEN 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Victory ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_left_name
                ELSE 'S' || rec_game.season_number || 'W' || rec_game.week_number || ' Draw ' || rec_game.score_left || '-' || rec_game.score_right || ' against ' || rec_game.club_right_name
             END,
             CASE 
                WHEN rec_game.score_diff > 0 THEN 'Unfortunately we have lost the game against ' || rec_game.club_left_name || '. The score was ' || rec_game.score_left || '-' || rec_game.score_right
                WHEN rec_game.score_diff < 0 THEN 'Great news! We have won the game against ' || rec_game.club_left_name || '. The score was ' || rec_game.score_left || '-' || rec_game.score_right
                ELSE 'We drew the game against ' || rec_game.club_left_name || ' with ' || rec_game.score_left || '-' || rec_game.score_right
             END,
             'Coach');
    END IF;

END;
$$;