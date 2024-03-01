-- public.view_clubs source

CREATE OR REPLACE VIEW public.view_clubs
AS SELECT clubs.id,
    clubs.created_at,
    clubs.id_league,
    clubs.id_user,
    clubs.club_name,
    profiles.username,
    countries.name AS country_name,
    leagues.level AS league_level,
    count(players.id) AS player_count,
    min(calculate_age(players.date_birth)) AS player_age_youngest,
    max(calculate_age(players.date_birth)) AS player_age_oldest,
    avg(calculate_age(players.date_birth)) AS player_age_average
   FROM clubs
     LEFT JOIN profiles ON clubs.id_user = profiles.id
     LEFT JOIN leagues ON clubs.id_league = leagues.id
     LEFT JOIN countries ON leagues.id_country = countries.id
     LEFT JOIN players ON clubs.id = players.id_club
  GROUP BY clubs.id, clubs.created_at, clubs.id_league, clubs.id_user, clubs.club_name, profiles.username, countries.name, leagues.level
  ORDER BY clubs.created_at, clubs.id;