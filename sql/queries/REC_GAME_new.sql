WITH player_positions AS (
    SELECT
        games.id AS game_id,
        UNNEST(ARRAY[
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
        ]) AS id_player_left,
        UNNEST(ARRAY[
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
        ]) AS id_player_right,
        UNNEST(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]) AS position_id -- Match positions
    FROM games
    JOIN games_teamcomp gtl ON games.id_club_left = gtl.id_club AND games.season_number = gtl.season_number AND games.week_number = gtl.week_number
    JOIN games_teamcomp gtr ON games.id_club_right = gtr.id_club AND games.season_number = gtr.season_number AND games.week_number = gtr.week_number
    WHERE games.id = 1
),
player_stats AS (
    SELECT
        pp.game_id,
        pp.position_id,
        gpp.position_name,
        gpp.coefs AS players_coef,
        pp.id_player_left,
        ARRAY[
            COALESCE(pl.keeper, 0),
            COALESCE(pl.defense, 0),
            COALESCE(pl.passes, 0),
            COALESCE(pl.playmaking, 0),
            COALESCE(pl.winger, 0),
            COALESCE(pl.scoring, 0)
        ] AS players_stats_left,
        pp.id_player_right,
        ARRAY[
            COALESCE(pr.keeper, 0),
            COALESCE(pr.defense, 0),
            COALESCE(pr.passes, 0),
            COALESCE(pr.playmaking, 0),
            COALESCE(pr.winger, 0),
            COALESCE(pr.scoring, 0)
        ] AS players_stats_right
    FROM
        player_positions pp
    JOIN
        games_possible_position gpp ON pp.position_id = gpp.id
    LEFT JOIN
        players pl ON pp.id_player_left = pl.id
    LEFT JOIN
        players pr ON pp.id_player_right = pr.id
    ORDER BY
        pp.position_id
)
SELECT
    ps.game_id,
    ps.position_id,
    ps.position_name,
    ps.players_coef,
    ps.id_player_left,
    ps.players_stats_left,
    ARRAY(
        SELECT SUM(c * s)
        FROM UNNEST(ps.players_coef) AS c,
             UNNEST(ps.players_stats_left) AS s
    ) AS players_weights_left,
    ps.id_player_right,
    ps.players_stats_right,
    ARRAY(
        SELECT SUM(c * s)
        FROM UNNEST(ps.players_coef) AS c,
             UNNEST(ps.players_stats_right) AS s
    ) AS players_weights_right,
    ARRAY(
            SELECT SUM(c * s)
            FROM unnest(ps.players_coef) WITH ORDINALITY AS coef(c, row_idx),
                 unnest(ps.players_stats_left) WITH ORDINALITY AS stat(s, col_idx)
            WHERE (row_idx - 1) / 6 + 1 = col_idx -- Match row-column positions of the 7x6 matrix
            GROUP BY row_idx
            ORDER BY row_idx
        ) AS players_weights_left_v2,
FROM
    player_stats ps
ORDER BY
    ps.position_id;