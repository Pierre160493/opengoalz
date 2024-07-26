-- public.view_games source

CREATE OR REPLACE VIEW public.view_games
AS SELECT subquery_left.id,
    subquery_left.date_start,
    subquery_left.week_number,
    subquery_left.id_club,
    subquery_left.name_club,
    subquery_left.id_user,
    subquery_left.id_club_left,
    subquery_left.name_club_left,
    subquery_left.id_user_club_left,
    subquery_left.username_club_left,
    subquery_left.id_club_right,
    subquery_left.name_club_right,
    subquery_left.id_user_club_right,
    subquery_left.username_club_right,
    subquery_left.id_stadium,
    subquery_left.is_played,
    subquery_left.is_league_game,
    subquery_left.is_cup,
    subquery_left.is_friendly,
    subquery_left.goals_left,
    subquery_left.goals_right,
        CASE
            WHEN subquery_left.goals_left > subquery_left.goals_right THEN 'Victory'::text
            WHEN subquery_left.goals_left = subquery_left.goals_right THEN 'Draw'::text
            WHEN subquery_left.goals_left < subquery_left.goals_right THEN 'Defeat'::text
            ELSE NULL::text
        END AS result,
    subquery_left.goals_left - subquery_left.goals_right AS goal_average,
    subquery_left.id_league
   FROM ( SELECT view_games_details.id,
            view_games_details.date_start,
            view_games_details.week_number,
            view_games_details.id_club_left AS id_club,
            view_games_details.name_club_left AS name_club,
            view_games_details.id_user_club_left AS id_user,
            view_games_details.id_club_left,
            view_games_details.name_club_left,
            view_games_details.id_user_club_left,
            view_games_details.username_club_left,
            view_games_details.id_club_right,
            view_games_details.name_club_right,
            view_games_details.id_user_club_right,
            view_games_details.username_club_right,
            view_games_details.id_stadium,
            view_games_details.is_played,
            view_games_details.is_league_game,
            view_games_details.is_cup,
            view_games_details.is_friendly,
            sum(
                CASE
                    WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_left THEN 1
                    ELSE 0
                END) AS goals_left,
            sum(
                CASE
                    WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_right THEN 1
                    ELSE 0
                END) AS goals_right,
            view_games_details.id_league
           FROM view_games_details
          GROUP BY view_games_details.id, view_games_details.date_start, view_games_details.week_number, view_games_details.id_club_left, view_games_details.name_club_left, view_games_details.id_user_club_left, view_games_details.username_club_left, view_games_details.id_club_right, view_games_details.name_club_right, view_games_details.id_user_club_right, view_games_details.username_club_right, view_games_details.id_stadium, view_games_details.is_played, view_games_details.is_league_game, view_games_details.is_cup, view_games_details.is_friendly, view_games_details.id_league) subquery_left
UNION ALL
 SELECT subquery_right.id,
    subquery_right.date_start,
    subquery_right.week_number,
    subquery_right.id_club,
    subquery_right.name_club,
    subquery_right.id_user,
    subquery_right.id_club_left,
    subquery_right.name_club_left,
    subquery_right.id_user_club_left,
    subquery_right.username_club_left,
    subquery_right.id_club_right,
    subquery_right.name_club_right,
    subquery_right.id_user_club_right,
    subquery_right.username_club_right,
    subquery_right.id_stadium,
    subquery_right.is_played,
    subquery_right.is_league_game,
    subquery_right.is_cup,
    subquery_right.is_friendly,
    subquery_right.goals_left,
    subquery_right.goals_right,
        CASE
            WHEN subquery_right.goals_left < subquery_right.goals_right THEN 'Victory'::text
            WHEN subquery_right.goals_left = subquery_right.goals_right THEN 'Draw'::text
            WHEN subquery_right.goals_left > subquery_right.goals_right THEN 'Defeat'::text
            ELSE NULL::text
        END AS result,
    subquery_right.goals_right - subquery_right.goals_left AS goal_average,
    subquery_right.id_league
   FROM ( SELECT view_games_details.id,
            view_games_details.date_start,
            view_games_details.week_number,
            view_games_details.id_club_right AS id_club,
            view_games_details.name_club_right AS name_club,
            view_games_details.id_user_club_right AS id_user,
            view_games_details.id_club_left,
            view_games_details.name_club_left,
            view_games_details.id_user_club_left,
            view_games_details.username_club_left,
            view_games_details.id_club_right,
            view_games_details.name_club_right,
            view_games_details.id_user_club_right,
            view_games_details.username_club_right,
            view_games_details.id_stadium,
            view_games_details.is_played,
            view_games_details.is_league_game,
            view_games_details.is_cup,
            view_games_details.is_friendly,
            sum(
                CASE
                    WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_left THEN 1
                    ELSE 0
                END) AS goals_left,
            sum(
                CASE
                    WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_right THEN 1
                    ELSE 0
                END) AS goals_right,
            view_games_details.id_league
           FROM view_games_details
          GROUP BY view_games_details.id, view_games_details.date_start, view_games_details.week_number, view_games_details.id_club_left, view_games_details.name_club_left, view_games_details.id_user_club_left, view_games_details.username_club_left, view_games_details.id_club_right, view_games_details.name_club_right, view_games_details.id_user_club_right, view_games_details.username_club_right, view_games_details.id_stadium, view_games_details.is_played, view_games_details.is_league_game, view_games_details.is_cup, view_games_details.is_friendly, view_games_details.id_league) subquery_right;