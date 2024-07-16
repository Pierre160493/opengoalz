-- DROP FUNCTION public.generate_new_season(timestamptz, int8, int8, int8);

CREATE OR REPLACE FUNCTION public.generate_new_season_games_and_teamcomps(
    inp_multiverse_speed bigint[],
    inp_season_number bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for multiverse loop
    league RECORD; -- Record for league loop
    club RECORD; -- Record for club loop
    loc_tmp_games_teamcomp_id bigint; -- Temporary variable to store the id of the games_teamcomp 
    mat_ij bigint[6][15] :=ARRAY[
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp [1: Id of the club]
    loc_date_start timestamp with time ZONE;-- Start date of the first round of games
    loc_interval_1_week INTERVAL := INTERVAL '7 days' / inp_m_speed; -- Date interval between games
    loc_tmp_id bigint; -- Temporary variable to store an id
    loc_array_id_games bigint[6]; -- Temporary variable to store games id
    loc_id_game_b1w1g1 bigint; -- Id of the game of the barrage1, week1, game1
    loc_id_game_b1w2g1 bigint; -- Id of the game of the barrage1, week2, game1
    loc_id_game_b2w1g1 bigint; -- Id of the game of the barrage2, week1, game1
    loc_id_game_b2w1g2 bigint; -- Id of the game of the barrage2, week1, game2
    loc_id_game_b2w2g1 bigint; -- Id of the game of the barrage2, week2, game1
    loc_id_game_b2w2g2 bigint; -- Id of the game of the barrage2, week2, game2 (friendly game)
    loc_id_game_b2w3g1 bigint; -- Id of the game of the barrage2, week3, game1
BEGIN

    -- Loop through the multiverses
    FOR multiverse IN
        (SELECT * FROM multiverse WHERE speed IN inp_multiverse_speed)
    LOOP

         -- Start date of the first round of games
        loc_date_start := multiverse.date_start + INTERVAL '5 days 21 hours';

        -- Calculate the date interval for 1 week depending on the multiverse speed
        loc_interval_1_week INTERVAL := INTERVAL '7 days' / multiverse.speed; -- Date interval between games
    
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
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_left_club, pos_right_club) VALUES
            -- Week 1 and 10
(multiverse.speed, league.id, inp_season_number, 1, loc_date_start, TRUE, 1, 2),
(multiverse.speed, league.id, inp_season_number, 1, loc_date_start, TRUE, 4, 3),
(multiverse.speed, league.id, inp_season_number, 1, loc_date_start, TRUE, 5, 6),
(multiverse.speed, league.id, inp_season_number, 10, loc_date_start + loc_interval_1_week * 9, TRUE, 2, 1),
(multiverse.speed, league.id, inp_season_number, 10, loc_date_start + loc_interval_1_week * 9, TRUE, 3, 4),
(multiverse.speed, league.id, inp_season_number, 10, loc_date_start + loc_interval_1_week * 9, TRUE, 6, 5),
            -- Week 2 and 9
(multiverse.speed, league.id, inp_season_number, 2, loc_date_start + loc_interval_1_week, TRUE, 3, 1),
(multiverse.speed, league.id, inp_season_number, 2, loc_date_start + loc_interval_1_week, TRUE, 2, 5),
(multiverse.speed, league.id, inp_season_number, 2, loc_date_start + loc_interval_1_week, TRUE, 6, 4),
(multiverse.speed, league.id, inp_season_number, 9, loc_date_start + loc_interval_1_week * 8, TRUE, 1, 3),
(multiverse.speed, league.id, inp_season_number, 9, loc_date_start + loc_interval_1_week * 8, TRUE, 5, 2),
(multiverse.speed, league.id, inp_season_number, 9, loc_date_start + loc_interval_1_week * 8, TRUE, 4, 6),
            -- Week 3 and 8
(multiverse.speed, league.id, inp_season_number, 3, loc_date_start + loc_interval_1_week * 2, TRUE, 1, 5),
(multiverse.speed, league.id, inp_season_number, 3, loc_date_start + loc_interval_1_week * 2, TRUE, 3, 6),
(multiverse.speed, league.id, inp_season_number, 3, loc_date_start + loc_interval_1_week * 2, TRUE, 4, 2),
(multiverse.speed, league.id, inp_season_number, 8, loc_date_start + loc_interval_1_week * 7, TRUE, 5, 1),
(multiverse.speed, league.id, inp_season_number, 8, loc_date_start + loc_interval_1_week * 7, TRUE, 6, 3),
(multiverse.speed, league.id, inp_season_number, 8, loc_date_start + loc_interval_1_week * 7, TRUE, 2, 4),
            -- Week 4 and 7
(multiverse.speed, league.id, inp_season_number, 4, loc_date_start + loc_interval_1_week * 3, TRUE, 6, 1),
(multiverse.speed, league.id, inp_season_number, 4, loc_date_start + loc_interval_1_week * 3, TRUE, 5, 4),
(multiverse.speed, league.id, inp_season_number, 4, loc_date_start + loc_interval_1_week * 3, TRUE, 2, 3),
(multiverse.speed, league.id, inp_season_number, 7, loc_date_start + loc_interval_1_week * 6, TRUE, 1, 6),
(multiverse.speed, league.id, inp_season_number, 7, loc_date_start + loc_interval_1_week * 6, TRUE, 4, 5),
(multiverse.speed, league.id, inp_season_number, 7, loc_date_start + loc_interval_1_week * 6, TRUE, 3, 2),
            -- Week 5 and 6
(multiverse.speed, league.id, inp_season_number, 5, loc_date_start + loc_interval_1_week * 4, TRUE, 1, 4),
(multiverse.speed, league.id, inp_season_number, 5, loc_date_start + loc_interval_1_week * 4, TRUE, 6, 2),
(multiverse.speed, league.id, inp_season_number, 5, loc_date_start + loc_interval_1_week * 4, TRUE, 5, 3),
(multiverse.speed, league.id, inp_season_number, 6, loc_date_start + loc_interval_1_week * 5, TRUE, 4, 1),
(multiverse.speed, league.id, inp_season_number, 6, loc_date_start + loc_interval_1_week * 5, TRUE, 2, 6),
(multiverse.speed, league.id, inp_season_number, 6, loc_date_start + loc_interval_1_week * 5, TRUE, 3, 5);

        END LOOP; -- End of the league loop

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the international leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND level = 0)
        LOOP

            -- Schedule the international league games
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_league, pos_left_club, pos_right_club) VALUES
            -- Week 11 (First of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 1, 4),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 2, 3),
            -- Week 12 (Second of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 6, 1),
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 5, 2),
            -- Week 13 (Third of 3 rounds)
(multiverse.speed, league.id, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 4, 6),
(multiverse.speed, league.id, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 3, 5),
            -- Week 14 (Cup round)
(multiverse.speed, league.id, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 1, 2),
(multiverse.speed, league.id, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 3, 4),
(multiverse.speed, league.id, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 5, 6);

            -- Schedule the 3 international friendly games
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club) VALUES
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 5, 6),
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 3, 4),
(multiverse.speed, league.id, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 1, 2);

        END LOOP; -- End of the international league loop

        -- Create the international friendly games between the continents (4th against eachother, same for 5th and 6th) 
        INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club) VALUES
-- 4th play against eachother on week 11
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 1, 6),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 2, 5),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 3, 4),
-- And on week 12
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 1, 6),
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 2, 5),
(multiverse.speed, league.id, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 3, 4),
-- 5th play against eachother
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 1, 6),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 2, 5),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 3, 4),
-- 6th play against eachother
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 1, 6),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 2, 5),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 3, 4);

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND id < 0
            AND level > 0)
        LOOP

            -- {1, 2} are the champions of the lower leagues league.id and -league.id 
            -- {3, 4} are the 2nd of the lower leagues league.id and -league.id 
            -- {5, 6} are the 2nd of the lower leagues league.id and -league.id



            ------ Week11 games
            -- [1, 2, 3]: Friendly games for the 4th, 5th and 6th clubs of the upper league
            -- [4] Relegation1: 1sts of both lower leagues {4 vs 5} ==> Winner goes up, Loser plays barrage against 5th of upper league
            -- [5, 6] Relegation2: 2nds and 3rds of both lower leagues {6 vs 9} and {7 vs 8} ==> Both winners plays against each other

            ------ Week11
            -- Games[1, 2, 3]: Friendly games between 4th, 5th, 6th of this league and 4th, 5th, 6th of symmetric league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 4, 5, league.id, -league.id),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 5, 4, league.id, -league.id),
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 6, 6, league.id, -league.id);
            -- Game[4]: First relegation series with game between both 1st of the lower leagues ==> Winner goes up, Loser plays barrage against 5th of upper league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 1, 2, league.id, league.id)
RETURNING loc_id_game_b1w1g1;
            -- Game[5]: First Game of Round 1 of Second relegation series {6 vs 9}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 3, 6, league.id, league.id),
RETURNING loc_id_game_b2w1g1;
            -- Game[6]: Second Game of Round 1 of Second relegation series {7 vs 8}
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 4, 5, league.id, league.id)
RETURNING loc_id_game_b2w1g2;

            ------ Week12
            -- Game[1]: Friendly game between 4th of this league and 4th of symmetric league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 4, 4, league.id, league.id);
            -- Game[2]: Barrage game between 5th of this league and Loser (2) of Barrage1 Game[4]
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 5, 2, league.id, loc_id_game_b1w1g1)
RETURNING loc_id_game_b1w2g1;
            -- Game[3]: Friendly game between 6th of upper league (who is going down) and Winner (1) of Barrage1 Game[4] who is going up
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 6, 1, league.id, loc_id_game_b1w1g1);
            -- Game[4]: First Game of Round 2 of Second relegation series Winner of Game[5] vs Winner of Game[6]
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_game_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 1, 1, loc_id_game_b2w1g1, loc_id_game_b2w1g2)
RETURNING loc_id_game_b2w2g1;
            -- Game[5]: Friendly Second Game of Round 2 of Second relegation series Loser of Game[5] vs Loser of Game[6]
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_game_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 2, 2, loc_id_game_b2w1g1, loc_id_game_b2w1g2)
RETURNING loc_id_game_b2w2g2;

            ------ Week13
            -- Game[1]: Round 2 (last) of Second relegation series opposing 4th of master league and Winner of second relegation series (Game[4])
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 4, 1, league.id, loc_id_game_b2w2g1)
RETURNING loc_id_game_b2w3g1;
            -- Game[2]: Friendly game between Winner of First Game of Barrage 1 and Winner of Second Game of Barrage 1 (both team going (or staying) up)
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 1, 1, loc_id_game_b1w1g1, loc_id_game_b1w2g1);
            -- Game[3]: Friendly game between 6th of this league (who is going down) and Loser of Second Game of Barrage 1 (who is going down (or not going up))
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 6, 2, league.id, loc_id_game_b1w2g1);
            -- Game[4]: Friendly game between Winner of friendly game of losers b2w2g2 and loser of b2w2g1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 2, 1, loc_id_game_b2w2g1, loc_id_game_b2w2g2)
RETURNING loc_id_game_f;
            -- Game[4]: Friendly game between Loser of b2w2g2 and symmetric team (SPECIAL HANDLING HERE BECAUSE WILL BE FULLY SET LATER)
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 13, loc_date_start + loc_interval_1_week * 12, TRUE, 2, 2, loc_id_game_b2w2g2, NULL);

            ------ Week14
            -- Game[1]: Friendly game between Winner of b1w1g1 and Winner of b2w3g1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_game_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 1, 1, loc_id_game_b1w1g1, loc_id_game_b2w3g1);
            -- Game[2]: Friendly game between Winner of b1w2g1 and Loser of b2w3g1
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_game_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 1, 2, loc_id_game_b1w2g1, loc_id_game_b2w3g1);
            -- Game[3]: Friendly game between both team going down that finished 6th of their league
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 6, 6, league.id, -league.id);
            -- Game[4]: Friendly game between Loser of b1w2g1 and Winner of last friendly game of week 13
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 2, 1, loc_id_game_b1w2g1, loc_id_game_f);
            -- Game[5]: Friendly game between Loser of last friendly game of week 13 and Loser of game_b2w2g2
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_league_left_club, id_game_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 14, loc_date_start + loc_interval_1_week * 13, TRUE, 2, 2, loc_id_game_f, loc_id_game_b2w2g2);

        END LOOP; -- End of the league loop
    END LOOP; -- End of the multiverse loop

END;
$function$
;