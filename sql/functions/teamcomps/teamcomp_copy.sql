-- DROP FUNCTION public.teamcomps_copy_previous(int8, int8, int8);

CREATE OR REPLACE FUNCTION public.teamcomps_copy_previous(
    inp_id_teamcomp bigint,
    inp_season_number bigint DEFAULT 0,
    inp_week_number bigint DEFAULT 1)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_teamcomp_ref bigint;
BEGIN

    -- Fetch the teamcomp id of the reference to copy from
    SELECT id INTO loc_id_teamcomp_ref FROM games_teamcomp
    WHERE id_club = (
        SELECT id_club FROM games_teamcomp WHERE id = inp_id_teamcomp
        ) AND season_number = inp_season_number AND week_number = inp_week_number;

    -- Set the players id from the previous teamcomp
    UPDATE games_teamcomp SET
        idgoalkeeper = teamcomp_ref.idgoalkeeper,
        idleftbackwinger = teamcomp_ref.idleftbackwinger,
        idleftcentralback = teamcomp_ref.idleftcentralback,
        idcentralback = teamcomp_ref.idcentralback,
        idrightcentralback = teamcomp_ref.idrightcentralback,
        idrightbackwinger = teamcomp_ref.idrightbackwinger,
        idleftwinger = teamcomp_ref.idleftwinger,
        idleftmidfielder = teamcomp_ref.idleftmidfielder,
        idcentralmidfielder = teamcomp_ref.idcentralmidfielder,
        idrightmidfielder = teamcomp_ref.idrightmidfielder,
        idrightwinger = teamcomp_ref.idrightwinger,
        idleftstriker = teamcomp_ref.idleftstriker,
        idcentralstriker = teamcomp_ref.idcentralstriker,
        idrightstriker = teamcomp_ref.idrightstriker,
        idsub1 = teamcomp_ref.idsub1,
        idsub2 = teamcomp_ref.idsub2,
        idsub3 = teamcomp_ref.idsub3,
        idsub4 = teamcomp_ref.idsub4,
        idsub5 = teamcomp_ref.idsub5,
        idsub6 = teamcomp_ref.idsub6,
        idsub7 = teamcomp_ref.idsub7
    FROM (
        SELECT
            idgoalkeeper,
            idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
            idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
            idleftstriker, idcentralstriker, idrightstriker,
            idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
        FROM games_teamcomp
        WHERE id = loc_id_teamcomp_ref
    ) AS teamcomp_ref
    WHERE id = inp_id_teamcomp;

    -- Clean the game orders
    DELETE FROM game_orders WHERE id_teamcomp = inp_id_teamcomp;

    -- Insert the game orders
    INSERT INTO game_orders (id_teamcomp, id_player_out, id_player_in, minute, condition)
    SELECT inp_id_teamcomp, id_player_out, id_player_in, minute, condition
    FROM game_orders
    WHERE id_teamcomp = loc_id_teamcomp_ref;

END;
$function$
;
