
SET statement_timeout = '15min';

SELECT reset_project();


SELECT teamcomp_check_or_correct_errors(757, false)

SELECT main()


SELECT * FROM games_teamcomp WHERE id_club = 1 AND season_number = 1 AND week_number IN (1,2,3,4,5) ORDER BY season_number, week_number



