CREATE TYPE public.game_context AS (
	loc_array_players_id_left _int8,
	loc_array_players_id_right _int8,
	loc_array_substitutes_left _int4,
	loc_array_substitutes_right _int4,
	loc_matrix_player_stats_left _float4,
	loc_matrix_player_stats_right _float4,
	loc_array_team_weights_left _float4,
	loc_array_team_weights_right _float4,
	loc_period_game int4,
	loc_minute_game int4,
	loc_date_start_period timestamp);