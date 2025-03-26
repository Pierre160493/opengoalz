CREATE OR REPLACE FUNCTION multiverse_launch_new()
RETURNS TRIGGER AS $$
DECLARE
    loc_interval_1_week INTERVAL := INTERVAL '7 days' / NEW.speed; -- Time for a week in a given multiverse
BEGIN

    ------ Initialize the multiverse row
    UPDATE multiverses SET
        date_season_end = date_season_start + (loc_interval_1_week * 14),
        season_number = 1, week_number = 1, day_number = 1,
        cash_printed = 0,
        last_run = now(), error = NULL
        WHERE id = NEW.id;

    ------ Generate leagues, clubs and players
    PERFORM multiverse_initialize_leagues_teams_and_players(NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;