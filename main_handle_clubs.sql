UPDATE clubs SET
    -- ...existing code...
    staff_weight = GREATEST(0, (staff_weight +
        (expenses_staff_applied * (1 +
            COALESCE((SELECT coef_coach FROM players WHERE players.id = clubs.id_coach), 0) / 100.0)
        )) * 0.5),
    -- ...existing code...
WHERE id_multiverse = inp_multiverse.id
