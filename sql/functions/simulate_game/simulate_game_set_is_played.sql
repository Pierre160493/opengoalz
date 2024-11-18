CREATE OR REPLACE FUNCTION public.simulate_game_set_is_played(
    inp_id_game bigint
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    rec_game RECORD;
BEGIN

    ------ Store the game record
    SELECT * INTO rec_game FROM games WHERE id = inp_id_game;

    ------ Set the game as played
    UPDATE games SET
        is_playing = FALSE
    WHERE id = rec_game.id;

    ------ Update player to say they are not playing anymore
    UPDATE players SET
        is_playing = FALSE
    WHERE id_club IN (rec_game.id_club_left, rec_game.id_club_right);

    ------ Update clubs results
    -- Left club won
    IF rec_game.score_left > rec_game.score_right THEN

        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
        WHERE id = rec_game.id_club_left;

        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
        WHERE id = rec_game.id_club_right;

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Victory for game in week ' || rec_game.week_number, 'Great news! We have won the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach'),
            (rec_game.id_club_right, 'Defeat for game in week ' || rec_game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach');
    
    -- Right club won
    ELSEIF rec_game.score_left < rec_game.score_right THEN
        
        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
        WHERE id = rec_game.id_club_left;
        
        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
        WHERE id = rec_game.id_club_right;

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Defeat for game in week ' || rec_game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach'),
            (rec_game.id_club_right, 'Victory for game in week ' || rec_game.week_number, 'Great news! We have won the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach');
    
    -- Draw
    ELSE
        UPDATE clubs SET
            lis_last_results = lis_last_results || 1
        WHERE id IN (rec_game.id_club_left, rec_game.id_club_right);

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Draw for game in week ' || rec_game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach'),
            (rec_game.id_club_right, 'Draw for game in week ' || rec_game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || rec_game.score_left || ' - ' || rec_game.score_right, 'Coach');
    END IF;

    ------ Update the league points
    -- Only for league games before week 10
    IF rec_game.is_league AND rec_game.week_number <= 10 THEN

        -- Left club won
        IF rec_game.score_left > rec_game.score_right THEN
            
            UPDATE clubs SET
                league_points = league_points + 3.0 + ((rec_game.score_left - rec_game.score_right) / 1000)
            WHERE id = rec_game.id_club_left;
            
            UPDATE clubs SET
                league_points = league_points - ((rec_game.score_left - rec_game.score_right) / 1000)
            WHERE id = rec_game.id_club_right;
        
        -- Right club won
        ELSEIF rec_game.score_left < rec_game.score_right THEN
            
            UPDATE clubs SET
                league_points = league_points + ((rec_game.score_left - rec_game.score_right) / 1000)
            WHERE id = rec_game.id_club_left;
            
            UPDATE clubs SET
                league_points = league_points + 3.0 - ((rec_game.score_left - rec_game.score_right) / 1000)
            WHERE id = rec_game.id_club_right;
        
        -- Draw
        ELSE
            
            UPDATE clubs SET
                league_points = league_points + 1.0
            WHERE id = rec_game.id_club_left;
            
            UPDATE clubs SET
                league_points = league_points + 1.0
            WHERE id = rec_game.id_club_right;
        END IF;
    END IF;

    ------ Update league position for specific games
    -- Return game of the first barrage (between firsts of opposite leagues)
    IF rec_game.id_games_description = 212 THEN

        -- Left club won
        IF rec_game.score_cumul_left > rec_game.score_cumul_right THEN
            
            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = rec_game.id_league
            WHERE id = rec_game.id_club_left;
            
            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = rec_game.id_league_club_left
            WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);
        
        -- Right club won
        ELSE

            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = rec_game.id_league
            WHERE id = rec_game.id_club_right;

            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = rec_game.id_league_club_right
            WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);
        END IF;

    -- 4th and final game of the barrage 1 (week 14) between 5th of the upper league and loser of the barrage 1
    ELSEIF rec_game.id_games_description = 214 THEN
        
        IF rec_game.score_cumul_left > rec_game.score_cumul_right THEN
            -- 5th of upper league won, both clubs stay at their place and league
        ELSE

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
            WHERE id = rec_game.id_club_right;
        END IF;

    -- Return game of the barrage 2 (week 14) between the 4th of the upper league and the winner of the 2nd round of the barrage 2
    ELSEIF rec_game.id_games_description = 332 THEN
        -- Left club won
        IF rec_game.score_cumul_left > rec_game.score_cumul_right THEN

            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
            WHERE id = rec_game.id_club_right;

        -- Right club won
        ELSE

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_right),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_right)
            WHERE id = rec_game.id_club_left;

            UPDATE clubs SET
                pos_league_next_season = (SELECT pos_league FROM clubs WHERE id = rec_game.id_club_left),
                id_league_next_season = (SELECT id_league FROM clubs WHERE id = rec_game.id_club_left)
            WHERE id = rec_game.id_club_right;
        END IF;
    END IF;

END;
$$;