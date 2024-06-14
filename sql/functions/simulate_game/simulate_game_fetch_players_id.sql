CREATE OR REPLACE FUNCTION public.simulate_game_fetch_players_id(inp_id_game int8, inp_id_club int8)
 RETURNS int8[21]
 LANGUAGE plpgsql
AS $function$
DECLARE
    players_id int8[21]; -- Matrix to hold player stats
BEGIN

    -- Loop through the input player IDs and fetch their stats
    SELECT ARRAY[
            idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
            idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
            idleftstriker, idcentralstriker, idrightstriker,
            idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
    ] INTO players_id
    FROM games_team_comp
    WHERE id_game = inp_id_game AND id_club = inp_id_club;

    RETURN players_id;

END;
$function$;