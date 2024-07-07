-- DROP FUNCTION public.generate_new_season();

CREATE OR REPLACE FUNCTION public.generate_after_season_games_and_new_season(
    inp_multiverse_speed integer,
    inp_date_season_start timestampz
)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    league RECORD; -- Record of the leagues
    lower_leagues RECORD; -- Record of the lower leagues
    loc_index integer; -- Record of the clubs
    loc_array_id_club integer[NULL,NULL,NULL,NULL,NULL,NULL]; -- Array of the clubs id
    loc_matrix_ids bigint[6][4] :=ARRAY[
        [NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp
    loc_tmp_id_club_up1 bigint; -- Id of the first club that goes up
    loc_tmp_id_club_up2 bigint; -- Id of the second club that goes up
    loc_tmp_id_club_relegate1 bigint; -- Id of the first club that goes down
    loc_tmp_id_club_relegate2 bigint; -- Id of the second club that goes down
BEGIN

    FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = inp_multiverse_speed ORDER BY level) LOOP

        -- Loop through all clubs in the league
        loc_index := 1;
        FOR I IN
            (SELECT id FROM clubs 
            WHERE id_league = league.id
            ORDER BY pos_league)
        LOOP

            loc_array_id_club[loc_index] := I;

            -- Loop through the 4 final weeks of the season
            FOR J IN 1..4 LOOP 

                -- Select the id of the row of the teamcomp for the club I for the week number J
                SELECT id INTO loc_tmp_id FROM games_teamcomp 
                WHERE id_club = loc_array_clubs_id[I] AND week_number = J AND season_number = league.season_number;

                -- If not found insert it
                IF loc_tmp_id IS NULL THEN
                    -- Insert a new row for the club I for the week number J if it doesn't already exist
                    INSERT INTO games_teamcomp (id_club, week_number, season_number)
                    VALUES (loc_array_clubs_id[I], J, league.season_number)
                    RETURNING id INTO loc_tmp_id;
                END IF;

                -- Insert the id of the games_teamcomp in the matrix for storing in games table
                loc_matrix_ids[I][J] := loc_tmp_id;

            END LOOP; -- End of the loop through weeks

            loc_index := loc_index + 1;
        END LOOP; -- End of the loop through clubs

        -- Generate the games for the last 4 weeks of the season
        INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
            (11, inp_multiverse_speed, league.season_number, loc_array_clubs_id[1], loc_matrix_ids[1][1], loc_array_clubs_id[2], loc_matrix_ids[2][1], inp_date_season_start, TRUE, leagues.id),
            (11, inp_multiverse_speed, league.season_number, loc_array_clubs_id[3], loc_matrix_ids[3][1], loc_array_clubs_id[4], loc_matrix_ids[4][1], inp_date_season_start, TRUE, leagues.id),
            (11, inp_multiverse_speed, league.season_number, loc_array_clubs_id[5], loc_matrix_ids[5][1], loc_array_clubs_id[6], loc_matrix_ids[6][1], inp_date_season_start, TRUE, leagues.id),
            (12, inp_multiverse_speed, league.season_number, loc_array_clubs_id[1], loc_matrix_ids[1][2], loc_array_clubs_id[2], loc_matrix_ids[2][2], inp_date_season_start, TRUE, leagues.id),
            (12, inp_multiverse_speed, league.season_number, loc_array_clubs_id[3], loc_matrix_ids[3][2], loc_array_clubs_id[4], loc_matrix_ids[4][2], inp_date_season_start, TRUE, leagues.id),
            (12, inp_multiverse_speed, league.season_number, loc_array_clubs_id[5], loc_matrix_ids[5][2], loc_array_clubs_id[6], loc_matrix_ids[6][2], inp_date_season_start, TRUE, leagues.id),
            (13, inp_multiverse_speed, league.season_number, loc_array_clubs_id[1], loc_matrix_ids[1][3], loc_array_clubs_id[2], loc_matrix_ids[2][3], inp_date_season_start, TRUE, leagues.id),
            (13, inp_multiverse_speed, league.season_number, loc_array_clubs_id[3], loc_matrix_ids[3][3], loc_array_clubs_id[4], loc_matrix_ids[4][3], inp_date_season_start, TRUE, leagues.id),
            (13, inp_multiverse_speed, league.season_number, loc_array_clubs_id[5], loc_matrix_ids[5][3], loc_array_clubs_id[6], loc_matrix_ids[6][3], inp_date_season_start, TRUE, leagues.id),
            (14, inp_multiverse_speed, league.season_number, loc_array_clubs_id[1], loc_matrix_ids[1][4], loc_array_clubs_id[2], loc_matrix_ids[2][4], inp_date_season_start, TRUE, leagues.id),
            (14, inp_multiverse_speed, league.season_number, loc_array_clubs_id[3], loc_matrix_ids[3][4], loc_array_clubs_id[4], loc_matrix_ids[4][4], inp_date_season_start, TRUE, leagues.id),
            (14, inp_multiverse_speed, league.season_number, loc_array_clubs_id[5], loc_matrix_ids[5][4], loc_array_clubs_id[6], loc_matrix_ids[6][4], inp_date_season_start, TRUE, leagues.id);
    
    END LOOP; -- End of the loop through leagues

    -- Handle ups and downs for clubs
    FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = inp_multiverse_speed ORDER BY level) LOOP

        -- -- Relegate the 2 last clubs of the league
        -- SELECT id INTO loc_tmp_id_club_relegate1 FROM clubs WHERE id_league = league.id AND pos_league = 5;
        -- SELECT id INTO loc_tmp_id_club_relegate2 FROM clubs WHERE id_league = league.id AND pos_league = 6;

        -- -- Select the 2 clubs that should go up
        -- SELECT id INTO loc_tmp_id_club_up1 FROM (
        --     SELECT id FROM clubs WHERE id_league IN (
        --         SELECT id FROM leagues WHERE id_upper_league = league.id
        --     ) AND pos_league = 1
        --     ORDER BY id
        --     LIMIT 2
        -- ) AS subquery
        -- ORDER BY id
        -- LIMIT 1;
        -- SELECT id INTO loc_tmp_id_club_up2 FROM (
        --     SELECT id FROM clubs WHERE id_league IN (
        --         SELECT id FROM leagues WHERE id_upper_league = league.id
        --     ) AND pos_league = 1
        --     ORDER BY id
        --     LIMIT 2
        -- ) AS subquery
        -- ORDER BY id DESC
        -- LIMIT 1;

        -- Generate new season for the league
        PERFORM generate_leagues_games_schedule(
            inp_date_season_start := multiverse.date_season_start,
            inp_multiverse_speed := inp_multiverse_speed,
            inp_id_league := leagues.id,
            loc_array_clubs_id := ARRAY(
                SELECT id FROM clubs WHERE id_league = leagues.id
            )
        );

    END LOOP;

END;
$function$
;
