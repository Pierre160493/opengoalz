-- Reset project
SELECT reset_project();

-- Set stats for all players
WITH stats AS (
    SELECT 75 AS value
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

SELECT simulate_games();

SELECT simulate_game(7);


SELECT populate_games_team_comp(7, 1);

    SELECT id FROM players
        WHERE id_club = 1
        AND id NOT IN (1, 2)
        ORDER BY random()
        LIMIT 5;


    
SELECT public.simulate_game_calculate_game_weights(
    (SELECT * 
        FROM public.simulate_game_fetch_player_stats(ARRAY[
            1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21
        ])),
    ARRAY[0, 0, 0, 0, 0, 0, 0]
);


SELECT simulate_game_fetch_players_id(46,1);



SELECT simulate_game(46);


    
SELECT public.simulate_game_calculate_game_weights(
    (SELECT * 
        FROM public.simulate_game_fetch_player_stats(ARRAY[
            1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21
        ])),
    ARRAY[0, 0, 0, 0, 0, 0, 0]
);


SELECT simulate_game_fetch_players_id(46,1);

SELECT simulate_game_goal_opportunity(
    inp_id_game := 1,
    inp_id_club_attack := 1,
    inp_id_club_defense := 1,
    inp_array_team_weights_attack := ARRAY[1, 2, 3, 4, 5, 6, 7],
    inp_array_team_weights_defense := ARRAY[1, 2, 3, 4, 5, 6, 7],
    inp_array_player_ids_attack := ARRAY[1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21],
    inp_array_player_ids_defense := ARRAY[1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21],
    inp_matrix_player_stats_attack := (SELECT * 
        FROM public.simulate_game_fetch_player_stats(ARRAY[
            1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21
        ])),
    inp_matrix_player_stats_defense := (SELECT * 
        FROM public.simulate_game_fetch_player_stats(ARRAY[
            1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21
        ]))
    );