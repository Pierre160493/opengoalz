-- DROP FUNCTION public.generate_new_season();

CREATE OR REPLACE FUNCTION public.generate_new_season()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record of the multiverse
    leagues RECORD; -- Record of the leagues
BEGIN

    -- Loop throuh all multiverses
    FOR multiverse IN (SELECT * FROM multiverses WHERE speed = 1) LOOP

        FOR leagues IN (SELECT * FROM leagues WHERE multiverse_speed = multiverse.speed) LOOP

            -- Generate new season for the league
            PERFORM generate_leagues_games_schedule(
                inp_date_season_start := multiverse.date_season_start,
                inp_multiverse_speed := multiverse.speed,
                inp_id_league := leagues.id,
                inp_array_clubs_id := ARRAY(
                    SELECT id FROM clubs WHERE id_league = leagues.id
                )
            );

        END LOOP; -- End of the loop through leagues

    END LOOP; -- End of the loop through multiverses

END;
$function$
;
