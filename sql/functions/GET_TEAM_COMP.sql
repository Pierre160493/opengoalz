------------ Get teamcomp by returning a table of 11+6 players and their positions
CREATE OR REPLACE FUNCTION get_team_comp(
    inp_id_game INTEGER DEFAULT NULL, -- The id of the game to simulate
    inp_id_club INTEGER -- The id of the club to get the team composition for
)
RETURNS TABLE (
    id_player INTEGER,
    id_position INTEGER
) AS $$
DECLARE
    i INTEGER; -- Loop counter for iterations through the loop and checks
    loc_record RECORD; -- Record to store the result of the SELECT statement
BEGIN

    ------------ Checks
    ------  Check if the game exists and get the count of rows where id = inp_id_game
    SELECT COUNT(*) INTO i FROM games WHERE id = inp_id_game; -- Get the count of rows where id = inp_id_game and store it in i
    IF i = 0 THEN -- If the count of rows where id = inp_id_game is 0, then it doesn't exist
        RAISE EXCEPTION 'Game with id % does not exist', inp_id_league;
    ELSIF i > 1 THEN -- If the count of rows where id = inp_id_game is greater than 1, then there are duplicates
        RAISE EXCEPTION 'Game with id % has duplicates', inp_id_league;
    END IF;

    ------------ Initialization
    ------ Get all the orders for the game from the club
    FOR loc_record IN
        SELECT id_player, id_position FROM games_teamcomp
            WHERE id_game = inp_id_game AND id_club = inp_id_club
    LOOP
        -- Process each row here
        id_player := loc_record.id_player;
        id_position := loc_record.id_position;
        -- Return the row
        RETURN NEXT;
    END LOOP;

    ------------ Processing
    
END;
$$ LANGUAGE plpgsql;