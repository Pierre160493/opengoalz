CREATE OR REPLACE FUNCTION public.trg_generate_games_teamcomp_for_games()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

    -- Generate games teamcomp for the team competitions
    -- Insert into games_team_comp table for the left club
    INSERT INTO games_teamcomp (id_game, id_club) VALUES
    (NEW.game_id, NEW.game_record.id_club_left),
    (NEW.game_id, NEW.game_record.id_club_right);

    RETURN NEW;
END;
$function$
;
