
-- INSERT INTO public.multiverses (id, date_season_start, speed, name) VALUES 
-- (1, date_trunc('week', NOW()) - INTERVAL '1 week' + INTERVAL '5 days 20 hours', 1, 'The Original'), -- 1 game per week
-- (2, date_trunc('week', NOW()) - INTERVAL '1 week' + INTERVAL '5 days 20 hours', 2, 'The Second'), -- 2 games per week
-- (3, date_trunc('week', NOW()) + INTERVAL '20 hours', 7, 'The Lucky Seven'), -- 7 [games.week-1] = 1 [games.day-1]
-- (4, date_trunc('week', NOW()) + INTERVAL '20 hours', 14, 'The Double Seven'), -- 14 [games.week-1] = 2 [games.day-1]
-- (5, date_trunc('hour', NOW()), 168, 'The Very Fast'), -- Every hour
-- (6, date_trunc('hour', NOW()), 1008, 'The Ultra Fast'); -- Every 10 minutes

INSERT INTO public.multiverses (id, date_season_start, speed, name) VALUES 
(2, date_trunc('day', NOW()), 56, 'Every 3 hours');