CREATE OR REPLACE FUNCTION teamcomp_fetch_players(inp_id_teamcomp bigint)
RETURNS TABLE (
    position_id int,
    position_name text,
    players_coef double precision[],
    id_players bigint,
    full_name text,
    subs int,
    players_stats double precision[],
    players_stats_other double precision[]
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
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
            UNNEST(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]) AS position_id -- Match positions
        FROM games_teamcomp gt
        WHERE gt.id = inp_id_teamcomp
    )
    SELECT
        teamcomp.position_id,
        games_possible_position.position_name,
        games_possible_position.coefs::double precision[] AS players_coef,
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
        teamcomp.position_id;
END;
$function$;
