String getPositionText(int position, {bool shortText = true}) {
  switch (position) {
    case 1:
      return shortText ? 'GK' : 'Goalkeeper';
    case 2:
      return shortText ? 'LBW' : 'Left Back Winger';
    case 3:
      return shortText ? 'LCB' : 'Left Center Back';
    case 4:
      return shortText ? 'RCB' : 'Right Center Back';
    case 5:
      return shortText ? 'RB' : 'Right Center Back';
    case 6:
      return shortText ? 'CDM' : 'Central Defensive Midfielder';
    case 7:
      return shortText ? 'LM' : 'Left Midfielder';
    case 8:
      return shortText ? 'CM' : 'Center Midfielder';
    case 9:
      return shortText ? 'RM' : 'Right Midfielder';
    case 10:
      return shortText ? 'LW' : 'Left Winger';
    case 11:
      return shortText ? 'RW' : 'Right Winger';
    case 12:
      return shortText ? 'ST' : 'Striker';
    case 13:
      return shortText ? 'SUB1' : 'Substitute 1';
    case 14:
      return shortText ? 'SUB2' : 'Substitute 2';
    case 15:
      return shortText ? 'SUB3' : 'Substitute 3';
    default:
      return shortText ? 'Unknown' : 'Unknown Position';
  }
}
