-- DROP FUNCTION public.trigger_players_stats_update_recalculate_all();

CREATE OR REPLACE FUNCTION public.trigger_players_stats_update_recalculate_all()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

-- Update the players table with recalculated values
UPDATE players SET
    performance_score_real = players_calculate_player_best_weight(
        ARRAY[
            NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.scoring, NEW.freekick, NEW.winger,
            NEW.motivation, NEW.form, NEW.experience, 100, NEW.stamina
        ]
    ),
    performance_score_theoretical = players_calculate_player_best_weight(
        ARRAY[
            NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.scoring, NEW.freekick, NEW.winger,
            100, 100, NEW.experience, 100, 100
        ]
    ),
    expenses_target = FLOOR(
        50 +
        1 * calculate_age((SELECT speed FROM multiverses WHERE id = NEW.id_multiverse), NEW.date_birth) +
        GREATEST(NEW.keeper, NEW.defense, NEW.playmaking, NEW.passes, NEW.winger, NEW.scoring, NEW.freekick) / 2 +
        (NEW.keeper + NEW.defense + NEW.passes + NEW.playmaking + NEW.winger + NEW.scoring + NEW.freekick) / 4 +
        (NEW.coef_coach + NEW.coef_scout) / 2
    ),
    coef_coach = FLOOR(
        (NEW.loyalty + 2 * NEW.leadership + 2 * NEW.discipline + 2 * NEW.communication + 2 * NEW.composure + NEW.teamwork) / 10
    ),
    coef_scout = FLOOR(
        (2 * NEW.loyalty + NEW.leadership + NEW.discipline + 3 * NEW.communication + 2 * NEW.composure + NEW.teamwork) / 10
    )
WHERE id = NEW.id;

RETURN NULL;
END;
$function$
;
