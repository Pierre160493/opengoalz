WITH teamcomp AS (
    SELECT
        UNNEST(ARRAY[
            gt.idgoalkeeper,
            gt.idleftbackwinger,
            gt.idleftcentralback,
            gt.idcentralback,
            gt.idrightcentralback,
            gt.idrightbackwinger,
            gt.idleftwinger,
            gt.idleftmidfielder,
            gt.idcentralmidfielder,
            gt.idrightmidfielder,
            gt.idrightwinger,
            gt.idleftstriker,
            gt.idcentralstriker,
            gt.idrightstriker,
            gt.idsub1,
            gt.idsub2,
            gt.idsub3,
            gt.idsub4,
            gt.idsub5,
            gt.idsub6
        ]) AS id_players,
        generate_series(1, 20) AS position_id
    FROM games_teamcomp gt
    WHERE id = 1
)
SELECT
    teamcomp.position_id,
    games_possible_position.position_name,
    games_possible_position.coefs AS players_coef,
    teamcomp.id_players,
    (players.first_name || ' ' || players.last_name) AS full_name,
    teamcomp.position_id AS subs,
    ARRAY[
        COALESCE(players.keeper, 0),
        COALESCE(players.defense, 0),
        COALESCE(players.passes, 0),
        COALESCE(players.playmaking, 0),
        COALESCE(players.winger, 0),
        COALESCE(players.scoring, 0),
        COALESCE(players.freekick, 0)
    ] AS players_stats,
    ARRAY[
        COALESCE(players.motivation, 0),
        COALESCE(players.form, 0),
        COALESCE(players.experience, 0),
        COALESCE(players.energy, 0),
        COALESCE(players.stamina, 0)
    ] AS players_stats_other
FROM
    teamcomp
JOIN
    games_possible_position ON teamcomp.position_id = games_possible_position.id
LEFT JOIN
    players ON teamcomp.id_players = players.id
ORDER BY
    teamcomp.position_id