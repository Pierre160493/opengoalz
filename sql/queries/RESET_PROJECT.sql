SELECT reset_project();

WITH stats AS (
    SELECT 50 AS value
)
UPDATE players
SET keeper = stats.value,
    defense = stats.value,
    playmaking = stats.value,
    passes = stats.value,
    scoring = stats.value,
    freekick = stats.value,
    winger = stats.value
FROM stats
WHERE id_club != 1;

UPDATE players SET keeper = 100, defense = 100, playmaking = 100, passes = 100, scoring = 100, freekick = 100, winger = 100
WHERE id_club = 1;

EXPLAIN ANALYZE SELECT simulate_games();



