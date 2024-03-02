-- DROP FUNCTION public.generate_league_games(int4);

CREATE OR REPLACE FUNCTION public.generate_league_games(inp_id_league integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    num_teams INTEGER; -- Number of teams in the league
BEGIN
    ------------ Checks
    ------ Check if the league exists
    IF NOT EXISTS (SELECT 1 FROM leagues WHERE id = inp_id_league) THEN
        RAISE EXCEPTION 'League with id % does not exist', inp_id_league;
    END IF;

    ------ Check the number of teams in the league
    SELECT COUNT(*) INTO num_teams FROM clubs WHERE id_league = inp_id_league;
    IF num_teams <> 8 THEN 
        RAISE EXCEPTION 'The number of teams in the league must be 8, found: %', num_teams;
    END IF;

    ------------ Initialization    

    ------------ Processing
    INSERT INTO games (id_club_left, id_club_right, week_number, date_start, is_league_game)
    SELECT
        full_games_schedule.id_club_left,
        full_games_schedule.id_club_right,
        full_games_schedule.week_number,
        full_games_schedule.date_game,
        TRUE
    FROM (
        SELECT
            games_schedule.week_number,
            club_left.id AS id_club_left,
            club_right.id AS id_club_right,
            --date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * games_schedule.week_number AS date_game
            date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (games_schedule.week_number - 12) AS date_game
        FROM games_schedule
        LEFT JOIN (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
            FROM clubs
            WHERE id_league = 1
        ) club_left ON games_schedule.club_left = club_left.row_number
        LEFT JOIN (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
            FROM clubs
            WHERE id_league = 1
        ) club_right ON games_schedule.club_right = club_right.row_number
        UNION ALL
        SELECT
            15 - games_schedule.week_number AS week_number,
            club_left.id AS id_club_left,
            club_right.id AS id_club_right,
            --date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (15 - games_schedule.week_number) AS date_game
            date_trunc('week', current_date) + INTERVAL '5 days 21 hours' + INTERVAL '7 days' * (15 - games_schedule.week_number - 12) AS date_game
        FROM games_schedule
        LEFT JOIN (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
            FROM clubs
            WHERE id_league = 1
        ) club_left ON games_schedule.club_left = club_left.row_number
        LEFT JOIN (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS row_number
            FROM clubs
            WHERE id_league = 1
        ) club_right ON games_schedule.club_right = club_right.row_number
    ) AS full_games_schedule;

END;
$function$
;

