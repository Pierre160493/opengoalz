
------ Returns the 7 team weights for the game
SELECT public.simulate_game_calculate_game_weights(
    (SELECT * 
        FROM public.simulate_game_fetch_player_stats(ARRAY[
            1, 2, 3, NULL, 5, 6, 7, 8, NULL, 10, 11, 12, NULL, 14, 15, 16, 17, 18, 19, 20, 21
        ])),
    ARRAY[0, 0, 0, 0, 0, 0, 0]
);