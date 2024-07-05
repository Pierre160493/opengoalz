-- DROP FUNCTION public.generate_leagues_games_schedule(timestamptz, int8, int8, int8, _int8);

CREATE OR REPLACE FUNCTION public.generate_leagues_games_schedule(
    inp_date_season_end timestamp with time zone,
    inp_multiverse_speed bigint,
    inp_season_number bigint,
    inp_id_league bigint,
    inp_array_clubs_id bigint[])
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
    loc_date_interval INTERVAL; -- Date interval between games
    loc_date_season_start timestamp with time zone;
BEGIN

    -- Loop through the 6 clubs of the league
    FOR I IN 1..6 LOOP
        -- Loop through the 10 rounds of the season
        FOR J IN 1..12 LOOP
            -- Insert a new row for the club I for the week number J
            INSERT INTO games_teamcomp (id_club, week_number, season_number)
            VALUES (inp_array_clubs_id[I], J, inp_season_number)
            RETURNING id INTO loc_tmp_games_teamcomp_id;

            -- For the 10 league rounds
            IF J <= 10 THEN
                -- Store the id of the games_teamcomp in the 2D matrix
                loc_matrix_ids[I][J] := loc_tmp_games_teamcomp_id;
            END IF;
        END LOOP;
    END LOOP;

    -- Calculate the date interval for 1 week depending on the multiverse speed
    loc_date_interval := INTERVAL '1 hour' * 24 * 7 / inp_multiverse_speed; -- Number of hours of 1 week for this multiverse speed

    -- date start of the season
    loc_date_season_start := inp_date_season_end - 12 * loc_date_interval

    -- Start season before ! TO DELETE !
    loc_date_season_start := loc_date_season_start - (loc_date_interval * 7);

    -- Schedule games for week 1 and return games of week 10
    INSERT INTO games (week_number, multiverse_speed, season_number, id_left_teamcomp, id_right_teamcomp, date_start, is_league_game, id_league) VALUES
        -- Week 1
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][1], loc_matrix_ids[2][1], loc_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][1], loc_matrix_ids[3][1], loc_date_season_start, TRUE, inp_id_league),
        (1, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][1], loc_matrix_ids[6][1], loc_date_season_start, TRUE, inp_id_league),
        -- Week 2
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][2], loc_matrix_ids[1][2], loc_date_season_start + loc_date_interval, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][2], loc_matrix_ids[5][2], loc_date_season_start + loc_date_interval, TRUE, inp_id_league),
        (2, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][2], loc_matrix_ids[4][2], loc_date_season_start + loc_date_interval, TRUE, inp_id_league),
        -- Week 3
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][3], loc_matrix_ids[5][3], loc_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][3], loc_matrix_ids[6][3], loc_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        (3, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][3], loc_matrix_ids[2][3], loc_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        -- Week 4
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][4], loc_matrix_ids[1][4], loc_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][4], loc_matrix_ids[4][4], loc_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        (4, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][4], loc_matrix_ids[3][4], loc_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        -- Week 5
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][5], loc_matrix_ids[4][5], loc_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][5], loc_matrix_ids[2][5], loc_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        (5, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][5], loc_matrix_ids[5][5], loc_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        -- Week 6
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][6], loc_matrix_ids[1][6], loc_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][6], loc_matrix_ids[6][6], loc_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        (6, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][6], loc_matrix_ids[3][6], loc_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        -- Week 7
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][7], loc_matrix_ids[6][7], loc_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][7], loc_matrix_ids[5][7], loc_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        (7, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][7], loc_matrix_ids[2][7], loc_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        -- Week 8
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][8], loc_matrix_ids[1][8], loc_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][8], loc_matrix_ids[3][8], loc_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        (8, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][8], loc_matrix_ids[4][8], loc_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        -- Week 9
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[1][9], loc_matrix_ids[3][9], loc_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[5][9], loc_matrix_ids[2][9], loc_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        (9, inp_multiverse_speed, inp_season_number, loc_matrix_ids[4][9], loc_matrix_ids[6][9], loc_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        -- Week 10
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[2][10], loc_matrix_ids[1][10], loc_date_season_start + loc_date_interval * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[3][10], loc_matrix_ids[4][10], loc_date_season_start + loc_date_interval * 9, TRUE, inp_id_league),
        (10, inp_multiverse_speed, inp_season_number, loc_matrix_ids[6][10], loc_matrix_ids[5][10], loc_date_season_start + loc_date_interval * 9, TRUE, inp_id_league);
        
END;
$function$
;
