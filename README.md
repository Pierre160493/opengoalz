# OpenGoalz

OpenGoalz is an open-source football management game of amateur football. You manage all of the club's decisions in order to climb the ranks and be the best club ! The goal is to create a more realistic and dynamic experience (than Hattrick or FM), playable online against other managers.

## Game Structure

### Seasons and Games

- **Season Length**: 14 weeks (10 league games and 4 interseason games for promotion and cups)
- **Game Frequency**: One game per week

### Continents and Leagues

Each club belongs to a country, and each country belongs to one of 6 continents:

- Africa
- Europe
- Asia
- Oceania
- North America
- South America

Each continent is made up of multiple leagues (in a triangulare structure where the top leagues have two lower leagues).

- 1 level 1 league
- 2 level 2 leagues
- 4 level 3 leagues
- 8 level 4 leagues
- ... and so on, depending on the number of active clubs in the multiverse

Like the following structure:

      1
     / \
    /   \
   2     -2
  / \    / \
 3  -3  4  -4

Each league contains 6 clubs.

### End of Season

#### Top Level Leagues

- **1st Place**: Plays the International Champions Cup (between the 6 champions of each level 1 league of each continent)
- **2nd Place**: Plays the 2nd International Cup (between the 6 second-place teams of each continent)
- **3rd Place**: Plays the 3rd International Cup (between the 6 third-place teams of each continent)
- **4th Place**: Plays a barrage game against the winner of the Second Barrage
- **5th Place**: Plays a barrage game against the loser of the First Barrage
- **6th Place**: Swaps place with the winner of the First Barrage

#### Other Leagues

- **1st Place**: Plays the First Barrage
- **2nd and 3rd Places**: Play the Second Barrage
- **4th, 5th, and 6th Places**: Same as the top-level league

## Transfer Handling

### Transfer Process

Transfers in OpenGoalz are handled through a bidding system. Here are the key points:

- **Bidding Time**: Players are available for bidding for a specific period.
- **Minimum Bid**: The minimum bid amount is 100.
- **Bid Increments**: New bids must be at least 1% higher than the previous bid.
- **Club Cash**: Clubs must have enough cash to place a bid.

### Transfer Outcomes

- **No Bids**: If no bids are made, the player remains in their current club or becomes clubless (if he was fired or if he asked to leave)
- **Player Sold**: If a bid is successful, the player is transferred to the bidding club, and the selling club receives the bid amount.

### Player Status

- **Clubless Players**: Clubless players can be bid on and will join the highest bidding club. Each week, if a clubless has not been bought, his expected_expenses will drop, rendering him more attractive
- **Club Players**: Players currently in a club can be transferred to another club through the bidding process.

### Scouting mechanic

With your scout, you have the possiblity of poaching other players (especially players from bot clubs).
If you are interested in a player, you can ask your scout to start using some of the club's scout strength to start influencing the player to come to your club by undermining his motivation.
Eventually the player will lack motivation and ask to leave the club. You can then try to buy him and you will get a reduction of the player salary because he wants to be in your club.

## Club Finances Handling

### Weekly Financial Updates

Each week, the game updates the financial status of each club. Here are the key points:

- **Staff and Scouting Expenses**: Club's staff and scouting expenses are applied based on target value and available cash.
- **Player Expenses**: Players' expenses are paid based on the club's available cash and the expenses ratio.
- **Debt Handling**: Clubs in debt receive notifications, and their staff, scouts, and players are not paid.
- **Tax**: Clubs pay a tax of 1% of their available cash.

### Player Management

- **Minimum Players**: Clubs must have at least 11 players. If a club has fewer than 11 players:

- Normal Clubs: Game is forfeit resulting to a 3-0 loss
- Bot Clubs: New Players are created

## Features

- **Players Training**: Training happens automatically based on various factors (age, player skill, played position, and staff skill).
- **Multiple Multiverses with Different Game Speeds**:
  - Speed1: 1 game per week (default)
  - Speed2: 2 games per week
  - Speed7: 7 games per week (1 per day)
  - Speed14: 14 games per week (2 per day)
- **Elo Ranking System**: [Elo ranking system](https://en.wikipedia.org/wiki/World_Football_Elo_Ratings) to compare clubs with each other
- **Money Management**: Recycles money in a closed loop (to avoid inflation and make money management challenging), with salaries and expenses split and returned to clubs according to their rankings.

## Player Management and Training

### Player Attributes

Players have various attributes that affect their performance:

- **Main Skills**
  - **Keeper**: Goalkeeping ability (for defense).
  - **Defense**: Defensive skills (for defense).
  - **Passes**: Passing accuracy (for goal opportunities and attacks)
  - **Playmaking**: Ability to generate goal opportunities.
  - **Winger**: Skills on the wing for side attacks.
  - **Scoring**: Goal-scoring ability (for attacks).
  - **Freekick**: Free kick accuracy.
  
  <!-- - **Technic**: Technical skills, including dribbling and ball control.
  - **Header**: Ability to win aerial duels and score with headers.
  - **Strength**: Physical power and ability to hold off opponents.
  - **Tackling**: Ability to dispossess opponents cleanly.
  - **Crossing**: Accuracy and effectiveness of delivering the ball from wide areas.
  - **Positioning**: Ability to be in the right place at the right time, both offensively and defensively.
  - **Vision**: Ability to see and execute passes that others might not see.
  - **Dribbling**: Skill in maneuvering the ball past opponents.
  - **Finishing**: Ability to convert goal-scoring opportunities.
  - **Marking**: Ability to closely guard and track opponents.
  - **Interceptions**: Ability to read the game and intercept passes.
  - **Long Shots**: Ability to score from long distances.
  - **Set Pieces**: Skill in taking corners, free kicks, and penalties. -->

- **Other Skills**
  - **Motivation**: Player's drive and determination.
  - **Form**: Current performance level.
  - **Stamina**: Ability to maintain energy during a game.
  - **Energy**: Player's effort level during a game.
  - **Experience**: Knowledge gained from playing games.
  - **Loyalty**: Commitment to the club.
  - **Leadership**: Ability to lead and inspire teammates.
  - **Discipline**: Adherence to training and strategies.
  - **Communication**: Coordination with teammates.
  - **Aggressivity**: Assertiveness on the field.
  - **Composure**: Performance under pressure.
  - **TeamWork**: Ability to work within the team.

### Size

The **Size** attribute is not a skill per se, but it influences several other skills:

- **Header**: Taller players generally have an advantage in aerial duels.
- **Technic**: Smaller players may have better agility and ball control.
- **Strength**: Larger players tend to have more physical power.

### Main Skills

The **Main Skills** are the football-related skills of the player.
They are updated weekly based on multiple criteria:

- **Age**: Younger players improve faster.
- **Staff Weight**: The quality of the club's staff affects training efficiency.
- **Training Coefficients**: Each attribute has a training coefficient that determines how much it improves (determined by the manager).
- **Played Position**: The position played during a game.

### Other Skills

The **Other Skills** are mental and physical attributes that are also updated weekly and during games.

#### Motivation

Players' motivation is updated weekly. It can drop if not paid their weekly expected expenses and may leave if the motivation is too low.

#### Energy

Energy is the player's ability to maintain his effort during a game.

#### Stamina

Stamina is the player's ability to maintain his energy during a game. The higher the stamina, the lower the energy drops during a game.

#### Experience

Increases by playing games.

### Player Performance Score

- The performance score is calculated based on the player's attributes.
- This score determines the player's effectiveness in matches.

## TODO

### Display Events of Current Games According to Time (NORMAL)

### Game Simulation Extra Cases (EASY)

Handle injuries, substitutions, and free kicks.

### Solo Mode Like FM Where You Can Advance at Your Speed (HARD)

Have more multiverses (can start becoming heavy for the database).
Try to make a local database

### Split money for transfers (EASY)

When a player is transfered, split money for example:

- 4%: For the league
- 1%: For international cup
- 10%: For previous clubs

### Fans

### Sligth updates of players other skills (Leadership, Discipline etc...) to have modified staff weight (EASY)

### Make a trigger on cash column of clubs table to perfrectly handle money in closed loop (EASY)

## Contributing

Contributions are welcome! Please fork the repository and submit pull requests.

## License

This project is licensed under the MIT License.
