CREATE OR REPLACE FUNCTION string_parser(
    inp_id BIGINT,
    inp_entity_type TEXT,
    inp_text TEXT DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
    loc_record RECORD;
    loc_name TEXT;
BEGIN
    CASE inp_entity_type
        WHEN 'idPlayer' THEN
            SELECT id, player_get_full_name(id) AS full_name INTO loc_record FROM players WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.full_name);
        WHEN 'idClub' THEN
            SELECT id, name INTO loc_record FROM clubs WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idLeague' THEN
            SELECT id, name INTO loc_record FROM leagues WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idGame' THEN
            SELECT id, 'S' || season_number || 'W' || week_number || ' game' AS name INTO loc_record FROM games WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idTeamcomp' THEN
            SELECT id, 'S' || season_number || 'W'  || week_number || ' teamcomp' AS name INTO loc_record FROM teamcomps WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        WHEN 'idCountry' THEN
            SELECT id, name INTO loc_record FROM countries WHERE id = inp_id;
            loc_name := COALESCE(inp_text, loc_record.name);
        -- WHEN 'user' THEN
        --     SELECT id, 'league' || level || '.' || number AS name INTO loc_record FROM leagues WHERE id = inp_id;
        --     RETURN '{idUser:' || id || '}';
        -- WHEN 'continent' THEN
        --     -- ...existing code...
        --     RETURN '{continent:' || id || '}';
        ELSE
            RAISE EXCEPTION 'Invalid entity type: %', inp_entity_type;
    END CASE;
    RETURN '{' || inp_entity_type || ':' || loc_record.id || ',' || loc_name || '}';
END;
$$ LANGUAGE plpgsql;