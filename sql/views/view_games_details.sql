-- public.view_games_details source

CREATE OR REPLACE VIEW public.view_games_details
AS SELECT games.id,
    games.date_start,
    games.week_number,
    games.id_teamcomp_left AS id_club_left,
    cl_left.name_club AS name_club_left,
    profile_left.uuid_user AS id_user_club_left,
    profile_left.username AS username_club_left,
    games.id_teamcomp_right AS id_club_right,
    cl_right.name_club AS name_club_right,
    profile_right.uuid_user AS id_user_club_right,
    profile_right.username AS username_club_right,
    games.id_stadium,
    games.is_played,
    games.is_league AS is_league_game,
    games.is_cup,
    games.is_friendly,
    game_events_type.event_type,
    game_events.date_event,
    game_events.game_minute,
    game_events.game_period,
    game_events.id_club,
    clubs.name_club AS club_name,
    game_events.id_player,
    players.first_name,
    players.last_name,
    game_events_type.description,
    clubs.id_league
   FROM games
     LEFT JOIN clubs cl_left ON games.id_teamcomp_left = cl_left.id
     LEFT JOIN clubs cl_right ON games.id_teamcomp_right = cl_right.id
     LEFT JOIN game_events ON games.id = game_events.id_game
     LEFT JOIN clubs ON game_events.id_club = clubs.id
     LEFT JOIN players ON players.id = game_events.id_player
     LEFT JOIN game_events_type ON game_events.id_event_type = game_events_type.id
     LEFT JOIN profiles profile_left ON cl_left.id_user = profile_left.uuid_user
     LEFT JOIN profiles profile_right ON cl_right.id_user = profile_right.uuid_user;