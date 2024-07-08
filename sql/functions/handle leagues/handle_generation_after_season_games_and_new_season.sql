-- DROP FUNCTION public.generate_after_season_games_and_new_season(int8, timestamptz);

CREATE OR REPLACE FUNCTION public.handle_generation_after_season_games_and_new_season(
    inp_multiverse_speed bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record for the multiverses loop
    league RECORD; -- Record for the league loop
    club RECORD; -- Record for the club loop
    loc_matrix_ids bigint[6][5] :=ARRAY[
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL],
        [NULL,NULL,NULL,NULL,NULL]]; -- Array of ids of the games_teamcomp [1: Club ids, Other: Teamcomp ids for next 4 games]x[6 clubs]
    loc_tmp_id bigint;
    loc_tmp_id_clubs_up bigint[2]; -- Id of the clubs that goes up
BEGIN

    -- Loop through all multiverses
    FOR multiverse IN (SELECT * FROM multiverses) LOOP

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ If the league is over and the next season is not generated yet
        IF now() > multiverse.date_league_end AND multiverse.is_next_season_generated IS FALSE THEN

            -- Loop through all leagues
            FOR league IN (SELECT * FROM leagues WHERE multiverse_speed = inp_multiverse_speed ORDER BY level) LOOP

                -- Loop through all clubs in the league ordered by position
                FOR club IN
                    (SELECT * FROM clubs 
                    WHERE id_league = league.id
                    ORDER BY pos_league)
                LOOP

                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------ Start handling final positions in league and next season league (default values, will be overwritten later for the ups and downs)
                    UPDATE clubs SET pos_league_next_season = club.pos_league, id_league_next_season = club.id_league
                        WHERE id = club.id;

                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------------------------------------------------------------------------------------------------------------------------------------------
                    ------------ Handle next season games
                    -- Insert the id of the club in the matrix for storing in games table
                    loc_matrix_ids[club.pos_league][1] := club.id;

                    -- Loop through the 4 final weeks of the season
                    FOR J IN 1..4 LOOP 

                        -- Select the id of the row of the teamcomp for the club I for the week number J
                        SELECT id INTO loc_tmp_id FROM games_teamcomp 
                        WHERE id_club = club.id AND week_number = J AND season_number = league.season_number;

                        -- If not found insert it
                        --IF loc_tmp_id IS NULL THEN
                        --    -- Insert a new row for the club I for the week number J if it doesn't already exist
                        --    INSERT INTO games_teamcomp (id_club, week_number, season_number)
                        --    VALUES (club.id, J, league.season_number)
                        --    RETURNING id INTO loc_tmp_id;
                        --END IF;

                        -- Insert the id of the games_teamcomp in the matrix for storing in games table
                        loc_matrix_ids[club.pos_league][J + 1] := loc_tmp_id;

                    END LOOP; -- End of the loop through weeks

                END LOOP; -- End of the loop through clubs

                -- Generate the games for the last 4 weeks of the season
                INSERT INTO games (week_number, multiverse_speed, season_number, id_club_left, id_teamcomp_left, id_club_right, id_teamcomp_right, date_start, is_cup, id_league) VALUES
                    (11, inp_multiverse_speed, league.season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][2], loc_matrix_ids[2][1], loc_matrix_ids[2][2], inp_date_start, TRUE, league.id),
                    (11, inp_multiverse_speed, league.season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][2], loc_matrix_ids[4][1], loc_matrix_ids[4][2], inp_date_start, TRUE, league.id),
                    (11, inp_multiverse_speed, league.season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][2], loc_matrix_ids[6][1], loc_matrix_ids[6][2], inp_date_start, TRUE, league.id),
                    (12, inp_multiverse_speed, league.season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][3], loc_matrix_ids[2][1], loc_matrix_ids[2][3], inp_date_start, TRUE, league.id),
                    (12, inp_multiverse_speed, league.season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][3], loc_matrix_ids[4][1], loc_matrix_ids[4][3], inp_date_start, TRUE, league.id),
                    (12, inp_multiverse_speed, league.season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][3], loc_matrix_ids[6][1], loc_matrix_ids[6][3], inp_date_start, TRUE, league.id),
                    (13, inp_multiverse_speed, league.season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][4], loc_matrix_ids[2][1], loc_matrix_ids[2][4], inp_date_start, TRUE, league.id),
                    (13, inp_multiverse_speed, league.season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][4], loc_matrix_ids[4][1], loc_matrix_ids[4][4], inp_date_start, TRUE, league.id),
                    (13, inp_multiverse_speed, league.season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][4], loc_matrix_ids[6][1], loc_matrix_ids[6][4], inp_date_start, TRUE, league.id),
                    (14, inp_multiverse_speed, league.season_number, loc_matrix_ids[1][1], loc_matrix_ids[1][5], loc_matrix_ids[2][1], loc_matrix_ids[2][5], inp_date_start, TRUE, league.id),
                    (14, inp_multiverse_speed, league.season_number, loc_matrix_ids[3][1], loc_matrix_ids[3][5], loc_matrix_ids[4][1], loc_matrix_ids[4][5], inp_date_start, TRUE, league.id),
                    (14, inp_multiverse_speed, league.season_number, loc_matrix_ids[5][1], loc_matrix_ids[5][5], loc_matrix_ids[6][1], loc_matrix_ids[6][5], inp_date_start, TRUE, league.id);
        
            -- Handle ups and downs
RAISE NOTICE 'testPG: league.id = %', league.id;

                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------------------------------------------------------------------------------------------------------------------------------------------
                ------------ Handle up and downs for this league
                -- Loop throught the list of clubs that should go up in this league
                loc_number := 1;
                FOR club IN
                    (SELECT * FROM clubs 
                    JOIN leagues ON clubs.id_league = leagues.id
                    WHERE leagues.id_upper_league = league.id
                    AND leagues.pos_league = 1
                    ORDER BY clubs.league_points DESC)
                LOOP

                    -- Handle 1st club going up
                    IF loc_number == 1 THEN
                        UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 5
                            WHERE id = club.id;
                        UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
                            WHERE id = (SELECT id FROM clubs WHERE id_league = club.id_league AND pos_league = 5);
                    -- Handle 2ns club
                    ELSE IF loc_number == 2 THEN
                        UPDATE clubs SET id_league_next_season = league.id, pos_league_next_season = 6
                            WHERE id = club.id;
                        UPDATE clubs SET id_league_next_season = club.id_league, pos_league_next_season = 1
                            WHERE id = (SELECT id FROM clubs WHERE id_league = club.id_league AND pos_league = 6);
                    ELSE
                        RAISE EXCEPTION 'ERROR when handling ups and downs for league with id: % ==> More than two clubs found to up', league.id;
                    END IF;

                    -- Update the position to the next club
                    loc_number := loc_number + 1;

                END LOOP;


            -- Generate new season for the league
            PERFORM generate_new_season(
                inp_date_season_start := (multiverse.date_league_end + (INTERVAL '7 days' / multiverse.speed) * 4),
                inp_multiverse_speed := multiverse.speed,
                inp_season_number := multiverse.season_number + 1,
                inp_id_league := league.id
            );

            END LOOP; -- End of the loop through leagues

            -- Update multiverses table that next season is generated
            UPDATE multiverse SET 
                is_next_season_generated = TRUE
            WHERE multiverse_speed = multiverse.speed;

        END IF;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------------------------------
        ------------ If the season is over
        IF now() > multiverse.date_league_end AND multiverse.is_next_season_generated IS FALSE THEN

            -- Update multiverses table for starting next season
            UPDATE multiverse SET
                season_number = season_number + 1,
                date_league_end = date_league_end + (INTERVAL '7 days' / multiverse.speed) * 14,
                is_next_season_generated = FALSE
                WHERE multiverse_speed = multiverse.speed;

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

END;
$function$
;
