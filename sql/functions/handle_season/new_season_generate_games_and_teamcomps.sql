-- DROP FUNCTION public.new_season_generate_games_and_teamcomps(int8, int8, timestamptz);

CREATE OR REPLACE FUNCTION public.new_season_generate_games_and_teamcomps(inp_multiverse_speed bigint, inp_season_number bigint, inp_date_start timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for multiverse loop
    league RECORD; -- Record for league loop
    club RECORD; -- Record for club loop
    loc_interval_1_week INTERVAL; -- Date interval between games
    loc_id_game_1 bigint; -- Id of the game
    loc_id_game_2 bigint; -- Id of the game
    loc_id_game_1L bigint; -- Id of the game
    loc_id_game_2L bigint; -- Id of the game
    loc_id_game_1R bigint; -- Id of the game
    loc_id_game_2R bigint; -- Id of the game
BEGIN

    -- Loop through the multiverses
    FOR multiverse IN
        (SELECT * FROM multiverses WHERE speed = inp_multiverse_speed)
    LOOP

        -- Calculate the date interval for 1 week depending on the multiverse speed
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed; -- Date interval between games
    
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND level > 0
            ORDER BY level)
        LOOP

            -- Loop through the clubs of the league
            FOR club IN
                (SELECT * FROM clubs WHERE id_league = league.id ORDER BY pos_league)
            LOOP

                -- Loop through the 14 weeks of the season
                FOR J IN 1..14 LOOP

                    -- Insert the games_teamcomp for the club for the 10 weeks of the season
                    INSERT INTO games_teamcomp (id_club, week_number, season_number)
                    VALUES (club.id, J, league.season_number);

                END LOOP; -- End of the loop for the weeks of the season
            END LOOP; -- End of the club loop

            -- Schedule games of first 10 weeks
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
            -- Week 1 and 10
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 1, 2, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 4, 3, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 5, 6, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 2, 1, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 3, 4, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 6, 5, league.id, league.id),
            -- Week 2 and 9
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 3, 1, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 2, 5, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 6, 4, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 1, 3, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 5, 2, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 4, 6, league.id, league.id),
            -- Week 3 and 8
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 1, 5, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 3, 6, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 4, 2, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 5, 1, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 6, 3, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 2, 4, league.id, league.id),
            -- Week 4 and 7
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 6, 1, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 5, 4, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 2, 3, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 1, 6, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 4, 5, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 3, 2, league.id, league.id),
            -- Week 5 and 6
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 1, 4, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 6, 2, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 5, 3, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 4, 1, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 2, 6, league.id, league.id),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 3, 5, league.id, league.id);

        END LOOP; -- End of the league loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the international leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND level = 0)
        LOOP
            
            -- 3 intercontinental cups
            IF league.number < 4 THEN

                -- Schedule the international league games
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right) VALUES
            -- Week 11 (First of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 4),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 3),
            -- Week 12 (Second of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 6, 1),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 5, 2),
            -- Week 13 (Third of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 6),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 3, 5),
            -- Week 14 (Cup round)
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 1, 2),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 3, 4),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 5, 6);

                -- Schedule the 3 international friendly games
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right) VALUES
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 6),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 4),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 1, 2);

            -- 3 intercontinental friendly games
            ELSE
            
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right) VALUES
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 1),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 5),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 2),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 4),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 3),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 6);

            END IF;
        END LOOP; -- End of the international league loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND id < 0
            AND level > 1)
        LOOP

            -- {1, 2} are the champions of the lower leagues league.id and -league.id 
            -- {3, 4} are the 2nd of the lower leagues league.id and -league.id 
            -- {5, 6} are the 2nd of the lower leagues league.id and -league.id

            ---- 4th, 5th and 6th Friendly Games for Week11 and 12
            -- Friendly games between 4th, 5th, 6th of this league and 4th, 5th, 6th of symmetric league for two first weeks (not for first level leagues)
            IF league.LEVEL > 2 THEN
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 4, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 5, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 6, -league.id, league.id);
            END IF;

            ---- Barrage1 Left League
            -- Week 11 and 12: Games between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 1, league.id, league.id)
RETURNING id INTO loc_id_game_1;

            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 2, league.id, league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_1;

            -- Week 13 and 14: Relegation Game Between 5th of the upper league and Loser of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 5, 2, league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 5, loc_id_game_1, league.id, loc_id_game_2);
            -- Friendly Games between 6th of the lower leagues and Winner of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 6, 1, league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 6, loc_id_game_1, league.id, loc_id_game_2);
            ---- Barrage1 Right League
            -- Week 11 and 12: Games between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 1, -league.id, -league.id)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 2, -league.id, -league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_1;
            -- Week 13 and 14: Relegation Game Between 5th of the upper league and Loser of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 5, 2, -league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 5, loc_id_game_1, -league.id, loc_id_game_2);
            -- Friendly Games between 6th of the lower leagues and Winner of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 6, 1, -league.id, loc_id_game_1)
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 6, loc_id_game_1, -league.id, loc_id_game_2);

            ---- Barrage2
            --- Right League
            -- Week 11
            -- Game1 {3 vs 6}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 3, 6, league.id, league.id)
RETURNING id INTO loc_id_game_1;
            -- Game2 {4 vs 5}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 5, league.id, league.id)
RETURNING id INTO loc_id_game_2;
            -- Week12
            -- Barrage2: First Game {Winner of loc_id_game_b2g1 vs Winner of loc_id_game_b2g2}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, loc_id_game_1, loc_id_game_2)
RETURNING id INTO loc_id_game_1L;
            -- Barrage2: Friendly Second Game {Loser of loc_id_game_b2g1 vs Loser of loc_id_game_b2g2}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 2, loc_id_game_1, loc_id_game_2)
RETURNING id INTO loc_id_game_2L;
            --- Left League
            -- Week 11
            -- Game1 {3 vs 6}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 3, 6, -league.id, -league.id)
RETURNING id INTO loc_id_game_1;
            -- Game2 {4 vs 5}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 5, -league.id, -league.id)
RETURNING id INTO loc_id_game_2;
            -- Week12
            -- Barrage2: First Game {Winner of loc_id_game_b2g1 vs Winner of loc_id_game_b2g2}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, loc_id_game_1, loc_id_game_2)
RETURNING id INTO loc_id_game_1R;
            -- Barrage2: Friendly Second Game {Loser of loc_id_game_b2g1 vs Loser of loc_id_game_b2g2}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 2, loc_id_game_1, loc_id_game_2)
RETURNING id INTO loc_id_game_2R;
            -- Week 13 and 14
            -- Relegation between 4th of master league and Winner of the barrage2
            -- Left League
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 1, league.id, loc_id_game_1L)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 4, loc_id_game_1L, league.id, loc_id_game_1);
            -- Right League
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 1, -league.id, loc_id_game_1R)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 4, loc_id_game_1R, -league.id, loc_id_game_1);
            -- Friendly Game between Losers of the second round of barrage2 (loc_id_game_b2w2g2L and loc_id_game_b2w2g2R) between leagues
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 2, loc_id_game_1L, loc_id_game_1R)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 2, loc_id_game_2L, loc_id_game_2R, loc_id_game_1);
            -- Friendly Game between Winners of the losing round of barrage2 (loc_id_game_b2w2g2L and loc_id_game_b2w2g2R) between leagues
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 1, 1, loc_id_game_2L, loc_id_game_2R)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_2R, loc_id_game_2L, loc_id_game_1);
            -- Friendly Game between Losers of the losing round of barrage2 (loc_id_game_b2w2g2L and loc_id_game_b2w2g2R) between leagues
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 2, loc_id_game_2L, loc_id_game_2R)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 2, loc_id_game_2R, loc_id_game_2L, loc_id_game_1);

        END LOOP; -- End of the league loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the lowest leagues of the multiverse of each continent
        FOR league IN 
            (SELECT * FROM leagues WHERE
                LEVEL > 0
                AND id < 0 -- Only select the left leagues
                AND id NOT IN ( -- Exclude the leagues that are the upper leagues
                    SELECT id_upper_league FROM leagues WHERE multiverse_speed = 1
                        AND id_upper_league IS NOT NULL)
            )
        LOOP

            -- Friendly Games between clubs of symmetric leagues
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 5, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 6, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 4, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 4, 5, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 5, 6, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 6, 4, league.id, -league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 4, 4, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 5, -league.id, league.id),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 6, 6, -league.id, league.id);

        END LOOP; -- End of the lowest league loop

    END LOOP; -- End of the multiverse loop

END;
$function$
;
