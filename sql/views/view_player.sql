-- public.view_games source

CREATE OR REPLACE VIEW public.view_games
AS SELECT view_games_details.id,
    view_games_details.date_start,
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
    view_games_details.is_cup,
    count(
        CASE
            WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_left THEN 1
            ELSE NULL::integer
        END) AS goals_left,
    count(
        CASE
            WHEN view_games_details.event_type = 'goal'::text AND view_games_details.id_club = view_games_details.id_club_right THEN 1
            ELSE NULL::integer
        END) AS goals_right
   FROM view_games_details
  GROUP BY view_games_details.id, view_games_details.date_start, view_games_details.id_club_left, view_games_details.name_club_left, view_games_details.id_user_club_left, view_games_details.username_club_left, view_games_details.id_club_right, view_games_details.name_club_right, view_games_details.id_user_club_right, view_games_details.username_club_right, view_games_details.id_stadium, view_games_details.is_played, view_games_details.is_cup;