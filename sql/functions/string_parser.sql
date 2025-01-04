CREATE OR REPLACE FUNCTION string_parser(
    inp_id BIGINT,
    entity_type TEXT,
    string TEXT DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
    loc_record RECORD;
BEGIN
    CASE entity_type
        WHEN 'player' THEN
            SELECT id, player_get_full_name(id) AS full_name INTO loc_record FROM players WHERE id = inp_id;
            RETURN '{idPlayer:' || loc_record.id || ',' || loc_record.full_name || '}';
        WHEN 'club' THEN
            SELECT id, name INTO loc_record FROM clubs WHERE id = inp_id;
            RETURN '{idClub:' || loc_record.id || ',' || loc_record.name || '}';
        WHEN 'league' THEN
            SELECT id, name INTO loc_record FROM leagues WHERE id = inp_id;
            RETURN '{idLeague:' || loc_record.id || ',' || loc_record.name || '}';
        WHEN 'game' THEN
            SELECT id, 'S' || season_number || 'W' || week_number || ' game' AS name INTO loc_record FROM games WHERE id = inp_id;
            RETURN '{idGame:' || loc_record.id || ',' || loc_record.name || '}';
        WHEN 'teamcomp' THEN
            SELECT id, 'S' || season_number || 'W'  || week_number || ' teamcomp' AS name INTO loc_record FROM teamcomps WHERE id = inp_id;
            RETURN '{idTeamcomp:' || loc_record.id || ',' || loc_record.name || '}';
        -- WHEN 'user' THEN
        --     SELECT id, 'league' || level || '.' || number AS name INTO loc_record FROM leagues WHERE id = inp_id;
        --     RETURN '{idUser:' || id || '}';
        -- WHEN 'continent' THEN
        --     -- ...existing code...
        --     RETURN '{continent:' || id || '}';
        ELSE
            RAISE EXCEPTION 'Invalid entity type: %', entity_type;
    END CASE;
END;
$$ LANGUAGE plpgsql;