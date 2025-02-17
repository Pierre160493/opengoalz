String getPositionText(int position, {bool shortText = true}) {
  switch (position) {
    case 1:
      return shortText ? 'GK' : 'Goalkeeper';
    case 2:
      return shortText ? 'LBW' : 'Left Back Winger';
    case 3:
      return shortText ? 'RBW' : 'Right Back Winger';
    case 4:
      return shortText ? 'LCB' : 'Left Center Back';
    case 5:
      return shortText ? 'RCB' : 'Right Center Back';
    case 6:
      return shortText ? 'LM' : 'Left Midfielder';
    case 7:
      return shortText ? 'LW' : 'Left Winger';
    case 8:
      return shortText ? 'RW' : 'Right Winger';
    case 9:
      return shortText ? 'LS' : 'Left Striker';
    case 10:
      return shortText ? 'RM' : 'Right Midfielder';
    case 11:
      return shortText ? 'RS' : 'Right Striker';
    case 12:
      return shortText ? 'CCB' : 'Central Center Back';
    case 13:
      return shortText ? 'CM' : 'Central Midfielder';
    case 14:
      return shortText ? 'CS' : 'Central Striker';
    case 15:
      return shortText ? 'SUB1' : 'Substitute 1';
    case 16:
      return shortText ? 'SUB2' : 'Substitute 2';
    case 17:
      return shortText ? 'SUB3' : 'Substitute 3';
    case 18:
      return shortText ? 'SUB4' : 'Substitute 4';
    case 19:
      return shortText ? 'SUB5' : 'Substitute 5';
    case 20:
      return shortText ? 'SUB6' : 'Substitute 6';
    case 21:
      return shortText ? 'SUB7' : 'Substitute 7';
    default:
      return shortText ? 'Unknown' : 'Unknown Position';
  }
}
