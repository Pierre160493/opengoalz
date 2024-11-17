CREATE OR REPLACE FUNCTION public.simulate_game_update_results(
    inp_id_game bigint,
    loc_score_left int,
    loc_score_right int,
    loc_score_left_previous int,
    loc_score_right_previous int,
    loc_score_penalty_left int,
    loc_score_penalty_right int,
    loc_minute_period_end int,
    loc_minute_period_extra_time int,
    loc_array_players_id_left int8[],
    loc_array_players_id_right int8[]
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    rec_game RECORD;
    i int;
BEGIN
    -- Fetch game details
    SELECT * INTO rec_game FROM games WHERE id = inp_id_game;

    -- Store the score
    UPDATE games SET
        score_left = loc_score_left,
        score_right = loc_score_right
    WHERE id = inp_id_game;

    -- Store the score if ever a game is a return game of this one
    UPDATE games SET
        score_cumul_left = loc_score_right,
        score_cumul_right = loc_score_left
    WHERE is_return_game_id_game_first_round = inp_id_game;

    -- Update cumulated score for cup games
    IF rec_game.is_cup THEN
        UPDATE games SET
            score_cumul_left = (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)),
            score_cumul_right = (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0))
        WHERE id = inp_id_game;
    END IF;

    -- Update game result
    IF loc_score_left > loc_score_right THEN
        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
        WHERE id = rec_game.id_club_left;
        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
        WHERE id = rec_game.id_club_right;

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Victory for game in week ' || rec_game.week_number, 'Great news! We have won the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (rec_game.id_club_right, 'Defeat for game in week ' || rec_game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');
    ELSEIF loc_score_left < loc_score_right THEN
        UPDATE clubs SET
            lis_last_results = lis_last_results || 0
        WHERE id = rec_game.id_club_left;
        UPDATE clubs SET
            lis_last_results = lis_last_results || 3
        WHERE id = rec_game.id_club_right;

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Defeat for game in week ' || rec_game.week_number, 'Unfortunately we have lost the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (rec_game.id_club_right, 'Victory for game in week ' || rec_game.week_number, 'Great news! We have won the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');
    ELSE
        UPDATE clubs SET
            lis_last_results = lis_last_results || 1
        WHERE id IN (rec_game.id_club_left, rec_game.id_club_right);

        INSERT INTO messages_mail (id_club_to, title, message, sender_role) VALUES
            (rec_game.id_club_left, 'Draw for game in week ' || rec_game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_right) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach'),
            (rec_game.id_club_right, 'Draw for game in week ' || rec_game.week_number, 'We drew the game against ' || (SELECT name FROM clubs WHERE id = rec_game.id_club_left) || ' with ' || loc_score_left || ' - ' || loc_score_right, 'Coach');
    END IF;

    -- Update the league points
    IF rec_game.is_league AND rec_game.week_number <= 10 THEN
        IF loc_score_left > loc_score_right THEN
            UPDATE clubs SET
                league_points = league_points + 3.0 + ((loc_score_left - loc_score_right) / 1000)
            WHERE id = rec_game.id_club_left;
            UPDATE clubs SET
                league_points = league_points - ((loc_score_left - loc_score_right) / 1000)
            WHERE id = rec_game.id_club_right;
        ELSEIF loc_score_left < loc_score_right THEN
            UPDATE clubs SET
                league_points = league_points + ((loc_score_left - loc_score_right) / 1000)
            WHERE id = rec_game.id_club_left;
            UPDATE clubs SET
                league_points = league_points + 3.0 - ((loc_score_left - loc_score_right) / 1000)
            WHERE id = rec_game.id_club_right;
        ELSE
            UPDATE clubs SET
                league_points = league_points + 1.0
            WHERE id = rec_game.id_club_left;
            UPDATE clubs SET
                league_points = league_points + 1.0
            WHERE id = rec_game.id_club_right;
        END IF;
    END IF;

    -- Update players experience and stats
    PERFORM simulate_game_process_experience_gain(
        inp_id_game := inp_id_game,
        inp_list_players_id_left := loc_array_players_id_left,
        inp_list_players_id_right := loc_array_players_id_right
    );

    -- Update league position for specific games
    IF rec_game.id_games_description = 212 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
            UPDATE clubs SET
                pos_league_next_season = 6,
                id_league_next_season = rec_game.id_league
            WHERE id = rec_game.id_club_left;
            UPDATE clubs SET
                pos_league_next_season = 3,
                id_league_next_season = rec_game.id_league_club_left
            WHERE id = (SELECT id FROM clubs WHERE id_league = rec_game.id_league AND pos_league = 6);
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
    ELSEIF rec_game.id_games_description = 214 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
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
    ELSEIF rec_game.id_games_description = 332 THEN
        IF (loc_score_left_previous + loc_score_left + (loc_score_penalty_left / 1000.0)) > (loc_score_right_previous + loc_score_right + (loc_score_penalty_right / 1000.0)) THEN
            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
            WHERE id = rec_game.id_club_left;
            UPDATE clubs SET
                pos_league_next_season = pos_league,
                id_league_next_season = id_league
            WHERE id = rec_game.id_club_right;
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

    -- Set date_end for this game
    UPDATE games SET date_end =
        date_start + (loc_minute_period_end + loc_minute_period_extra_time) * INTERVAL '1 minute'
    WHERE id = inp_id_game;

    -- Set games_teamcomp is_played = TRUE
    UPDATE games_teamcomp SET is_played = TRUE WHERE id IN (rec_game.id_teamcomp_club_left, rec_game.id_teamcomp_club_right);

END;
$$;