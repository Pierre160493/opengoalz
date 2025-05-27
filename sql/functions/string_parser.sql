CREATE OR REPLACE FUNCTION string_parser(
    inp_entity_type TEXT,
    inp_id BIGINT DEFAULT NULL,
    inp_uuid_user UUID DEFAULT NULL,
    inp_text TEXT DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
    loc_record RECORD;
    loc_name TEXT;
BEGIN
    -- Validate input based on entity type
    CASE inp_entity_type
        WHEN 'idPlayer', 'idClub', 'idLeague', 'idGame', 'idTeamcomp', 'idCountry' THEN
            IF inp_id IS NULL THEN
                -- RAISE EXCEPTION 'inp_id must be provided for entity type %', inp_entity_type;
                RETURN 'NOT FOUND';
            END IF;
        WHEN 'uuidUser' THEN
            IF inp_uuid_user IS NULL THEN
                RAISE EXCEPTION 'inp_uuid_user must be provided for entity type uuidUser';
            END IF;
        ELSE
            RAISE EXCEPTION 'Invalid entity type: %', inp_entity_type;
    END CASE;

    -- Process based on entity type
    CASE inp_entity_type
        WHEN 'idPlayer' THEN
            SELECT id::TEXT, player_get_full_name(id) AS full_name INTO loc_record FROM players WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.full_name);
        WHEN 'idClub' THEN
            SELECT id::TEXT, name INTO loc_record FROM clubs WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idLeague' THEN
            SELECT id::TEXT, name INTO loc_record FROM leagues WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idGame' THEN
            SELECT id::TEXT, 'S' || season_number || 'W' || week_number || ' game' AS name INTO loc_record FROM games WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idTeamcomp' THEN
            SELECT id::TEXT, 'S' || season_number || 'W'  || week_number || ' teamcomp' AS name INTO loc_record FROM teamcomps WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idCountry' THEN
            SELECT id::TEXT, name INTO loc_record FROM countries WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'uuidUser' THEN
            SELECT uuid_user::TEXT AS id, username AS name INTO loc_record FROM profiles WHERE uuid_user = inp_uuid_user;
            loc_name := COALESCE(inp_text, loc_record.name);
        ELSE
            RAISE EXCEPTION 'Invalid entity type: %', inp_entity_type;
    END CASE;

    RETURN '{' || inp_entity_type || ':' || loc_record.id || ',' || loc_name || '}';
END;
$$ LANGUAGE plpgsql;