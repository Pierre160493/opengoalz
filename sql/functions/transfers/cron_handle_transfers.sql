-- DROP FUNCTION public.cron_handle_transfers();

CREATE OR REPLACE FUNCTION public.cron_handle_transfers()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    multiverse RECORD; -- Record variable to store the multiverses
BEGIN

    -- Query to select rows to process (bids finished and player is not currently playing a game)
    FOR multiverse IN (
        SELECT * FROM multiverses
    ) LOOP

        ------ Handle the transfers
        PERFORM transfers_handle_transfers(multiverse.id);        
    END LOOP;

END;
$function$
;
