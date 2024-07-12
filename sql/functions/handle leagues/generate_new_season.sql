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
BEGIN

    -- Loop through the multiverses
    FOR multiverse IN
        (SELECT * FROM multiverse WHERE speed IN inp_multiverse_speed)
    LOOP

         -- Start date of the first round of games
        loc_date_start := multiverse.date_start + INTERVAL '5 days 21 hours';

        -- Calculate the date interval for 1 week depending on the multiverse speed
        loc_interval_1_week INTERVAL := INTERVAL '7 days' / multiverse.speed; -- Date interval between games

        -- INSERT INTO games_teamcomp (id_club, week_number, season_number)
        -- SELECT club.id, generate_series, inp_season_number
        --     FROM 
        --         (SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed ORDER BY level) AS league
        --         JOIN 
        --         (SELECT * FROM clubs WHERE id_league = league.id ORDER BY pos_league) AS club
        --         CROSS JOIN 
        --         generate_series(1, 14) AS weeks(generate_series);
    
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

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------ Loop through the normal leagues of the multiverse
        FOR league IN 
            (SELECT * FROM leagues
            WHERE multiverse_speed = multiverse.speed
            AND id < 0
            AND level > 0)
        LOOP

            -- {1, 2, 3} are the 4th, 5th and 6th clubs of the upper league
            -- {4, 5} are the champions of the lower leagues league.id and -league.id 
            -- {6, 7} are the 2nd of the lower leagues league.id and -league.id 
            -- {8, 9} are the 2nd of the lower leagues league.id and -league.id 

            -- Schedule the first relegation series with game between both winners of the lower leagues ==> Winner goes up
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 4, 5, league.id, -league.id)
RETURNING loc_tmp_id;
            -- Friendly relegation game between winner (1) of first relegation game (loc_tmp_id) and 3 (last of upper league)
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_friendly, pos_left_club, pos_right_club, id_game_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 12, loc_date_start + loc_interval_1_week * 11, TRUE, 1, 3, loc_tmp_id, league.id_upper_league);

            -- Schedule the second relegation game between both winners of the lower leagues ==> Winner goes up
            INSERT INTO games (
multiverse_speed, id_league, season_number, week_number, date_start, is_relegation, pos_left_club, pos_right_club, id_league_left_club, id_league_right_club) VALUES
(multiverse.speed, league.id_upper_league, inp_season_number, 11, loc_date_start + loc_interval_1_week * 10, TRUE, 4, 5, league.id, -league.id)
RETURNING loc_tmp_id;


        END LOOP; -- End of the league loop

    END LOOP; -- End of the multiverse loop


END;
$function$
;
