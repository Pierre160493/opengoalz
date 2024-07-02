-- DROP FUNCTION public.generate_leagues_games_schedule(timestamptz, int8, int8, _int8);

CREATE OR REPLACE FUNCTION public.generate_leagues_games_schedule(
    inp_date_season_start timestamp with time zone,
    inp_multiverse_speed bigint,
    inp_id_league bigint,
    inp_array_clubs_id bigint[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_date_interval INTERVAL; -- Date interval between games
BEGIN

--RAISE NOTICE '%', inp_array_clubs_id;
    
    loc_date_interval := INTERVAL '1 hour' * 24 * 7 / inp_multiverse_speed; -- Number of hours of 1 week for this multiverse speed
    inp_date_season_start := inp_date_season_start - (loc_date_interval * 7);

    -- Schedule games for week 1 and return games of week 10
    INSERT INTO games (week_number, id_club_left, id_club_right, date_start, is_league_game, id_league) VALUES
        -- Week 1
        (1, inp_array_clubs_id[1], inp_array_clubs_id[2], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_array_clubs_id[4], inp_array_clubs_id[3], inp_date_season_start, TRUE, inp_id_league),
        (1, inp_array_clubs_id[5], inp_array_clubs_id[6], inp_date_season_start, TRUE, inp_id_league),
        -- Week 2
        (2, inp_array_clubs_id[3], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval, TRUE, inp_id_league),
        (2, inp_array_clubs_id[2], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval, TRUE, inp_id_league),
        (2, inp_array_clubs_id[6], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval, TRUE, inp_id_league),
        -- Week 3
        (3, inp_array_clubs_id[1], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        (3, inp_array_clubs_id[3], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        (3, inp_array_clubs_id[4], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 2, TRUE, inp_id_league),
        -- Week 4
        (4, inp_array_clubs_id[6], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        (4, inp_array_clubs_id[5], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        (4, inp_array_clubs_id[2], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 3, TRUE, inp_id_league),
        -- Week 5
        (5, inp_array_clubs_id[1], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        (5, inp_array_clubs_id[6], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        (5, inp_array_clubs_id[3], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 4, TRUE, inp_id_league),
        -- Week 6
        (6, inp_array_clubs_id[4], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        (6, inp_array_clubs_id[2], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        (6, inp_array_clubs_id[5], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 5, TRUE, inp_id_league),
        -- Week 7
        (7, inp_array_clubs_id[1], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        (7, inp_array_clubs_id[4], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        (7, inp_array_clubs_id[3], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 6, TRUE, inp_id_league),
        -- Week 8
        (8, inp_array_clubs_id[5], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        (8, inp_array_clubs_id[6], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        (8, inp_array_clubs_id[2], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 7, TRUE, inp_id_league),
        -- Week 9
        (9, inp_array_clubs_id[1], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        (9, inp_array_clubs_id[5], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        (9, inp_array_clubs_id[4], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 8, TRUE, inp_id_league),
        -- Week 10
        (10, inp_array_clubs_id[2], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 9, TRUE, inp_id_league),
        (10, inp_array_clubs_id[3], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 9, TRUE, inp_id_league),
        (10, inp_array_clubs_id[6], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 9, TRUE, inp_id_league);
        
END;
$function$
;
