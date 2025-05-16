-- SQL function to insert a new row into public.transfers_embodied_players_offers

CREATE OR REPLACE FUNCTION public.transfers_handle_new_embodied_player_offer(
    inp_id_player bigint,
    inp_id_club bigint,
    inp_expenses_offered smallint,
    inp_date_limit timestamp with time zone DEFAULT NULL,
    inp_number_season smallint DEFAULT 1,
    inp_comment_for_player text DEFAULT NULL,
    inp_comment_for_club text DEFAULT NULL
)
RETURNS bigint AS $$
DECLARE
    new_id bigint;
    current_user_name text;
BEGIN
    -- Get the PostgreSQL session user (database user)
    current_user_name := session_user;

    RAISE EXCEPTION 'Current user: %', current_user_name;

    -- Check that the bidding club belongs to the user (assuming clubs table has a user_name or user_id column)
    IF NOT EXISTS (
        SELECT 1
        FROM clubs
        WHERE id = inp_id_club
          AND (username = current_user_name)
    ) THEN
        RAISE EXCEPTION 'Club % does not belong to the current user: %', inp_id_club, current_user_name;
    END IF;

    INSERT INTO public.transfers_embodied_players_offers (
        id_player,
        id_club,
        expenses_offered,
        date_limit,
        number_season,
        comment_for_player,
        comment_for_club
    ) VALUES (
        inp_id_player,
        inp_id_club,
        inp_expenses_offered,
        inp_date_limit,
        inp_number_season,
        inp_comment_for_player,
        inp_comment_for_club
    )
    RETURNING id INTO new_id;

    RETURN new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
