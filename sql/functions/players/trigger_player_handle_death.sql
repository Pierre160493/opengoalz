CREATE OR REPLACE FUNCTION trigger_players_handle_death()
RETURNS TRIGGER AS $$
DECLARE
    descriptions TEXT[] := ARRAY[
        'Died of natural causes',
        'Died of a disease',
        'Died of covid-19',
        'Died of an infection',
        'Died of a heart attack',
        'Died of a stroke',
        'Died of a car accident',
        'Died of a plane crash',
        'Died of a train accident',
        'Died of a boat accident',
        'Died of a lightning strike',
        'Died of a meteorite impact',
        'Died of a volcanic eruption'
    ];
    random_description TEXT;
BEGIN

    ------ Remove the player from the club if he was coaching it
    UPDATE clubs SET
        id_coach = NULL
    WHERE id_coach = NEW.id;

    -- Select a random description from the array
    random_description := descriptions[floor(random() * array_length(descriptions, 1) + 1)::int];
    ------ Insert a new row in the history table
    INSERT INTO players_history (id_player, id_club, description)
    VALUES (NEW.id, NEW.id_club, random_description);

    ------ Send mails to the club to inform them of the death of the player
    INSERT INTO mails (id_club_to, sender_role, is_club_info, title, message)
        SELECT 
            id AS id_club_to, 'Secretary' AS sender_role, TRUE AS is_club_info,
            'Our caoch has died' AS title,
            'Our coach has died' AS message
        FROM 
            clubs
        WHERE id_coach = NEW.id;

    ------ Reset the player
    UPDATE players SET
        id_club = NULL,
        performance_score = 0,
        expenses_payed = 0, expenses_expected = 0, expenses_missed = 0, expenses_target = 0,
        keeper = 0, defense = 0, passes = 0, playmaking = 0, winger = 0, scoring = 0, freekick = 0,
        motivation = 0, form = 0, stamina = 0, energy = 0,
        training_points_available = 0, training_points_used = 0,
        coef_coach = 0, coef_scout = 0
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
