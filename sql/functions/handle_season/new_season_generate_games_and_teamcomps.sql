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
    loc_id_game_3 bigint; -- Id of the game
    loc_id_game_4 bigint; -- Id of the game
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
            ORDER BY continents, level)
        LOOP

            -- Loop through the clubs of the league
            FOR club IN
                (SELECT * FROM clubs WHERE id_league = league.id ORDER BY pos_league)
            LOOP

                -- Loop through the 14 weeks of the season
                FOR J IN 1..14 LOOP

                    -- Insert the games_teamcomp for the club for the 10 weeks of the season
                    INSERT INTO games_teamcomp (id_club, week_number, season_number)
                    VALUES (club.id, J, inp_season_number);

                END LOOP; -- End of the loop for the weeks of the season
            END LOOP; -- End of the club loop

            -- Schedule games of first 10 weeks
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
            -- Week 1 and 10
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 1, 2, league.id, league.id, '1st league game of week 1'),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 4, 3, league.id, league.id, '2nd league game of week 1'),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 5, 6, league.id, league.id, '3rd league game of week 1'),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 2, 1, league.id, league.id, '1st league game of week 10'),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 3, 4, league.id, league.id, '2nd league game of week 10'),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 6, 5, league.id, league.id, '3rd league game of week 10'),
            -- Week 2 and 9
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 3, 1, league.id, league.id, '1st league game of week 2'),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 2, 5, league.id, league.id, '2nd league game of week 2'),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 6, 4, league.id, league.id, '3rd league game of week 2'),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 1, 3, league.id, league.id, '1st game of week 9'),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 5, 2, league.id, league.id, '2nd game of week 9'),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 4, 6, league.id, league.id, '3rd game of week 9'),
            -- Week 3 and 8
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 1, 5, league.id, league.id, '1st league game of week 3'),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 3, 6, league.id, league.id, '2nd league game of week 3'),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 4, 2, league.id, league.id, '3rd league game of week 3'),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 5, 1, league.id, league.id, '1st league game of week 8'),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 6, 3, league.id, league.id, '2nd league game of week 8'),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 2, 4, league.id, league.id, '3rd league game of week 8'),
            -- Week 4 and 7
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 6, 1, league.id, league.id, '1st league game of week 4'),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 5, 4, league.id, league.id, '2nd league game of week 4'),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 2, 3, league.id, league.id, '3rd league game of week 4'),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 1, 6, league.id, league.id, '1st league game of week 7'),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 4, 5, league.id, league.id, '2nd league game of week 7'),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 3, 2, league.id, league.id, '3rd league game of week 7'),
            -- Week 5 and 6
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 1, 4, league.id, league.id, '1st league game of week 5'),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 6, 2, league.id, league.id, '2nd league game of week 5'),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 5, 3, league.id, league.id, '3rd league game of week 5'),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 4, 1, league.id, league.id, '1st league game of week 6'),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 2, 6, league.id, league.id, '2nd league game of week 6'),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 3, 5, league.id, league.id, '3rd league game of week 6');

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
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
            -- Week 11 (First of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 4, league.id, league.id, '1st international league game of week 11'),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 3, league.id, league.id, '2nd international league game of week 11'),
            -- Week 12 (Second of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 6, 1, league.id, league.id, '1st international league game of week 12'),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 5, 2, league.id, league.id, '2nd international league game of week 12'),
            -- Week 13 (Third of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 6, league.id, league.id, '1st international league game of week 13'),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 3, 5, league.id, league.id, '2nd international league game of week 13'),
            -- Week 14 (Cup round)
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 1, 2, league.id, league.id, '1st international cup game of week 14 for winners of the international league'),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 3, 4, league.id, league.id, '2nd international cup game of week 14 for seconds of the international league'),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 5, 6, league.id, league.id, '3rd international cup game of week 14 for thirds of the international league');

                -- Schedule the 3 international friendly games
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 6, league.id, league.id, 'International friendly game of week 11 for both clubs that are free from international league this week'),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 4, league.id, league.id, 'International friendly game of week 12 for both clubs that are free from international league this week'),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 1, 2, league.id, league.id, 'International friendly game of week 13 for both clubs that are free from international league this week');

            -- 3*2 intercontinental friendly games between 4th, 5th and 6th of master leagues for week 11 and 12
            ELSE
            
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 1, league.id, league.id, 'International friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 5, league.id, league.id, 'International friendly game of week 12 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 2, league.id, league.id, 'International friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 4, league.id, league.id, 'International friendly game of week 12 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 3, league.id, league.id, 'International friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 6, league.id, league.id, 'International friendly game of week 12 for clubs waiting the results of the barrages');

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
            -- Friendly games between 4th, 5th, 6th of this league and 4th, 5th, 6th of symmetric league for two first weeks (not for first level leagues because they already play friendly international)
            IF league.LEVEL > 2 THEN
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 'Intercontinental friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 4, -league.id, league.id, 'Intercontinental friendly game of week 12 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 'Intercontinental friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 5, -league.id, league.id, 'Intercontinental friendly game of week 12 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 'Intercontinental friendly game of week 11 for clubs waiting the results of the barrages'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 6, -league.id, league.id, 'Intercontinental friendly game of week 12 for clubs waiting the results of the barrages');
            END IF;

            ---- Barrage1
            -- Week 11 and 12: Games between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 1, league.id, -league.id, '1st game of the barrage 1 (week 11) of the lower leagues between champions of the left and right league')
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, is_return_game_id_game_first_round, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, -league.id, league.id, loc_id_game_1, '2nd and final game of the barrage 1 (week 12) of the lower leagues between champions of the left and right league')
RETURNING id INTO loc_id_game_1;
            -- Week 13 and 14: Relegation Game Between 5th of the upper league and Loser of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 5, 2, league.id_upper_league, loc_id_game_1, '3rd game of the barrage 1 (week 13) between 5th of the upper league and loser of the barrage 1')
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 5, loc_id_game_1, league.id_upper_league, loc_id_game_2, '4th and final game of the barrage 1 (week 14) between 5th of the upper league and loser of the barrage 1');
            -- Friendly Games between 6th of the lower leagues and Winner of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 6, 1, league.id_upper_league, loc_id_game_1, 'Friendly game of the barrage 1 (week 13) between 6th of the upper league and winner of the barrage 1')
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 6, loc_id_game_1, league.id_upper_league, loc_id_game_2, 'Friendly return game of the barrage 1 (week 14) between 6th of the upper league and winner of the barrage 1');
            
            ---- Barrage2
            -- Week 11
            -- Game1: Barrage between 2nd and 3rd {2nd of left league vs 3rd of right league}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, league.id, -league.id, '1st game of the barrage 2 (week 11) of the lower leagues between 2nd of the left league and 3rd of the right league')
RETURNING id INTO loc_id_game_3;
            -- Game2: Barrage between 2nd and 3rd {2nd of right league vs 3rd of left league}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, -league.id, league.id, '2nd game of the barrage 2 (week 11) of the lower leagues between 2nd of the right league and 3rd of the left league')
RETURNING id INTO loc_id_game_4;
            -- Week12
            -- Game1: Barrage between winners of the first round {Winner of loc_id_game_1 vs Winner of loc_id_game_2} => Winner plays barrage and loser plays friendly
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, loc_id_game_3, loc_id_game_4, '1st game of the barrage 2 (week 12) of the lower leagues between the winners of the first round of the barrage 2')
RETURNING id INTO loc_id_game_1;
            -- Game2: Friendly between losers of first round {Loser of loc_id_game_1 vs Loser of loc_id_game_2} => Winner plays international friendly game and loser plays friendly
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 2, loc_id_game_3, loc_id_game_4, '2nd and friendly game of the barrage 2 (week 12) of the lower leagues between the losers of the first round of the barrage 2')
RETURNING id INTO loc_id_game_2;
            ------ Week 13 and 14
            -- Relegation between 4th of master league and Winner of the barrage2
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 1, league.id, loc_id_game_1, '1st game of the barrage 2 (week 13) between the 4th of the upper league and the winner of the 2nd round of the barrage 2')
RETURNING id INTO loc_id_game_3;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 4, loc_id_game_1, league.id, loc_id_game_3, 'Return game of the barrage 2 (week 14) between the 4th of the upper league and the winner of the 2nd round of the barrage 2');
            ------ Week 13
            -- Friendly game between loser of second round of barrage 2 and loser of friendly game between losers of the first round of the barrage 2 => Winner will play an international friendly game
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 2, 2, loc_id_game_1, loc_id_game_2, 'Friendly cup game (week 13) between the loser of the winning round of the barrage 2 and the loser of the friendly round of the barrage 2')
RETURNING id INTO loc_id_game_3;
            -- International friendly game between the winner of the losing round of the barrage2 and symetric from other continent
--            INSERT INTO games (
--multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, description) VALUES
--(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 1, 1, loc_id_game_2, NULL, 'International friendly game (week13) between the winner of the losing round (week12) of the barrage2 and international symmetric');
            ------ Week 14
            -- Friendly Game between loser of the losing round of barrage2 and loser of friendly 
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 2, 2, loc_id_game_2, loc_id_game_3, 'Final friendly game (week 14) of the barrage2');
            -- International friendly game between winner of friendly game between loser of 
--            INSERT INTO games (
--multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, description) VALUES
--(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_3, NULL, 'Final international friendly game (week14) of the barrage2');

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
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 'Friendly game (week11) of the lowest leagues between 4th of left league with 4th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 'Friendly game (week11) of the lowest leagues between 5th of left league with 5th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 'Friendly game (week11) of the lowest leagues between 6th of left league with 6th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 5, -league.id, league.id, 'Friendly game (week12) of the lowest leagues between 4th of right league with 5th of left league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 6, -league.id, league.id, 'Friendly game (week12) of the lowest leagues between 5th of right league with 6th of left league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 4, -league.id, league.id, 'Friendly game (week12) of the lowest leagues between 6th of right league with 4th of left league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 4, 5, league.id, -league.id, 'Friendly game (week13) of the lowest leagues between 4th of left league with 5th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 5, 6, league.id, -league.id, 'Friendly game (week13) of the lowest leagues between 5th of left league with 6th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 6, 4, league.id, -league.id, 'Friendly game (week13) of the lowest leagues between 6th of left league with 4th of right league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 4, 4, -league.id, league.id, 'Friendly game (week14) of the lowest leagues between 4th of right league with 4th of left league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 5, -league.id, league.id, 'Friendly game (week14) of the lowest leagues between 5th of right league with 5th of left league'),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 6, 6, -league.id, league.id, 'Friendly game (week14) of the lowest leagues between 6th of right league with 6th of left league');

        END LOOP; -- End of the lowest league loop

    END LOOP; -- End of the multiverse loop

END;
$function$
;
