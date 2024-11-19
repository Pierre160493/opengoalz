-- DROP FUNCTION public.teamcomps_check_error_in_teamcomp(int8);

CREATE OR REPLACE FUNCTION public.teamcomp_check_error(inp_id_teamcomp bigint)
 RETURNS TEXT
 LANGUAGE plpgsql
AS $function$
DECLARE
    loc_id_club INT; -- Id of the club
    loc_players_id int8[];
    loc_count INT; -- Number of players in the teamcomp
    loc_duplicate_id INT := NULL; -- Id of the duplicate player
    return_text TEXT := NULL; -- Text to return
BEGIN

    ------ Select the club of the teamcomp
    SELECT id_club INTO loc_id_club
    FROM games_teamcomp WHERE id = inp_id_teamcomp;

    ------ Fetch players id into a temporary array
    loc_players_id := teamcomp_fetch_players_id(inp_id_teamcomp := inp_id_teamcomp);

    ------ Check if there are any duplicate player IDs in the teamcomp
    SELECT id INTO loc_duplicate_id
        FROM (
            SELECT id, COUNT(*) AS cnt
            FROM unnest(loc_players_id) AS id
            WHERE id IS NOT NULL -- Add this condition to remove null values
            GROUP BY id
        ) AS subquery
    WHERE cnt > 1;

    ------ If a duplicate player ID is found, raise an exception
    IF loc_duplicate_id IS NOT NULL THEN
        --RAISE EXCEPTION 'Duplicate player ID % found for teamcomp: %', loc_duplicate_id, inp_id_teamcomp;
        return_text := 'Duplicate player ID found in the teamcomp';
    END IF;

    ------ While the return text is null, keep searching for errors
    IF return_text IS NULL THEN

        ------ Check that there are no more than 11 players in the specified columns
        SELECT COUNT(id)
        INTO loc_count
        FROM unnest(loc_players_id[1:14]) AS id
        WHERE id IS NOT NULL;

        ------ Check if there are exactly 11 players in the teamcomp
        IF loc_count = 0 THEN
            return_text := 'No players found in the teamcomp';
        ELSEIF loc_count = 1 THEN
            return_text := 'Only 1 player found in the teamcomp instead of 11';
        ELSEIF loc_count < 11 THEN
            return_text := FORMAT('Only %s players found in the teamcomp, instead of 11', loc_count);
        ELSEIF loc_count > 11 THEN
            return_text := FORMAT('%s players found in the teamcomp, instead of 11', loc_count);
        END IF;
    END IF;

    ------ While no errors are found, keep searching for errors
    IF return_text IS NULL THEN
        ------ Check that each player belongs to the specified club
        FOR i IN 1..14 LOOP
            IF loc_players_id[i] IS NOT NULL THEN
                PERFORM id
                FROM players
                WHERE id = loc_players_id[i]
                AND id_club = loc_id_club;

                -- Then the player doesn't belong to the club
                IF NOT FOUND THEN
                    return_text := FORMAT('Player [%s] does not belong to the club', loc_players_id[i]);
                END IF;
            END IF;
        END LOOP;
    END IF;

    ------ Update the error field of the teamcomp to NULL
    UPDATE games_teamcomp SET error = return_text WHERE id = inp_id_teamcomp;

    RETURN return_text;
END;
$function$
;
