WITH game_data AS (
    SELECT
        games.*,
        ARRAY[
            gtl.idgoalkeeper,
            gtl.idleftbackwinger,
            gtl.idleftcentralback,
            gtl.idcentralback,
            gtl.idrightcentralback,
            gtl.idrightbackwinger,
            gtl.idleftwinger,
            gtl.idleftmidfielder,
            gtl.idcentralmidfielder,
            gtl.idrightmidfielder,
            gtl.idrightwinger,
            gtl.idleftstriker,
            gtl.idcentralstriker,
            gtl.idrightstriker,
            gtl.idsub1,
            gtl.idsub2,
            gtl.idsub3,
            gtl.idsub4,
            gtl.idsub5,
            gtl.idsub6
        ] AS id_players_left,
        ARRAY[
            gtr.idgoalkeeper,
            gtr.idleftbackwinger,
            gtr.idleftcentralback,
            gtr.idcentralback,
            gtr.idrightcentralback,
            gtr.idrightbackwinger,
            gtr.idleftwinger,
            gtr.idleftmidfielder,
            gtr.idcentralmidfielder,
            gtr.idrightmidfielder,
            gtr.idrightwinger,
            gtr.idleftstriker,
            gtr.idcentralstriker,
            gtr.idrightstriker,
            gtr.idsub1,
            gtr.idsub2,
            gtr.idsub3,
            gtr.idsub4,
            gtr.idsub5,
            gtr.idsub6
        ] AS id_players_right,
        cl.name AS name_club_left, cl.username AS username_club_left,
        cr.name AS name_club_right, cr.username AS username_club_right
    FROM games
    JOIN games_teamcomp gtl ON games.id_club_left = gtl.id_club AND games.season_number = gtl.season_number AND games.week_number = gtl.week_number
    JOIN games_teamcomp gtr ON games.id_club_right = gtr.id_club AND games.season_number = gtr.season_number AND games.week_number = gtr.week_number
    JOIN clubs cl ON games.id_club_left = cl.id
    JOIN clubs cr ON games.id_club_right = cr.id
    WHERE games.id = 1
),
players_weights AS (
    SELECT ARRAY_AGG(gpp.weights ORDER BY gpp.id) AS weights
    FROM games_possible_position gpp
    WHERE gpp.is_titulaire
),
subs AS (
    SELECT ARRAY(SELECT generate_series(1, 21)) AS subs_init
),
rec_game_init AS (
    SELECT
        pw.weights AS players_weights,
        ARRAY(
            SELECT ARRAY[
                COALESCE(p.keeper, 0),
                COALESCE(p.defense, 0),
                COALESCE(p.passes, 0),
                COALESCE(p.playmaking, 0),
                COALESCE(p.winger, 0),
                COALESCE(p.scoring, 0)
            ]
            FROM UNNEST(gd.id_players_left) WITH ORDINALITY AS u(player_id, ord)
            LEFT JOIN players p ON p.id = u.player_id
            ORDER BY u.ord
        ) AS players_stats_left,
        ARRAY(
            SELECT ARRAY[
                COALESCE(p.keeper, 0),
                COALESCE(p.defense, 0),
                COALESCE(p.passes, 0),
                COALESCE(p.playmaking, 0),
                COALESCE(p.winger, 0),
                COALESCE(p.scoring, 0)
            ]
            FROM UNNEST(gd.id_players_right) WITH ORDINALITY AS u(player_id, ord)
            LEFT JOIN players p ON p.id = u.player_id
            ORDER BY u.ord
        ) AS players_stats_right,
        subs.subs_init AS subs_left,
        subs.subs_init AS subs_right,
        gd.*
    FROM game_data gd
    JOIN players_weights pw ON true
    JOIN subs ON TRUE
)
SELECT
    --UNNEST(players_weights),
    --players_stats_left,
    --UNNEST(players_stats_left)
    *
FROM rec_game_init;