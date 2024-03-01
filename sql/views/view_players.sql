-- public.view_players source

CREATE OR REPLACE VIEW public.view_players
AS SELECT players.id,
    players.created_at,
    players.id_club,
    players.first_name,
    players.last_name,
    players.date_birth,
    calculate_age(players.date_birth) AS age,
    clubs.club_name,
    profiles.username,
    profiles.id AS id_user,
    players.keeper,
    players.defense,
    players.playmaking,
    players.passes,
    players.winger,
    players.scoring,
    players.freekick
   FROM players
     JOIN clubs ON players.id_club = clubs.id
     LEFT JOIN profiles ON clubs.id_user = profiles.id
  ORDER BY (calculate_age(players.date_birth));