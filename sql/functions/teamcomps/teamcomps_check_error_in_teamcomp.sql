-- DROP FUNCTION public.teamcomps_check_error_in_teamcomp(int8);

CREATE OR REPLACE FUNCTION public.teamcomps_check_error_in_teamcomp(inp_id_teamcomp bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_teamcomp_id INT; -- Id of the team composition
    loc_id_club INT; -- Id of the club
    loc_teamcomp_ids int8[];
    loc_count INT; -- Number of players in the teamcomp
    loc_duplicate_id INT := NULL; -- Id of the duplicate player
BEGIN

    -- Fetch the teamcomp id
    select id, id_club into loc_teamcomp_id, loc_id_club from games_teamcomp where id = inp_id_teamcomp;

    -- Fetch team compositions into a temporary array
    SELECT ARRAY[
        idgoalkeeper, idleftbackwinger, idleftcentralback, idcentralback, idrightcentralback, idrightbackwinger,
        idleftwinger, idleftmidfielder, idcentralmidfielder, idrightmidfielder, idrightwinger,
        idleftstriker, idcentralstriker, idrightstriker,
        idsub1, idsub2, idsub3, idsub4, idsub5, idsub6, idsub7
    ] INTO loc_teamcomp_ids
    FROM games_teamcomp
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
        RAISE EXCEPTION 'Duplicate player ID % found for teamcomp: %', loc_duplicate_id, inp_id_teamcomp;
        --UPDATE games_teamcomp SET error = 'Duplicate player ID'
        --    WHERE id = inp_id_teamcomp;
        --RETURN;
    END IF;

    -- Check that there are no more than 11 players in the specified columns
    SELECT COUNT(id)
    INTO loc_count
    FROM unnest(loc_teamcomp_ids[1:14]) AS id
    WHERE id IS NOT NULL;

    -- If there are more than 11 players in the teamcomp, raise an exception
    IF loc_count > 11 THEN
        RAISE EXCEPTION 'There cannot be more than 11 players in the 14 main positions !';
        --UPDATE games_teamcomp SET error = 'There cannot be more than 11 players in the 14 main positions !'
        --    WHERE id = inp_id_teamcomp;
        --RETURN;
    END IF;

    -- Check that each player belongs to the specified club
    FOR i IN 1..14 LOOP
        IF loc_teamcomp_ids[i] IS NOT NULL THEN
            PERFORM id
            FROM players
            WHERE id = loc_teamcomp_ids[i]
            AND id_club = loc_id_club;

            IF NOT FOUND THEN
                RAISE EXCEPTION 'Teamcomp [%]: Player ID % does not belong to club ID %', inp_id_teamcomp, loc_teamcomp_ids[i], loc_id_club;
                --UPDATE games_teamcomp SET error = 'Player does not belong to the club'
                --    WHERE id = inp_id_teamcomp;
                --RETURN;
            END IF;
        END IF;
    END LOOP;

    -- Check if the teamcomp is valid
    IF loc_count < 11 THEN
        UPDATE games_teamcomp SET error = 'Less than 11 players in the teamcomp'
            WHERE id = inp_id_teamcomp;
    ELSEIF loc_count = 11 THEN
        UPDATE games_teamcomp SET error = NULL
            WHERE id = inp_id_teamcomp;
    END IF;



END;
$function$
;
