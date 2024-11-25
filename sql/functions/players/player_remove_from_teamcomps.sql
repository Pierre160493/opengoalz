-- DROP FUNCTION public.teamcomps_remove_player_from_teamcomps(int8);

CREATE OR REPLACE FUNCTION public.player_remove_from_teamcomps(rec_player RECORD)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
BEGIN

    ------ Remove the player id from the teamcomps of his club where he appears
    UPDATE games_teamcomp
        SET
            idgoalkeeper = CASE WHEN idgoalkeeper = rec_player.id THEN NULL ELSE idgoalkeeper END,
            idleftbackwinger = CASE WHEN idleftbackwinger = rec_player.id THEN NULL ELSE idleftbackwinger END,
            idleftcentralback = CASE WHEN idleftcentralback = rec_player.id THEN NULL ELSE idleftcentralback END,
            idcentralback = CASE WHEN idcentralback = rec_player.id THEN NULL ELSE idcentralback END,
            idrightcentralback = CASE WHEN idrightcentralback = rec_player.id THEN NULL ELSE idrightcentralback END,
            idrightbackwinger = CASE WHEN idrightbackwinger = rec_player.id THEN NULL ELSE idrightbackwinger END,
            idleftwinger = CASE WHEN idleftwinger = rec_player.id THEN NULL ELSE idleftwinger END,
            idleftmidfielder = CASE WHEN idleftmidfielder = rec_player.id THEN NULL ELSE idleftmidfielder END,
            idcentralmidfielder = CASE WHEN idcentralmidfielder = rec_player.id THEN NULL ELSE idcentralmidfielder END,
            idrightmidfielder = CASE WHEN idrightmidfielder = rec_player.id THEN NULL ELSE idrightmidfielder END,
            idrightwinger = CASE WHEN idrightwinger = rec_player.id THEN NULL ELSE idrightwinger END,
            idleftstriker = CASE WHEN idleftstriker = rec_player.id THEN NULL ELSE idleftstriker END,
            idcentralstriker = CASE WHEN idcentralstriker = rec_player.id THEN NULL ELSE idcentralstriker END,
            idrightstriker = CASE WHEN idrightstriker = rec_player.id THEN NULL ELSE idrightstriker END,
            idsub1 = CASE WHEN idsub1 = rec_player.id THEN NULL ELSE idsub1 END,
            idsub2 = CASE WHEN idsub2 = rec_player.id THEN NULL ELSE idsub2 END,
            idsub3 = CASE WHEN idsub3 = rec_player.id THEN NULL ELSE idsub3 END,
            idsub4 = CASE WHEN idsub4 = rec_player.id THEN NULL ELSE idsub4 END,
            idsub5 = CASE WHEN idsub5 = rec_player.id THEN NULL ELSE idsub5 END,
            idsub6 = CASE WHEN idsub6 = rec_player.id THEN NULL ELSE idsub6 END,
            idsub7 = CASE WHEN idsub7 = rec_player.id THEN NULL ELSE idsub7 END
    WHERE is_played IS FALSE
    AND id_club = rec_player.id_club;

    ------ Try to correct the errors in the main default teamcomp
    PERFORM teamcomp_correct_teamcomp_errors(
        inp_id_teamcomp := (
            SELECT id
            FROM games_teamcomp
            WHERE id_club = rec_player.id_club
            AND season_number = 0
            AND week_number = 1
        )
    );

END;
$function$
;
