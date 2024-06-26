CREATE OR REPLACE FUNCTION generate_leagues_games_schedule(
    inp_date_season_start DATE, -- Start date of the season
    inp_multiverse_speed INT8, -- Speed of the multiverse
    inp_array_clubs_id INT8[6] -- Array of club ids
)
RETURNS void AS $$
DECLARE
    loc_date_interval DATE -- Date interval between games
BEGIN

    loc_date_interval := INTERVAL '1 hour' * 168 / inp_multiverse_speed -- Number of hours of 1 week for this multiverse speed

    -- Schedule games for week 1 and return games of week 10
    INSERT INTO games (week_number, id_club_left, id_club_right, date_start, is_league_game) VALUES
        -- Week 1
        (1, inp_array_clubs_id[1], inp_array_clubs_id[2], inp_date_season_start, TRUE),
        (1, inp_array_clubs_id[4], inp_array_clubs_id[3], inp_date_season_start, TRUE),
        (1, inp_array_clubs_id[5], inp_array_clubs_id[6], inp_date_season_start, TRUE),
        -- Week 2
        (2, inp_array_clubs_id[3], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval, TRUE),
        (2, inp_array_clubs_id[2], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval, TRUE),
        (2, inp_array_clubs_id[6], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval, TRUE),
        -- Week 3
        (3, inp_array_clubs_id[1], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 2, TRUE),
        (3, inp_array_clubs_id[3], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 2, TRUE),
        (3, inp_array_clubs_id[4], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 2, TRUE),
        -- Week 4
        (4, inp_array_clubs_id[6], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 3, TRUE),
        (4, inp_array_clubs_id[5], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 3, TRUE),
        (4, inp_array_clubs_id[2], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 3, TRUE),
        -- Week 5
        (5, inp_array_clubs_id[1], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 4, TRUE),
        (5, inp_array_clubs_id[6], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 4, TRUE),
        (5, inp_array_clubs_id[3], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 4, TRUE),
        -- Week 6
        (6, inp_array_clubs_id[4], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 5, TRUE),
        (6, inp_array_clubs_id[2], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 5, TRUE),
        (6, inp_array_clubs_id[5], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 5, TRUE),
        -- Week 7
        (7, inp_array_clubs_id[1], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 6, TRUE),
        (7, inp_array_clubs_id[4], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 6, TRUE),
        (7, inp_array_clubs_id[3], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 6, TRUE),
        -- Week 8
        (8, inp_array_clubs_id[5], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 7, TRUE),
        (8, inp_array_clubs_id[6], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 7, TRUE),
        (8, inp_array_clubs_id[2], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 7, TRUE),
        -- Week 9
        (9, inp_array_clubs_id[1], inp_array_clubs_id[3], inp_date_season_start + loc_date_interval * 8, TRUE),
        (9, inp_array_clubs_id[5], inp_array_clubs_id[2], inp_date_season_start + loc_date_interval * 8, TRUE),
        (9, inp_array_clubs_id[4], inp_array_clubs_id[6], inp_date_season_start + loc_date_interval * 8, TRUE),
        -- Week 10
        (10, inp_array_clubs_id[2], inp_array_clubs_id[1], inp_date_season_start + loc_date_interval * 9, TRUE),
        (10, inp_array_clubs_id[3], inp_array_clubs_id[4], inp_date_season_start + loc_date_interval * 9, TRUE),
        (10, inp_array_clubs_id[6], inp_array_clubs_id[5], inp_date_season_start + loc_date_interval * 9, TRUE);
        
END;
$$ LANGUAGE plpgsql;
