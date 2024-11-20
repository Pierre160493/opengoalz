-- DROP FUNCTION public.teamcomp_fetch_players_id(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_fetch_players_id(inp_id_teamcomp bigint)
RETURNS bigint[]
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Fetch the players id from the given teamcomp
    RETURN (
        SELECT ARRAY[
            idgoalkeeper, -- 1
            idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger, -- 2-6
            idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger, -- 7-11
            idleftstriker, idcentralstriker, idrightstriker, -- 12-14
            idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7 -- 15-21
        ]
        FROM games_teamcomp
        WHERE id = inp_id_teamcomp
    );
END;
$function$;