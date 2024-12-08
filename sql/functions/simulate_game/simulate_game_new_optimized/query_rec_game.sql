WITH teamcomp AS (
    SELECT
        games.id AS id_game,
        generate_series(1, 20) AS id_position,
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
        ]) AS id_players_l,
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
        ]) AS id_players_r
    FROM games
    JOIN games_teamcomp gtl ON gtl.id = 1
    JOIN games_teamcomp gtr ON gtr.id = 8
    WHERE games.id = 1
), players_stats1 AS (
    SELECT
        teamcomp.*,
        games_possible_position.position_name,
        games_possible_position.coefs AS players_coef,
        (pl.first_name || ' ' || pl.last_name) AS players_name_left,
        teamcomp.id_position AS subs_left,
        ARRAY[
            COALESCE(pl.keeper, 0),
            COALESCE(pl.defense, 0),
            COALESCE(pl.passes, 0),
            COALESCE(pl.playmaking, 0),
            COALESCE(pl.winger, 0),
            COALESCE(pl.scoring, 0),
            COALESCE(pl.freekick, 0)
        ] AS players_stats_left,
        ARRAY[
            COALESCE(pl.motivation, 0),
            COALESCE(pl.form, 0),
            COALESCE(pl.experience, 0),
            COALESCE(pl.energy, 0),
            COALESCE(pl.stamina, 0)
        ] AS players_stats_other_left,
        (pr.first_name || ' ' || pr.last_name) AS players_name_right,
        teamcomp.id_position AS subs_right,
        ARRAY[
            COALESCE(pr.keeper, 0),
            COALESCE(pr.defense, 0),
            COALESCE(pr.passes, 0),
            COALESCE(pr.playmaking, 0),
            COALESCE(pr.winger, 0),
            COALESCE(pr.scoring, 0),
            COALESCE(pr.freekick, 0)
        ] AS players_stats_right,
        ARRAY[
            COALESCE(pr.motivation, 0),
            COALESCE(pr.form, 0),
            COALESCE(pr.experience, 0),
            COALESCE(pr.energy, 0),
            COALESCE(pr.stamina, 0)
        ] AS players_stats_other_right
    FROM
        teamcomp
    JOIN
        games_possible_position ON teamcomp.id_position = games_possible_position.id
    LEFT JOIN
        players pl ON teamcomp.id_players_l = pl.id
    LEFT JOIN
        players pr ON teamcomp.id_players_r = pr.id
    ORDER BY
        teamcomp.id_position
), players_stats2 AS (
SELECT
    ps1.*,
    ARRAY[
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[1:1]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- LeftDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[2:2]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- CentralDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[3:3]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- RightDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[4:4]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- MidField
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[5:5]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- LeftAttack
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[6:6]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s), -- Central Attack
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[7:7]) AS c, UNNEST(ps1.players_stats_left[1:6]) AS s) -- Right Attack
    ] AS players_weights_l,
    ARRAY[
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[1:1]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- LeftDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[2:2]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- CentralDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[3:3]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- RightDefense
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[4:4]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- MidField
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[5:5]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- LeftAttack
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[6:6]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s), -- Central Attack
        (SELECT SUM(c * s) FROM UNNEST(ps1.players_coef[7:7]) AS c, UNNEST(ps1.players_stats_right[1:6]) AS s) -- Right Attack
    ] AS players_weights_r
FROM
    players_stats1 ps1
ORDER BY
    ps1.id_position
), game_stats AS (
SELECT
    ps2.id_game,
    ARRAY_AGG(ps2.id_position) AS id_position,
    ARRAY_AGG(ps2.position_name) AS id_position,
    ARRAY_AGG(ps2.players_stats_left) AS players_stats_l,
    ARRAY_AGG(ps2.players_stats_right) AS players_stats_r,
    ARRAY_AGG(players_weights_l) AS players_weights_l,
    ARRAY_AGG(players_weights_r) AS players_weights_r,
    ARRAY[
        SUM((players_weights_l[1:14])[1]),
        SUM((players_weights_l[1:14])[2]),
        SUM((players_weights_l[1:14])[3]),
        SUM((players_weights_l[1:14])[4]),
        SUM((players_weights_l[1:14])[5]),
        SUM((players_weights_l[1:14])[6]),
        SUM((players_weights_l[1:14])[7])
    ] AS team_weights_l,
    ARRAY[
        SUM((players_weights_r[1:14])[1]),
        SUM((players_weights_r[1:14])[2]),
        SUM((players_weights_r[1:14])[3]),
        SUM((players_weights_r[1:14])[4]),
        SUM((players_weights_r[1:14])[5]),
        SUM((players_weights_r[1:14])[6]),
        SUM((players_weights_r[1:14])[7])
    ] AS team_weights_r
FROM
    players_stats2 ps2
GROUP BY ps2.id_game
    ), game_stats2 AS (
SELECT
    random() AS random_for_goal,
    LEAST(0.4, GREATEST(0.1, (1.0/5.0))) AS opportunity_prob,
    team_weights_l[4] / (team_weights_l[4] + team_weights_r[4]) AS midfield_prob_left,
    team_weights_l[1] + team_weights_l[2] + team_weights_l[3] AS defense_l,
    team_weights_l[5] + team_weights_l[6] + team_weights_l[7] AS attack_l,
    team_weights_r[1] + team_weights_r[2] + team_weights_r[3] AS defense_r,
    team_weights_r[5] + team_weights_r[6] + team_weights_r[7] AS attack_r,
    *
FROM game_stats)
SELECT
    CASE
        WHEN random_for_goal > opportunity_prob THEN ARRAY[0,0]
        ELSE ARRAY[0,0]
    END AS goals,
    *
FROM game_stats2;