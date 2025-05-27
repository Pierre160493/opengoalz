CREATE OR REPLACE FUNCTION trigger_players_handle_retire()
RETURNS TRIGGER AS $$
DECLARE
    descriptions TEXT[] := ARRAY[
        'Retired due to age',
        'Retired due to injury',
        'Retired to pursue a coaching career',
        'Retired to spend more time with family',
        'Retired to focus on personal business',
        'Retired due to health reasons',
        'Retired to become a sports analyst',
        'Retired to travel the world',
        'Retired to write a book',
        'Retired to start a charity foundation',
        'Retired to become a mentor for young players',
        'Retired to pursue higher education',
        'Retired to explore new opportunities'
    ];
    random_description TEXT;
    player_string_parser TEXT;
BEGIN

    player_string_parser := string_parser(inp_entity_type := 'idPlayer', inp_id := NEW.id);

    -- Select a random description from the array
    random_description := descriptions[floor(random() * array_length(descriptions, 1) + 1)::int];
    ------ Insert a new row in the history table
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (NEW.id, NEW.id_club, random_description);

    ------ Send mails to the club to inform them of the death of the player
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        SELECT 
            id AS id_club_to, 'Secretary' AS sender_role, TRUE AS is_club_info,
            player_string_parser || ' has retired' AS title,
            player_string_parser || ' has retired, let''s wish him the best in his future life ! He will stay in the club for now, you can try to convert him as a coach' AS message
        FROM 
            clubs
        WHERE id_coach = NEW.id;

    ------ Reset the player
    UPDATE players SET
        expenses_missed = 0,
        --expenses_target = 0,
        training_points_available = 0, training_points_used = 0
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
