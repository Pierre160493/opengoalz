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

## Naming Conventions

When naming PostgreSQL tables, it is recommended to use plural names to indicate that the table contains multiple records of the same type. For example:

- Use `clubs` instead of `club`
- Use `players` instead of `player`

This convention helps to maintain consistency and clarity in the database schema.

## Custom Ranking System

To avoid point inflation, you can implement a custom ranking system where each club starts with a fixed amount of ranking points, for example, 100 points. The points are exchanged between clubs based on the game results. Here is a basic outline of how this system can work:

1. **Initial Points**: Each club starts with 100 ranking points. The points are stored in a column named `ranking_points` in the clubs table.

2. **Game Result**: After each game, the winner takes a certain number of points from the loser. The number of points exchanged can be based on the difference in ranking points between the two clubs, the result of the game (number of goals), and the importance of the game.

3. **Points Calculation**:
   - If Club A (with `points_A`) wins against Club B (with `points_B`), the points exchanged can be calculated as:

     ```
     points_exchanged = k * (1 - (points_A / (points_A + points_B))) * goal_factor * importance_factor
     ```

     where `k` is a constant factor that determines the maximum points that can be exchanged in a game, `goal_factor` is a multiplier based on the goal difference, and `importance_factor` is a coefficient based on the importance of the game. The result is then rounded to the highest integer:

     ```
     points_exchanged = Math.ceil(points_exchanged)
     ```

   - If Club B wins, the calculation is similar:

     ```
     points_exchanged = k * (1 - (points_B / (points_A + points_B))) * goal_factor * importance_factor
     points_exchanged = Math.ceil(points_exchanged)
     ```

4. **Goal Factor**:
   - The `goal_factor` can be calculated as:

     ```
     goal_factor = 1 + (goal_difference / max_goals)
     ```

     where `goal_difference` is the absolute difference in goals scored by the two clubs, and `max_goals` is a normalization factor (e.g., the maximum number of goals considered for the factor).

5. **Importance Factor**:
   - The `importance_factor` can be assigned based on the type of game:
     - Friendly match: `importance_factor = 0.5`
     - League match: `importance_factor = 1.0`
     - Cup match: `importance_factor = 1.5`
     - International match: `importance_factor = 2.0`

6. **Update Points**:
   - If Club A wins:

     ```
     points_A += points_exchanged
     points_B -= points_exchanged
     ```

   - If Club B wins:

     ```
     points_B += points_exchanged
     points_A -= points_exchanged
     ```

7. **Draws**: In case of a draw, no points are exchanged, or a smaller number of points can be exchanged to reflect the draw.

This system ensures that the total number of ranking points in the league remains constant, preventing inflation. The points exchanged depend on the relative strengths of the clubs, the game result, and the importance of the game, making the system dynamic and competitive.

## TODO

### Money Management (LONG)

Find an idea for recycling money in a closed loop. Salaries and expenses would be split and returned to the clubs according to their rankings

Starting budget: 140 000 (10 000 per week)
Players have a salary (it's amateur so it's more some kind of expanses and bonuses) of around 100 per weak, so a team of 20 players amount for around 2 000 per week.

Staff, trainer and material (balls, jerseys, bus etc...) amount for 1000 per weak

All this money goes to the common pot league and it will be redistributed as bonuses and sponsors at the end of the season.

Each week 1% of each club budget is taken for the common pot league (this is to discourage storing too much money).

Then at the end of each season, leagues share back the common pot according to the rankings. A percentage of the common pot is also shared between leagues.

### Display Events of Current Games according to time (NORMAL)

### Game Simulation Extra Cases (EASY)

Handle injuries, subs and free kick

### Handle training and staff (MEDIUM)

Create staff table where staff have some mental stats like loyalty, seriousness, motivation, discipline, and communication skills

### Select followed (or favorite) clubs and players and access it from the UserPage (EASY)

Make a table linking id_clubs or id_player to id_user (in profiles table)

### Mode Solo like FM where you can advance at your speed (HARD)

Have more multiverses (can start becoming heavy for the db)
