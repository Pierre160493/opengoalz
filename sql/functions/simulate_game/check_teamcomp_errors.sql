-- DROP FUNCTION public.check_teamcomp_errors(int8, int8);

CREATE OR REPLACE FUNCTION public.check_teamcomp_errors(inp_id_club bigint, inp_id_game bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_teamcomp_id INT; -- Id of the team composition
    loc_teamcomp_ids int8[];
    loc_count INT; -- Number of players in the teamcomp
    loc_duplicate_id INT := NULL; -- Id of the duplicate player
BEGIN

    -- Fetch the teamcomp id
    select id into loc_teamcomp_id from games_team_comp where id_game = inp_id_game and id_club = inp_id_club;

    -- Fetch team compositions into a temporary array
    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
    ] INTO loc_teamcomp_ids
    FROM games_team_comp
    WHERE id = loc_teamcomp_id;

    -- Check if there are any duplicate player IDs in the teamcomp
    SELECT id INTO loc_duplicate_id
        FROM (
            SELECT id, COUNT(*) AS cnt
            FROM unnest(loc_teamcomp_ids) AS id
            WHERE id IS NOT NULL -- Add this condition to remove null values
            GROUP BY id
        ) AS subquery
    WHERE cnt > 1;

    -- If a duplicate player ID is found, raise an exception
    IF loc_duplicate_id IS NOT NULL THEN
        RAISE EXCEPTION 'Duplicate player ID % found in teamcomp for team id: % and game id: %', loc_duplicate_id, inp_id_club, inp_id_game;
    END IF;

    -- Check that there are no more than 11 players in the specified columns
    SELECT COUNT(id)
    INTO loc_count
    FROM unnest(loc_teamcomp_ids[1:14]) AS id
    WHERE id IS NOT NULL;

    -- If there are more than 11 players in the teamcomp, raise an exception
    IF loc_count > 11 THEN
        RAISE EXCEPTION 'There cannot be more than 11 players in the 14 main positions !';
    END IF;

    -- Check that each player belongs to the specified club
    FOR i IN 1..14 LOOP
        IF loc_teamcomp_ids[i] IS NOT NULL THEN
            PERFORM id
            FROM players
            WHERE id = loc_teamcomp_ids[i]
            AND id_club = inp_id_club;

            IF NOT FOUND THEN
                RAISE EXCEPTION 'Player ID % does not belong to club ID %', loc_teamcomp_ids[i], inp_id_club;
            END IF;
        END IF;
    END LOOP;

END;
$function$
;
