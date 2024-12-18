-- DROP FUNCTION public.teamcomps_remove_player_from_teamcomps(int8);

CREATE OR REPLACE FUNCTION public.player_change_shirt_number_and_notes(
    inp_id_player int8,
    inp_id_club int8,
    inp_shirt_number int DEFAULT NULL,
    inp_notes TEXT DEFAULT NULL::TEXT,
    inp_notes_small TEXT DEFAULT NULL::TEXT)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN

    ------ CHECKS: General
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ELSIF inp_id_club IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be NULL';
    END IF;


    IF (SELECT id_club FROM players WHERE id = inp_id_player) != inp_id_club THEN
        RAISE EXCEPTION 'The player does not belong to the club';
    END IF;

    ------ Shirt number
    IF inp_shirt_number IS NOT NULL THEN
        IF inp_shirt_number < 0 THEN
            RAISE EXCEPTION 'Shirt number cannot be negative';
        ELSIF inp_shirt_number > 99 THEN
            RAISE EXCEPTION 'Shirt number cannot be higher than 99';
        ---- Check: Shirt number should be unique in the club
        -- ELSIF inp_shirt_number IN (
        --     SELECT p.shirt_number
        --     FROM players p
        --     JOIN players p2 ON p.id_club = p2.id_club
        --     WHERE p2.id = inp_id_player
        --       AND p.id != p2.id
        -- ) THEN

        --     ---- If we force the value, remove the other player's shirt number
        --     IF inp_force = TRUE THEN
        --         -- Remove the shirt number from the other player
        --         UPDATE players
        --             SET shirt_number = NULL
        --         WHERE id_club = inp_id_club AND shirt_number = inp_shirt_number;

        --     ELSE
        --         -- Raise an exception
        --         RAISE EXCEPTION 'Shirt number % is already taken by %', inp_shirt_number, (SELECT player_get_full_name(id) FROM players WHERE shirt_number = inp_shirt_number AND id_club = inp_id_club);
        
        --     END IF;
        END IF;

    ---- Update the shirt number of the player and remove it from others in the same club
    UPDATE players
    SET shirt_number =
        CASE
            WHEN id = inp_id_player THEN inp_shirt_number
            ELSE NULL
        END
    WHERE id_club = inp_id_club
    AND (shirt_number = inp_shirt_number OR id = inp_id_player);

    ------ Notes
    IF inp_notes IS NOT NULL THEN
        UPDATE players
            SET notes = inp_notes
        WHERE id = inp_id_player;
    END IF;

    ------ Notes small
    IF inp_notes_small IS NOT NULL THEN
        IF LENGTH(inp_notes_small) > 6 THEN
            RAISE EXCEPTION 'The small notes cannot exceed 6 characters';
        END IF;

        UPDATE players
            SET notes_small = inp_notes_small
        WHERE id = inp_id_player;
    END IF;

END;
$function$
;
