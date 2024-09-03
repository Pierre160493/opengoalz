-- DROP FUNCTION public.club_handle_new_user_asignement();

CREATE OR REPLACE FUNCTION public.club_handle_new_user_asignement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  teamcomp RECORD;
BEGIN

  ------ Check that the user can have an additional club
   
  IF ((SELECT COUNT(*) FROM clubs WHERE username = NEW.username) >=
    (SELECT number_clubs_available FROM profiles WHERE username = NEW.username)
    ) THEN
      RAISE EXCEPTION 'You can not have an additional club assigned to you';
  END IF;

  ------ Check that it's the last level league of the continent
  IF (
    SELECT level FROM leagues WHERE id = NEW.id_league) =
    (SELECT max(LEVEL) FROM leagues WHERE continent = NEW.continent AND id_multiverse = NEW.id_multiverse) THEN
      RAISE EXCEPTION 'You can not assign a user to a league that is not of the last level';
  END IF;

  -- Log history
  INSERT INTO clubs_history (id_club, description)
  VALUES (NEW.id, 'User ' || NEW.username || ' has been assigned to the club');

  -- Update the club row
  UPDATE clubs SET can_update_name = TRUE WHERE id = NEW.id;

  ------ The players of the old club become free players
  -- Log the history of the players
  INSERT INTO players_history (id_player, id_club, description)
  SELECT id, id_club, 'Player has been released from the club because a new onwer took control'
  FROM players WHERE id_club = NEW.id;
  
  -- Release the players
  UPDATE players SET id_club = NULL WHERE id_club = NEW.id;

  -- Reset the default teamcomps of the club to NULL everywhere
  FOR teamcomp IN
    SELECT * FROM games_teamcomp WHERE id_club = NEW.id AND season_number = 0
  LOOP
    PERFORM teamcomps_copy_previous(inp_id_teamcomp := teamcomp.id, INP_SEASON_NUMBER := - 999);
  END LOOP;

  -- Generate the new team of the club
  PERFORM club_create_players(inp_id_club := NEW.id);

  -- Return the new record to proceed with the update
  RETURN NEW;
END;
$function$
;
