-- DROP FUNCTION public.handle_generation_after_season_games_and_new_season();

CREATE OR REPLACE FUNCTION public.handle_games_generartion()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    league RECORD; -- Record for the league loop
    club RECORD; -- Record for the club loop
    mat_ij bigint[6][5] :=ARRAY[
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp [1: Club ids, Other: Teamcomp ids for next 4 games]x[6 clubs]
    loc_tmp_id bigint;
    loc_array_id_clubs bigint[]; -- Id of the clubs that goes up
    loc_date timestamp WITH time ZONE; -- start date of the games
    loc_interval_1_week INTERVAL; -- Interval time for a week in this multiverse
    bool_simulate_games bool := FALSE; -- If the the simulate_games function has to be called again
BEGIN
RAISE NOTICE 'PG: Debut fonction handle_generation_after_season_games_and_new_season';
    -- Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP
        
        loc_interval_1_week := INTERVAL '7 days' / multiverse.speed; -- Interval of 1 week for this multiverse

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ If the league is over and the next season is not generated yet
        IF now() > multiverse.date_league_end AND multiverse.is_next_season_generated IS FALSE THEN

            -- Set this to TRUE to run another loop of simulate_games at the end of this function
            bool_simulate_games := TRUE;

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------ Start handling final positions in league and next season league (default values, will be overwritten later for the ups and downs)
            UPDATE clubs SET pos_league_next_season = pos_league, id_league_next_season = id_league
                WHERE multiverse_speed = multiverse.speed;

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------ Handle first level leagues with world cups
            -- Loop through the n world cups
            FOR N IN 1..3 LOOP

                -- Select the 6 clubs that will play the level N world cup
                SELECT clubs.id
                INTO loc_array_id_clubs
                FROM clubs
                JOIN leagues ON leagues.id = clubs.id_league
                WHERE leagues."level" = 1
                AND clubs.pos_league = N
                ORDER BY clubs.league_points DESC

                IF loc_array_id_clubs.lenth <> 6 THEN
                    RAISE EXCEPTION 'ERROR when handling champions world cup ==> 6 clubs expected, % found', loc_array_id_clubs.lenth;
                END IF;

                mat_ij := NULL;

                -- Loop through the 6 clubs
                FOR I IN 1..6 LOOP

                    -- Store the club id in the matrix
                    mat_ij[I][1] := loc_array_id_clubs[1];

                    -- Loop through the 3 games of the 2 leagues of the champions world cup
                    FOR J IN 1..3 LOOP

                        -- Select the id of the row of the teamcomp for the club I for the week number J
                        SELECT id INTO loc_tmp_id FROM games_teamcomp 
                        WHERE id_club = loc_array_id_clubs[I] AND week_number = (J+10) AND season_number = multiverse.season_number;

                        -- Store the teamcomp id in the matrix
                        mat_ij[i][j + 1] := loc_tmp_id;
                    END LOOP;
                END LOOP;

            -- Generate the games for the 3 next weeks of the season
                INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
(11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, 0),
(11, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][2], mat_ij[3][1], mat_ij[3][2], loc_date, TRUE, 0),
(12, multiverse.speed, league.season_number, mat_ij[4][1], mat_ij[4][3], mat_ij[5][1], mat_ij[5][3], loc_date + loc_interval_1_week * 1, TRUE, 0),
(12, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][3], mat_ij[6][1], mat_ij[6][3], loc_date + loc_interval_1_week * 1, TRUE, 0),
(13, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][4], mat_ij[1][1], mat_ij[1][4], loc_date + loc_interval_1_week * 2, TRUE, 0),
(13, multiverse.speed, league.season_number, mat_ij[6][1], mat_ij[6][4], mat_ij[2][1], mat_ij[2][4], loc_date + loc_interval_1_week * 2, TRUE, 0);

                -- Generate the friendly games
INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_friendly, id_league) VALUES
(11, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, 0),
(12, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][3], mat_ij[2][1], mat_ij[2][3], loc_date + loc_interval_1_week * 1, TRUE, 0),
(13, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][4], mat_ij[4][1], mat_ij[4][4], loc_date + loc_interval_1_week * 2, TRUE, 0);

            END LOOP; -- End of the loop through world cups

            -- Handle 4th position clubs
            SELECT clubs.id
            INTO loc_array_id_clubs
            FROM clubs
            JOIN leagues ON leagues.id = clubs.id_league
            WHERE leagues."level" = 1
            AND clubs.pos_league = 4
            ORDER BY clubs.league_points DESC

            FOR I IN 1..6 LOOP
                
                -- Store the club id in the matrix
                mat_ij[I][1] := loc_array_id_clubs[1];

                -- Select the id of the row of the teamcomp for the club I for the week number J
                SELECT id INTO loc_tmp_id FROM games_teamcomp 
                WHERE id_club = loc_array_id_clubs[I] AND week_number = 11 AND season_number = multiverse.season_number;

                -- Store the teamcomp id in the matrix
                mat_ij[i][2] := loc_tmp_id;
            END LOOP;

            -- Create the 3 games opoosing the 4th position clubs of each level 1 league
            INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_friendly, id_league) VALUES
(11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[2][1], mat_ij[2][2], loc_date, TRUE, 0),
(11, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, 0),
(11, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, 0);

            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------------------------------------------------------------------------------------------------------------------------------------------
            ------------  Loop through all leagues of the multiverse
            FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed AND level > 1) LOOP

                -- Loop through all clubs in the league ordered by position
                FOR club IN
                    (SELECT * FROM clubs 
                    WHERE id_league = league.id
                    ORDER BY pos_league)
                LOOP

                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------ Handle end season games
                    -- Insert the id of the club in the matrix for storing in games table
                    mat_ij[club.pos_league][1] := club.id;

                    -- Loop through the 4 final weeks of the season
                    FOR J IN 1..4 LOOP 

                        -- Select the id of the row of the teamcomp for the club I for the week number J
                        SELECT id INTO loc_tmp_id FROM games_teamcomp 
                        WHERE id_club = club.id AND week_number = (J+10) AND season_number = league.season_number;

                        -- If not found insert it
                        --IF loc_tmp_id IS NULL THEN
                        --    -- Insert a new row for the club I for the week number J if it doesn't already exist
                        --    INSERT INTO games_teamcomp (id_club, week_number, season_number)
                        --    VALUES (club.id, J, league.season_number)
                        --    RETURNING id INTO loc_tmp_id;
                        --END IF;

                        -- Insert the id of the games_teamcomp in the matrix for storing in games table
                        mat_ij[club.pos_league][J + 1] := loc_tmp_id;

                    END LOOP; -- End of the loop through weeks

                END LOOP; -- End of the loop through clubs
                
                loc_date = multiverse.date_league_end + INTERVAL '5 days 21 hours';

                -- Generate the games for the last 4 weeks of the season
                INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
(11, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][2], mat_ij[2][1], mat_ij[2][2], loc_date, TRUE, league.id),
(11, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][2], mat_ij[4][1], mat_ij[4][2], loc_date, TRUE, league.id),
(11, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][2], mat_ij[6][1], mat_ij[6][2], loc_date, TRUE, league.id),
(12, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][3], mat_ij[1][1], mat_ij[1][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
(12, multiverse.speed, league.season_number, mat_ij[4][1], mat_ij[4][3], mat_ij[3][1], mat_ij[3][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
(12, multiverse.speed, league.season_number, mat_ij[6][1], mat_ij[6][3], mat_ij[5][1], mat_ij[5][3], loc_date + loc_interval_1_week * 1, TRUE, league.id),
(13, multiverse.speed, league.season_number, mat_ij[1][1], mat_ij[1][4], mat_ij[2][1], mat_ij[2][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
(13, multiverse.speed, league.season_number, mat_ij[3][1], mat_ij[3][4], mat_ij[4][1], mat_ij[4][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
(13, multiverse.speed, league.season_number, mat_ij[5][1], mat_ij[5][4], mat_ij[6][1], mat_ij[6][4], loc_date + loc_interval_1_week * 2, TRUE, league.id),
(14, multiverse.speed, league.season_number, mat_ij[2][1], mat_ij[2][5], mat_ij[1][1], mat_ij[1][5], loc_date + loc_interval_1_week * 3, TRUE, league.id),
(14, multiverse.speed, league.season_number, mat_ij[4][1], mat_ij[4][5], mat_ij[3][1], mat_ij[3][5], loc_date + loc_interval_1_week * 3, TRUE, league.id),
(14, multiverse.speed, league.season_number, mat_ij[6][1], mat_ij[6][5], mat_ij[5][1], mat_ij[5][5], loc_date + loc_interval_1_week * 3, TRUE, league.id);
        

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------ Handle up and downs for this league
                -- Loop throught the list of clubs that should go up in this league
                loc_tmp_id := 1;
                FOR club IN
                    (SELECT * FROM clubs 
                    JOIN leagues ON clubs.id_league = leagues.id
                    WHERE leagues.id_upper_league = league.id
                    AND clubs.pos_league = 1
                    ORDER BY clubs.league_points DESC)
                LOOP
                    -- Handle 1st club going up
                    IF loc_tmp_id = 1 THEN
                        -- 1st club going up
                        UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 5
                            WHERE id = club.id;
                        -- 1st club going down (the one at 5th position)
                        UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
                            WHERE id = (SELECT id FROM clubs WHERE id_league = league.id AND pos_league = 5);
                    -- Handle 2nd club
                    ELSEIF loc_tmp_id = 2 THEN
                        -- 2nd club going up
                        UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 6
                            WHERE id = club.id;
                        -- 2nd club going down (the one at 6th position)
                        UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
                            WHERE id = (SELECT id FROM clubs WHERE id_league = league.id AND pos_league = 6);
                    ELSE
                        RAISE EXCEPTION 'ERROR when handling ups and downs for league with id: % ==> More than two clubs found to up', league.id;
                    END IF;

                    -- Update the position to the next club
                    loc_tmp_id := loc_tmp_id + 1;

                END LOOP;


            -- Generate new season for the league
            PERFORM generate_new_season(
                inp_date_season_start := multiverse.date_season_end,
                inp_m_speed := multiverse.speed,
                inp_season_number := multiverse.season_number + 1,
                inp_id_league := league.id
            );

            END LOOP; -- End of the loop through leagues

            -- Update multiverses table that next season is generated
            UPDATE multiverses SET 
                is_next_season_generated = TRUE
            WHERE speed = multiverse.speed;

        END IF;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ If the season is over
        IF now() > multiverse.date_season_end THEN
            bool_simulate_games := TRUE;

            -- Update multiverses table for starting next season
            UPDATE multiverses SET
                season_number = season_number + 1,
                date_season_start = date_season_end,
                date_league_end = date_season_end + loc_interval_1_week * 10,
                date_season_end = date_season_end + loc_interval_1_week * 14,
                is_next_season_generated = FALSE
                WHERE speed = multiverse.speed;

            -- Update leagues
            UPDATE leagues SET
                season_number = season_number + 1
                WHERE multiverse_speed = multiverse.speed;

            UPDATE clubs SET
                season_number = season_number + 1,
                id_league = id_league_next_season,
                id_league_next_season = NULL,
                pos_league = pos_league_next_season,
                pos_league_next_season = NULL,
                league_points = 0
                WHERE multiverse_speed = multiverse.speed;

        END IF;

    END LOOP;

    IF bool_simulate_games IS TRUE THEN
        PERFORM simulate_games();
    END IF;

END;
$function$
;
