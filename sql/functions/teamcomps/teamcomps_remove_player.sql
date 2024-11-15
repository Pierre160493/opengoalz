-- DROP FUNCTION public.teamcomps_populate(int8);

CREATE OR REPLACE FUNCTION public.teamcomps_remove_player_from_teamcomps(inp_id_player bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    removal_count INT := 0; -- Counter for the number of removals
BEGIN

-- Remove the player id from the teamcomps of his club where he appears
    WITH updated_rows AS (
        UPDATE games_teamcomp
        SET
            idgoalkeeper = CASE WHEN idgoalkeeper = inp_id_player THEN NULL ELSE idgoalkeeper END,
            idleftbackwinger = CASE WHEN idleftbackwinger = inp_id_player THEN NULL ELSE idleftbackwinger END,
            idleftcentralback = CASE WHEN idleftcentralback = inp_id_player THEN NULL ELSE idleftcentralback END,
            idcentralback = CASE WHEN idcentralback = inp_id_player THEN NULL ELSE idcentralback END,
            idrightcentralback = CASE WHEN idrightcentralback = inp_id_player THEN NULL ELSE idrightcentralback END,
            idrightbackwinger = CASE WHEN idrightbackwinger = inp_id_player THEN NULL ELSE idrightbackwinger END,
            idleftwinger = CASE WHEN idleftwinger = inp_id_player THEN NULL ELSE idleftwinger END,
            idleftmidfielder = CASE WHEN idleftmidfielder = inp_id_player THEN NULL ELSE idleftmidfielder END,
            idcentralmidfielder = CASE WHEN idcentralmidfielder = inp_id_player THEN NULL ELSE idcentralmidfielder END,
            idrightmidfielder = CASE WHEN idrightmidfielder = inp_id_player THEN NULL ELSE idrightmidfielder END,
            idrightwinger = CASE WHEN idrightwinger = inp_id_player THEN NULL ELSE idrightwinger END,
            idleftstriker = CASE WHEN idleftstriker = inp_id_player THEN NULL ELSE idleftstriker END,
            idcentralstriker = CASE WHEN idcentralstriker = inp_id_player THEN NULL ELSE idcentralstriker END,
            idrightstriker = CASE WHEN idrightstriker = inp_id_player THEN NULL ELSE idrightstriker END,
            idsub1 = CASE WHEN idsub1 = inp_id_player THEN NULL ELSE idsub1 END,
            idsub2 = CASE WHEN idsub2 = inp_id_player THEN NULL ELSE idsub2 END,
            idsub3 = CASE WHEN idsub3 = inp_id_player THEN NULL ELSE idsub3 END,
            idsub4 = CASE WHEN idsub4 = inp_id_player THEN NULL ELSE idsub4 END,
            idsub5 = CASE WHEN idsub5 = inp_id_player THEN NULL ELSE idsub5 END,
            idsub6 = CASE WHEN idsub6 = inp_id_player THEN NULL ELSE idsub6 END,
            idsub7 = CASE WHEN idsub7 = inp_id_player THEN NULL ELSE idsub7 END
        WHERE id_club = (SELECT id_club FROM players WHERE id = inp_id_player)
        AND is_played = FALSE
        RETURNING *
    )
    SELECT COUNT(*) INTO removal_count FROM updated_rows;

    RETURN removal_count;

END;
$function$
;
