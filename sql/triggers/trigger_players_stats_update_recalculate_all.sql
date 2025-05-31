CREATE OR REPLACE FUNCTION public.trigger_players_stats_update_recalculate_all()
RETURNS trigger AS $function$
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
$function$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS trg_update_performance_score ON players;

CREATE TRIGGER trg_update_performance_score
AFTER INSERT OR UPDATE OF
    keeper,
    defense,
    playmaking,
    passes,
    scoring,
    freekick,
    winger,
    motivation,
    form,
    stamina,
    experience,
    loyalty,
    leadership,
    discipline,
    communication,
    composure,
    teamwork
ON players
FOR EACH ROW
EXECUTE FUNCTION public.trigger_players_stats_update_recalculate_all();
