# opengoalz

Football Management Game using postgresql (with supabase) as backend and flutter as frontend, all in open source
Inspired by Hattrick and Football Manager, the goal is to be more realistic and dynamic than Hattrick and being able to play online on the computer and phone (compared to Football Manager)

## Reasons to make this game

HT is not really realistic, you need to chose what to train, that's not what happens in real life.

Multiple game speeds:

- Speed1 : 1 game per weak (default)

- Speed2: 2 games per weak

- Speed7: 7 games per weak (1 per day)

- Speed14: 14 games per weak (2 per day)

## TODO

### Default teamcomps (EASY)

Possiblity of setting multiple default teamcomps

### Young Players Management (LONG)

Find an idea for example each league and country spawn young players and then bidding between clubs to get them (with money and points from their rankings)

### Money Management (LONG)

Find an idea for recycling money in a closed loop. Salaries and expenses would be split and returned to the clubs according to their rankings

Starting budget: 140 000 (10 000 per week)
Players have a salary (it's amateur so it's more some kind of expanses and bonuses) of around 100 per weak, so a team of 20 players amount for around 2 000 per week.

Staff, trainer and material (balls, jerseys, bus etc...) amount for 1000 per weak

All this money goes to the common pot league and it will be redistributed as bonuses and sponsors at the end of the season.

Each week 1% of each club budget is taken for the common pot league (this is to discourage storing too much money).

10% of each transfer goes to the common pot league

Then at the end of each season, leagues share back the common pot according to the rankings. A percentage of the common pot is also shared between leagues.

### Display Events of Current Games according to time (NORMAL)

### Game Simulation Extra Cases (EASY)

Handle injuries, subs and free kick

### Log players events (for example goals, injuries) (EASY)

### Handle training and staff (MEDIUM)

### Others small development and corrections

- At first connection, after login, the page crashes

### Select followed (or favorite) clubs and players and access it from the UserPage (EASY)

Make a table linking id_clubs or id_player to id_user (in profiles table)

### Mode Solo like FM where you can advance at your speed

Have more multiverses (can start becoming heavy for the db)
