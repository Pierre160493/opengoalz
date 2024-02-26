CREATE OR REPLACE FUNCTION reset_sequences_for_tables()
RETURNS VOID AS $$
DECLARE
    table_name TEXT;
BEGIN
    -- List of table names to alter sequences
    FOR table_name IN
        SELECT unnest(ARRAY['clubs', 'players', 'leagues', 'games']) -- Add your table names here
    LOOP
        -- Construct and execute the ALTER SEQUENCE command for each table
        EXECUTE 'ALTER SEQUENCE ' || pg_get_serial_sequence(table_name, 'id') || ' RESTART WITH 1';
    END LOOP;
END $$ LANGUAGE plpgsql;

select reset_sequences_for_tables();