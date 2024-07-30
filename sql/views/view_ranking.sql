-- public.view_ranking source

CREATE OR REPLACE VIEW public.view_ranking
AS SELECT subquery.id_club,
    subquery.name_club,
    subquery.id_user,
    sum(subquery.n_victories * 3 + subquery.n_draws) AS n_points,
    sum(
        CASE
            WHEN subquery.result = 'Victory'::text THEN 1
            ELSE 0
        END) AS n_victories,
    sum(
        CASE
            WHEN subquery.result = 'Draw'::text THEN 1
            ELSE 0
        END) AS n_draws,
    sum(
        CASE
            WHEN subquery.result = 'Defeat'::text THEN 1
            ELSE 0
        END) AS n_defeats,
    sum(subquery.goal_average) AS total_goal_average,
    sum(
        CASE
            WHEN subquery.id_club_left = subquery.id_club THEN subquery.goals_left
            ELSE subquery.goals_right
        END) AS goals_scored,
    sum(
        CASE
            WHEN subquery.id_club_left = subquery.id_club THEN subquery.goals_right
            ELSE subquery.goals_left
        END) AS goals_taken,
    subquery.id_league
   FROM ( SELECT view_games.id_club,
            view_games.name_club,
            view_games.id_user,
            view_games.goal_average,
            view_games.result,
            view_games.id_club_left,
            view_games.id_club_right,
            view_games.goals_left,
            view_games.goals_right,
            sum(
                CASE
                    WHEN view_games.result = 'Victory'::text THEN 1
                    ELSE 0
                END) AS n_victories,
            sum(
                CASE
                    WHEN view_games.result = 'Draw'::text THEN 1
                    ELSE 0
                END) AS n_draws,
            view_games.id_league
           FROM view_games
          WHERE view_games.is_league_game AND view_games.is_played
          GROUP BY view_games.id_club, view_games.name_club, view_games.id_user, view_games.goal_average, view_games.result, view_games.id_club_left, view_games.id_club_right, view_games.goals_left, view_games.goals_right, view_games.id_league) subquery
  GROUP BY subquery.id_club, subquery.name_club, subquery.id_user, subquery.id_league
  ORDER BY (sum(subquery.n_victories * 3 + subquery.n_draws)) DESC, (sum(subquery.goal_average)) DESC;