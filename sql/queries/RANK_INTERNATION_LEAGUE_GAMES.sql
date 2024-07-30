WITH filtered_games AS (
    SELECT id, week_number, id_club_left, score_left, id_club_right, score_right
    FROM games
    WHERE id_league = 1
    AND season_number = 1
    AND week_number IN (11, 12, 13)
    AND is_league IS TRUE
),
games_with_points_1 AS (
    SELECT id_club, SUM(points) as total_points, SUM(goals_for) - SUM(goals_against) AS goal_average, SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against
    FROM (
        SELECT id_club_left AS id_club,
            CASE
                WHEN score_left > score_right THEN 3
                WHEN score_left = score_right THEN 1
                ELSE 0
            END AS points,
            score_left AS goals_for,
            score_right AS goals_against
        FROM (
            SELECT id, id_club_left, score_left, id_club_right, score_right
            FROM (VALUES (11), (12), (13)) AS weeks(week_number)
            JOIN LATERAL (
                SELECT *
                FROM filtered_games
                WHERE week_number = weeks.week_number
                ORDER BY id
                LIMIT 1
            ) AS subquery ON TRUE
        ) AS subquery_left
        UNION ALL
        SELECT id_club_right AS id_club,
            CASE
                WHEN score_right > score_left THEN 3
                WHEN score_right = score_left THEN 1
                ELSE 0
            END AS points,
            score_right AS goals_for,
            score_left AS goals_against
        FROM (
            SELECT id, id_club_left, score_left, id_club_right, score_right
            FROM (VALUES (11), (12), (13)) AS weeks(week_number)
            JOIN LATERAL (
                SELECT *
                FROM filtered_games
                WHERE week_number = weeks.week_number
                ORDER BY id
                LIMIT 1
            ) AS subquery ON TRUE
        ) AS subquery_right
    ) AS subquery
    GROUP BY id_club
),
games_with_points_2 AS (
    SELECT id_club, SUM(points) as total_points, SUM(goals_for) - SUM(goals_against) AS goal_average, SUM(goals_for) AS goals_for, SUM(goals_against) AS goals_against
    FROM (
        SELECT id_club_left AS id_club,
            CASE
                WHEN score_left > score_right THEN 3
                WHEN score_left = score_right THEN 1
                ELSE 0
            END AS points,
            score_left AS goals_for,
            score_right AS goals_against
        FROM (
            SELECT id, id_club_left, score_left, id_club_right, score_right
            FROM (VALUES (11), (12), (13)) AS weeks(week_number)
            JOIN LATERAL (
                SELECT *
                FROM filtered_games
                WHERE week_number = weeks.week_number
                ORDER BY id DESC
                LIMIT 1
            ) AS subquery ON TRUE
        ) AS subquery_left
        UNION ALL
        SELECT id_club_right AS id_club,
            CASE
                WHEN score_right > score_left THEN 3
                WHEN score_right = score_left THEN 1
                ELSE 0
            END AS points,
            score_right AS goals_for,
            score_left AS goals_against
        FROM (
            SELECT id, id_club_left, score_left, id_club_right, score_right
            FROM (VALUES (11), (12), (13)) AS weeks(week_number)
            JOIN LATERAL (
                SELECT *
                FROM filtered_games
                WHERE week_number = weeks.week_number
                ORDER BY id DESC
                LIMIT 1
            ) AS subquery ON TRUE
        ) AS subquery_right
    ) AS subquery
    GROUP BY id_club
)
SELECT subquery2.* FROM (
SELECT id_club, total_points + CASE
    WHEN row_number = 1 THEN 10000
    WHEN row_number = 2 THEN 2000
    ELSE 300
END as total_points_final, total_points, goal_average, goals_for, goals_against, old_league_points
FROM (
    SELECT id_club, total_points, goal_average, goals_for, goals_against, clubs.league_points AS old_league_points,
    ROW_NUMBER() OVER (
        ORDER BY total_points DESC, goal_average DESC, goals_for DESC) as row_number
    FROM games_with_points_1
    JOIN clubs ON games_with_points_1.id_club = clubs.id)
AS ranked_clubs_1
UNION ALL
SELECT id_club, total_points + CASE
    WHEN row_number = 1 THEN 10000
    WHEN row_number = 2 THEN 2000
    ELSE 300
END as total_points_final, total_points, goal_average, goals_for, goals_against, old_league_points
FROM (
    SELECT id_club, total_points, goal_average, goals_for, goals_against, clubs.league_points AS old_league_points,
    ROW_NUMBER() OVER (
        ORDER BY total_points DESC, goal_average DESC, goals_for DESC) as row_number
    FROM games_with_points_2
    JOIN clubs ON games_with_points_2.id_club = clubs.id)
AS ranked_clubs_2) AS subquery2
ORDER BY total_points_final DESC, goal_average DESC, goals_for DESC, goals_against, old_league_points