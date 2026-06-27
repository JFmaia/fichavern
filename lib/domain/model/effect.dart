/// Efeitos mecânicos declarados por uma OpçãoDeCatálogo.
/// Cada subtipo corresponde a um `type` do vocabulário fechado (roadmap seção 4.1).
/// O plugin chama `derive()` fazendo switch exaustivo sobre esta sealed class —
/// sem precisar de `if type == "abilityBonus"` em string.
sealed class Effect {
  const Effect();
}

final class AbilityBonusEffect extends Effect {
  final String ability;
  final int value;

  const AbilityBonusEffect({required this.ability, required this.value});
}

final class AbilityPenaltyEffect extends Effect {
  final String ability;
  final int value;

  const AbilityPenaltyEffect({required this.ability, required this.value});
}

final class SetHpEffect extends Effect {
  final int perLevel;

  const SetHpEffect({required this.perLevel});
}

final class GrantsProficiencyEffect extends Effect {
  final String ref;

  const GrantsProficiencyEffect({required this.ref});
}

final class GrantsTraitEffect extends Effect {
  final String ref;

  const GrantsTraitEffect({required this.ref});
}

final class SetSpeedEffect extends Effect {
  final int value;

  const SetSpeedEffect({required this.value});
}

final class GrantsSkillEffect extends Effect {
  final String ref;

  const GrantsSkillEffect({required this.ref});
}
