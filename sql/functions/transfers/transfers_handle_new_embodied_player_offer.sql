-- SQL function to insert a new row into public.transfers_embodied_players_offers

CREATE OR REPLACE FUNCTION public.transfers_handle_new_embodied_player_offer(
    inp_id_player bigint,
    inp_id_club bigint,
    inp_expenses_offered smallint,
    inp_date_limit timestamp with time zone DEFAULT NULL,
    inp_number_season smallint DEFAULT 1,
    inp_comment_for_player text DEFAULT NULL,
    inp_comment_for_club text DEFAULT NULL)
RETURNS void AS $$
DECLARE
    rec_player RECORD; -- Player record
    rec_club RECORD; -- Club record
    new_id bigint;
    current_user_name text;
BEGIN

    ------ CHECKS
    IF inp_id_player IS NULL THEN
        RAISE EXCEPTION 'Player id cannot be NULL';
    ELSIF inp_id_club IS NULL THEN
        RAISE EXCEPTION 'Club id cannot be null !';
    ELSIF inp_expenses_offered IS NULL THEN
        RAISE EXCEPTION 'Expenses offered cannot be NULL !';
    ELSIF inp_expenses_offered < 0 THEN
        RAISE EXCEPTION 'Expenses offered cannot be negative !';
    ELSIF inp_number_season < 1 THEN
        RAISE EXCEPTION 'Number of seasons cannot be lower than 1 !';
    ELSIF inp_number_season > 5 THEN
        RAISE EXCEPTION 'Number of seasons cannot be higher than 5 !';
    END IF;

    ------ Get the club record
    SELECT * INTO rec_club FROM clubs WHERE id = inp_id_club;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Club with id % does not exist', inp_id_club;
    END IF;

    ------ Get the player record
    SELECT players.*, player_get_full_name(players.id) AS full_name, multiverses.speed INTO rec_player
    FROM players
    LEFT JOIN clubs ON clubs.id = players.id_club
    JOIN multiverses ON multiverses.id = players.id_multiverse
    WHERE players.id = inp_id_player;

    ------ CHECKS on the player record
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Player with id % does not exist', inp_id_player;
    ELSIF rec_player.id_multiverse != rec_club.id_multiverse THEN
        RAISE EXCEPTION 'Player and club must be in the same multiverse';
    ELSIF inp_expenses_offered < rec_player.expenses_target * 0.5 THEN
        RAISE EXCEPTION 'Expenses offered cannot be lower than 50%% of the target expenses (%)', rec_player.expenses_target;
    ELSIF inp_expenses_offered > rec_player.expenses_target * 1.5 THEN
        RAISE EXCEPTION 'Expenses offered cannot be higher than 150%% of the target expenses (%)', rec_player.expenses_target; 
    END IF;

    ------ Delete the previous offer if it exists
    DELETE FROM public.transfers_embodied_players_offers
    WHERE id_player = inp_id_player
        AND id_club = inp_id_club
        AND is_accepted IS NULL;

    ------ Insert the new offer
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
    );

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
