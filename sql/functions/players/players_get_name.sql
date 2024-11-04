CREATE OR REPLACE FUNCTION public.get_player_name(id_player bigint)
RETURNS text
LANGUAGE plpgsql
AS $function$
DECLARE
    player_name text;
BEGIN
    SELECT first_name || ' ' || UPPER(last_name) || 
           COALESCE(' (' || surname || ')', '') INTO player_name
    FROM players
    WHERE id = id_player;

    RETURN player_name;
END;
$function$;