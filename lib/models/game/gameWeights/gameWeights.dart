class GameWeights {
  final double leftDefense;
  final double centralDefense;
  final double rightDefense;
  final double midfield;
  final double leftAttack;
  final double centralAttack;
  final double rightAttack;

  GameWeights({
    required this.leftDefense,
    required this.centralDefense,
    required this.rightDefense,
    required this.midfield,
    required this.leftAttack,
    required this.centralAttack,
    required this.rightAttack,
  });

  GameWeights.fromList(List<dynamic> listWeights)
      : leftDefense = listWeights[0].toDouble(),
        centralDefense = listWeights[1].toDouble(),
        rightDefense = listWeights[2].toDouble(),
        midfield = listWeights[3].toDouble(),
        leftAttack = listWeights[4].toDouble(),
        centralAttack = listWeights[5].toDouble(),
        rightAttack = listWeights[6].toDouble();
}
