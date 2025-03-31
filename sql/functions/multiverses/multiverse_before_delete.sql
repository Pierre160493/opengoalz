CREATE OR REPLACE FUNCTION multiverse_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Starting controlled deletion for multiverse % (%)', OLD.id, OLD.name;
    
    -- Lock the multiverse table to prevent concurrent operations
    LOCK TABLE multiverses IN SHARE MODE;
    RAISE NOTICE 'Acquired exclusive lock on multiverses table';
    
    DELETE from games WHERE id_multiverse = OLD.id;
    -- DELETE from players WHERE id_multiverse = OLD.id;
    DELETE from clubs WHERE id_multiverse = OLD.id;
    
    -- The original DELETE statement will handle the multiverse row itself
    RAISE NOTICE 'Finished cleaning up data for multiverse % (%)', OLD.id, OLD.name;
    
    -- Return OLD to allow the original DELETE to proceed
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;