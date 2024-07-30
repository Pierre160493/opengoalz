-- DROP FUNCTION public.new_season_generate_games_and_teamcomps(int8, int8, timestamptz);

CREATE OR REPLACE FUNCTION public.handle_season_generate_games_and_teamcomps(inp_multiverse_speed bigint, inp_season_number bigint, inp_date_start timestamp with time zone)
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
    loc_id_game_transverse bigint := NULL; -- Id of the game used to make friendly game between winners of first barrage 1 between brother leagues 
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
            ORDER BY continent, level)
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
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
            -- Week 1 and 10
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 1, 2, league.id, league.id, 1),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 4, 3, league.id, league.id, 2),
(multiverse.speed, league.id, inp_season_number, 1, inp_date_start, TRUE, 5, 6, league.id, league.id, 3),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 2, 1, league.id, league.id, 91),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 3, 4, league.id, league.id, 92),
(multiverse.speed, league.id, inp_season_number, 10, inp_date_start + loc_interval_1_week * 9, TRUE, 6, 5, league.id, league.id, 93),
            -- Week 2 and 9
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 3, 1, league.id, league.id, 11),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 2, 5, league.id, league.id, 12),
(multiverse.speed, league.id, inp_season_number, 2, inp_date_start + loc_interval_1_week, TRUE, 6, 4, league.id, league.id, 13),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 1, 3, league.id, league.id, 81),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 5, 2, league.id, league.id, 82),
(multiverse.speed, league.id, inp_season_number, 9, inp_date_start + loc_interval_1_week * 8, TRUE, 4, 6, league.id, league.id, 83),
            -- Week 3 and 8
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 1, 5, league.id, league.id, 21),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 3, 6, league.id, league.id, 22),
(multiverse.speed, league.id, inp_season_number, 3, inp_date_start + loc_interval_1_week * 2, TRUE, 4, 2, league.id, league.id, 23),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 5, 1, league.id, league.id, 71),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 6, 3, league.id, league.id, 72),
(multiverse.speed, league.id, inp_season_number, 8, inp_date_start + loc_interval_1_week * 7, TRUE, 2, 4, league.id, league.id, 73),
            -- Week 4 and 7
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 6, 1, league.id, league.id, 31),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 5, 4, league.id, league.id, 32),
(multiverse.speed, league.id, inp_season_number, 4, inp_date_start + loc_interval_1_week * 3, TRUE, 2, 3, league.id, league.id, 33),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 1, 6, league.id, league.id, 61),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 4, 5, league.id, league.id, 62),
(multiverse.speed, league.id, inp_season_number, 7, inp_date_start + loc_interval_1_week * 6, TRUE, 3, 2, league.id, league.id, 63),
            -- Week 5 and 6
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 1, 4, league.id, league.id, 41),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 6, 2, league.id, league.id, 42),
(multiverse.speed, league.id, inp_season_number, 5, inp_date_start + loc_interval_1_week * 4, TRUE, 5, 3, league.id, league.id, 43),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 4, 1, league.id, league.id, 51),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 2, 6, league.id, league.id, 52),
(multiverse.speed, league.id, inp_season_number, 6, inp_date_start + loc_interval_1_week * 5, TRUE, 3, 5, league.id, league.id, 53);

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
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
            -- Week 11 (First Round)
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 4, league.id, league.id, 101),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 2, 5, league.id, league.id, 102),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 3, 6, league.id, league.id, 103),
            -- Week 12 (Second Round)
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 1, 5, league.id, league.id, 111),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 2, 6, league.id, league.id, 112),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, 3, 4, league.id, league.id, 113),
            -- Week 13 (Third Round)
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 1, 6, league.id, league.id, 121),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 4, league.id, league.id, 122),
(multiverse.speed, league.id, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 3, 5, league.id, league.id, 123),
            -- Week 14 (Cup round)
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 1, 2, league.id, league.id, 131),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 3, 4, league.id, league.id, 132),
(multiverse.speed, league.id, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, 5, 6, league.id, league.id, 133);

            -- 3*2 intercontinental friendly games between 4th, 5th and 6th of master leagues for week 11 and 12
            ELSE
            
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 1, league.id, league.id, 191),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 5, league.id, league.id, 192),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 2, league.id, league.id, 193),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 4, league.id, league.id, 194),
(multiverse.speed, league.id, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 3, league.id, league.id, 195),
(multiverse.speed, league.id, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 3, 6, league.id, league.id, 196);

            END IF;
        END LOOP; -- End of the international league loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND id < 0
            AND level > 1
            ORDER BY id_upper_league)
        LOOP

            -- {1, 2} are the champions of the lower leagues league.id and -league.id 
            -- {3, 4} are the 2nd of the lower leagues league.id and -league.id 
            -- {5, 6} are the 2nd of the lower leagues league.id and -league.id

            ---- 4th, 5th and 6th Friendly Games for Week11 and 12
            -- Friendly games between 4th, 5th, 6th of this league and 4th, 5th, 6th of symmetric league for two first weeks (not for first level leagues because they already play friendly international)
            IF league.LEVEL > 2 THEN
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 161),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 4, -league.id, league.id, 162),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 163),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 5, -league.id, league.id, 164),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 165),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 6, -league.id, league.id, 166);
            END IF;

            ---- Barrage1
            -- Week 11 and 12: Games between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, 1, 1, league.id, -league.id, 211)
RETURNING id INTO loc_id_game_1;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, is_return_game_id_game_first_round, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, -league.id, league.id, loc_id_game_1, 212)
RETURNING id INTO loc_id_game_1;
            -- Week 13 and 14: Friendly game between winner of the barrage 1 and winner of the barrage 1 from the symmetric league
            IF loc_id_game_transverse IS NULL THEN
                -- Store the game id for the next winner of the barrage 1 from league that will play friendly game against the winner of this league barrage 1  
                loc_id_game_transverse := loc_id_game_1;
            ELSE
                -- Then we can insert the game between two winners of barrage 1
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 1, 1, loc_id_game_1, loc_id_game_transverse, 215)
RETURNING id INTO loc_id_game_2;
                INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, is_return_game_id_game_first_round, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_transverse, loc_id_game_1, loc_id_game_2, 216);
                -- Reset to NULL for next leagues
                loc_id_game_transverse := NULL;
            END IF;
            -- Week 13 and 14: Relegation Game Between 5th of the upper league and Loser of the barrage1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_game_club_right, id_league_club_left, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 2, 5, loc_id_game_1, league.id_upper_league, 213)
RETURNING id INTO loc_id_game_2;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_right, id_game_club_left, is_return_game_id_game_first_round, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 2, league.id_upper_league, loc_id_game_1, loc_id_game_2, 214);
            
            ---- Barrage2
            -- Week 11
            -- Game1: Barrage between 2nd and 3rd {2nd of left league vs 3rd of right league}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, league.id, -league.id, 311)
RETURNING id INTO loc_id_game_3;
            -- Game2: Barrage between 2nd and 3rd {2nd of right league vs 3rd of left league}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 2, 3, -league.id, league.id, 312)
RETURNING id INTO loc_id_game_4;
            -- Week12
            -- Game1: Barrage between winners of the first round {Winner of loc_id_game_1 vs Winner of loc_id_game_2} => Winner plays barrage and loser plays friendly
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 1, 1, loc_id_game_3, loc_id_game_4, 321)
RETURNING id INTO loc_id_game_1;
            -- Game2: Friendly between losers of first round {Loser of loc_id_game_1 vs Loser of loc_id_game_2} => Winner plays international friendly game and loser plays friendly
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 2, 2, loc_id_game_3, loc_id_game_4, 322)
RETURNING id INTO loc_id_game_2;
            ------ Week 13 and 14
            -- Relegation between 4th of master league and Winner of the barrage2
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_club_left, pos_club_right, id_league_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, 4, 1, league.id_upper_league, loc_id_game_1, 331)
RETURNING id INTO loc_id_game_3;
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, is_return_game_id_game_first_round, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 4, loc_id_game_1, league.id_upper_league, loc_id_game_3, 332);
            ------ Week 13
            -- Friendly game between loser of second round of barrage 2 and winner of friendly game between losers of the first round of the barrage 2
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 2, 2, loc_id_game_1, loc_id_game_2, 341)
RETURNING id INTO loc_id_game_3;
            -- Friendly game between winner of friendly game between losers of first round of barrage 2 and 6th club from the upper league (that is going down)
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 1, 6, loc_id_game_2, league.id_upper_league, 342)
RETURNING id INTO loc_id_game_4;
            ------ Week 14
            -- Friendly Game between winners of last two friendly games loc_id_game_3 and loc_id_game_4
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 1, 1, loc_id_game_3, loc_id_game_4, 351);
            -- Friendly Game between losers of last two friendly games loc_id_game_3 and loc_id_game_4
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_game_club_left, id_game_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 2, 2, loc_id_game_3, loc_id_game_4, 352);

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
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, is_cup, pos_club_left, pos_club_right, id_league_club_left, id_league_club_right, id_game_description) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 4, 4, league.id, -league.id, 411),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 5, 5, league.id, -league.id, 412),
(multiverse.speed, league.id_upper_league, inp_season_number, 11, inp_date_start + loc_interval_1_week * 10, TRUE, TRUE, 6, 6, league.id, -league.id, 413),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 4, 5, -league.id, league.id, 421),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 5, 6, -league.id, league.id, 422),
(multiverse.speed, league.id_upper_league, inp_season_number, 12, inp_date_start + loc_interval_1_week * 11, TRUE, TRUE, 6, 4, -league.id, league.id, 423),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 4, 5, league.id, -league.id, 431),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 5, 6, league.id, -league.id, 432),
(multiverse.speed, league.id_upper_league, inp_season_number, 13, inp_date_start + loc_interval_1_week * 12, TRUE, TRUE, 6, 4, league.id, -league.id, 433),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 4, 4, -league.id, league.id, 441),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 5, 5, -league.id, league.id, 442),
(multiverse.speed, league.id_upper_league, inp_season_number, 14, inp_date_start + loc_interval_1_week * 13, TRUE, TRUE, 6, 6, -league.id, league.id, 443);

        END LOOP; -- End of the lowest league loop

    END LOOP; -- End of the multiverse loop

END;
$function$
;
