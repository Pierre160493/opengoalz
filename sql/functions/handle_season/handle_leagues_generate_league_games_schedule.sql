-- DROP FUNCTION public.generate_leagues_games_schedule(timestamptz, int8, int8, int8, _int8);

CREATE OR REPLACE FUNCTION public.generate_leagues_games_schedule(inp_date_season_start timestamp with time zone, inp_multiverse_speed bigint, inp_season_number bigint, inp_id_league bigint, inp_array_clubs_id bigint[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_tmp_games_teamcomp_id bigint; -- Temporary variable to store the id of the games_teamcomp 
    loc_matrix_ids bigint[6][10] :=ARRAY[
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL],
[NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp
    loc_interval_1_week INTERVAL; -- Date interval between games
BEGIN

    -- Loop through the 6 clubs of the league
    FOR I IN 1..6 LOOP
        -- Loop through the 10 rounds of the season
        FOR J IN 1..12 LOOP

            -- Select the id of the row of the teamcomp for the club I for the week number J
            SELECT id INTO loc_tmp_games_teamcomp_id FROM games_teamcomp 
            WHERE id_club = inp_array_clubs_id[I] AND week_number = J AND season_number = inp_season_number;

            -- If not found insert it
            IF loc_tmp_games_teamcomp_id IS NULL THEN
                -- Insert a new row for the club I for the week number J if it doesn't already exist
                INSERT INTO games_teamcomp (id_club, week_number, season_number)
                VALUES (inp_array_clubs_id[I], J, inp_season_number)
                RETURNING id INTO loc_tmp_games_teamcomp_id;
            END IF;

            -- For the 10 league rounds
            IF J <= 10 THEN
                -- Store the id of the games_teamcomp in the 2D matrix
                loc_matrix_ids[I][J] := loc_tmp_games_teamcomp_id;
            END IF;
        END LOOP;
    END LOOP;

    -- Calculate the date interval for 1 week depending on the multiverse speed
    loc_interval_1_week := INTERVAL '1 hour' * 24 * 7 / inp_multiverse_speed; -- Number of hours of 1 week for this multiverse speed

    -- Start season before ! TO DELETE !
    inp_date_season_start := inp_date_season_start - (loc_interval_1_week * 7);

    -- Schedule games for week 1 and return games of week 10
    INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_league_game, id_league) VALUES
        -- Week 1
        (1, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[1], loc_matrix_ids[1][1], inp_array_clubs_id[2], loc_matrix_ids[2][1], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[4], loc_matrix_ids[4][1], inp_array_clubs_id[3], loc_matrix_ids[3][1], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[5], loc_matrix_ids[5][1], inp_array_clubs_id[6], loc_matrix_ids[6][1], inp_date_season_start, TRUE, inp_id_league),
        -- Week 2
        (2, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[3], loc_matrix_ids[3][2], inp_array_clubs_id[1], loc_matrix_ids[1][2], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[2], loc_matrix_ids[2][2], inp_array_clubs_id[5], loc_matrix_ids[5][2], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[6], loc_matrix_ids[6][2], inp_array_clubs_id[4], loc_matrix_ids[4][2], inp_date_season_start + loc_interval_1_week, TRUE, inp_id_league),
        -- Week 3
        (3, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[1], loc_matrix_ids[1][3], inp_array_clubs_id[5], loc_matrix_ids[5][3], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[3], loc_matrix_ids[3][3], inp_array_clubs_id[6], loc_matrix_ids[6][3], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[4], loc_matrix_ids[4][3], inp_array_clubs_id[2], loc_matrix_ids[2][3], inp_date_season_start + loc_interval_1_week * 2, TRUE, inp_id_league),
        -- Week 4
        (4, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[6], loc_matrix_ids[6][4], inp_array_clubs_id[1], loc_matrix_ids[1][4], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[5], loc_matrix_ids[5][4], inp_array_clubs_id[4], loc_matrix_ids[4][4], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[2], loc_matrix_ids[2][4], inp_array_clubs_id[3], loc_matrix_ids[3][4], inp_date_season_start + loc_interval_1_week * 3, TRUE, inp_id_league),
        -- Week 5
        (5, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[1], loc_matrix_ids[1][5], inp_array_clubs_id[4], loc_matrix_ids[4][5], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[6], loc_matrix_ids[6][5], inp_array_clubs_id[2], loc_matrix_ids[2][5], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[3], loc_matrix_ids[3][5], inp_array_clubs_id[5], loc_matrix_ids[5][5], inp_date_season_start + loc_interval_1_week * 4, TRUE, inp_id_league),
        -- Week 6
        (6, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[4], loc_matrix_ids[4][6], inp_array_clubs_id[1], loc_matrix_ids[1][6], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[2], loc_matrix_ids[2][6], inp_array_clubs_id[6], loc_matrix_ids[6][6], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[5], loc_matrix_ids[5][6], inp_array_clubs_id[3], loc_matrix_ids[3][6], inp_date_season_start + loc_interval_1_week * 5, TRUE, inp_id_league),
        -- Week 7
        (7, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[1], loc_matrix_ids[1][7], inp_array_clubs_id[6], loc_matrix_ids[6][7], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[4], loc_matrix_ids[4][7], inp_array_clubs_id[5], loc_matrix_ids[5][7], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[3], loc_matrix_ids[3][7], inp_array_clubs_id[2], loc_matrix_ids[2][7], inp_date_season_start + loc_interval_1_week * 6, TRUE, inp_id_league),
        -- Week 8
        (8, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[5], loc_matrix_ids[5][8], inp_array_clubs_id[1], loc_matrix_ids[1][8], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[6], loc_matrix_ids[6][8], inp_array_clubs_id[3], loc_matrix_ids[3][8], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[2], loc_matrix_ids[2][8], inp_array_clubs_id[4], loc_matrix_ids[4][8], inp_date_season_start + loc_interval_1_week * 7, TRUE, inp_id_league),
        -- Week 9
        (9, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[1], loc_matrix_ids[1][9], inp_array_clubs_id[3], loc_matrix_ids[3][9], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[5], loc_matrix_ids[5][9], inp_array_clubs_id[2], loc_matrix_ids[2][9], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[4], loc_matrix_ids[4][9], inp_array_clubs_id[6], loc_matrix_ids[6][9], inp_date_season_start + loc_interval_1_week * 8, TRUE, inp_id_league),
        -- Week 10
        (10, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[2], loc_matrix_ids[2][10], inp_array_clubs_id[1], loc_matrix_ids[1][10], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[3], loc_matrix_ids[3][10], inp_array_clubs_id[4], loc_matrix_ids[4][10], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, inp_array_clubs_id[6], loc_matrix_ids[6][10], inp_array_clubs_id[5], loc_matrix_ids[5][10], inp_date_season_start + loc_interval_1_week * 9, TRUE, inp_id_league);
        

    ------ Handle next season teamcomps
    -- Loop through the 6 clubs of the league
    FOR I IN 1..6 LOOP
        -- Loop through the 10 rounds of the season
        FOR J IN 1..12 LOOP

            -- Select the id of the row of the teamcomp for the club I for the week number J
            SELECT id INTO loc_tmp_games_teamcomp_id FROM games_teamcomp 
            WHERE id_club = inp_array_clubs_id[I] AND week_number = J AND season_number = inp_season_number + 1;

            -- If not found insert it
            IF loc_tmp_games_teamcomp_id IS NULL THEN
                -- Insert a new row for the club I for the week number J if it doesn't already exist
                INSERT INTO games_teamcomp (id_club, week_number, season_number)
                VALUES (inp_array_clubs_id[I], J, inp_season_number + 1)
                RETURNING id INTO loc_tmp_games_teamcomp_id;
            END IF;
        END LOOP;
    END LOOP;
END;
$function$
;
