-- public.view_clubs source

CREATE OR REPLACE VIEW public.view_clubs
AS SELECT clubs.id AS id_club,
    clubs.created_at,
    clubs.multiverse_speed,
    clubs.id_league,
    clubs.id_user,
    clubs.name_club,
    profiles.username,
    profiles.id_default_club,
        CASE
            WHEN profiles.id_default_club = clubs.id THEN true
            ELSE false
        END AS is_default_club,
    countries.name AS country_name,
    leagues.level AS league_level,
    is_currently_playing(inp_id_club => clubs.id) AS is_currently_playing,
    count(players.id) AS player_count,
    min(calculate_age(players.date_birth)) AS player_age_youngest,
    max(calculate_age(players.date_birth)) AS player_age_oldest,
    avg(calculate_age(players.date_birth)) AS player_age_average,
    clubs.cash_absolute,
    clubs.cash_available,
    clubs.number_fans,
    ( SELECT string_agg(
                CASE
                    WHEN subquery.result = 'Victory'::text THEN 'V'::text
                    WHEN subquery.result = 'Draw'::text THEN 'D'::text
                    WHEN subquery.result = 'Defeat'::text THEN 'L'::text
                    ELSE ' '::text
                END, ''::text) AS last_results
           FROM ( SELECT view_games.result
                   FROM view_games
                  WHERE view_games.id_club = clubs.id AND view_games.is_played = true
                  ORDER BY view_games.date_start DESC
                 LIMIT 5) subquery) AS last_results
   FROM clubs
     LEFT JOIN profiles ON clubs.id_user = profiles.uuid_user
     LEFT JOIN leagues ON clubs.id_league = leagues.id
     LEFT JOIN countries ON clubs.id_country = countries.id
     LEFT JOIN players ON clubs.id = players.id_club
     LEFT JOIN finances ON clubs.id = finances.id_club
     LEFT JOIN fans ON clubs.id = fans.id_club
  GROUP BY clubs.id, clubs.created_at, clubs.id_league, clubs.id_user, clubs.name_club, profiles.username, profiles.id_default_club, countries.name, leagues.level
  ORDER BY clubs.created_at, clubs.id;