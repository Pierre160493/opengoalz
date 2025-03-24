CREATE TRIGGER multiverse_after_insert_launch_new
AFTER INSERT ON multiverses
FOR EACH ROW
EXECUTE FUNCTION multiverse_launch_new();