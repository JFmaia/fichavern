/// Pré-requisitos declarativos de uma OpçãoDeCatálogo.
/// Cada subtipo corresponde a um `type` do vocabulário fechado (roadmap seção 4.2).
/// O plugin avalia cada tipo com um avaliador próprio — um por subtipo, nunca por opção individual.
sealed class Prerequisite {
  const Prerequisite();
}

final class MinAbilityPrerequisite extends Prerequisite {
  final String ability;
  final int value;

  const MinAbilityPrerequisite({required this.ability, required this.value});
}

final class MinProficiencyPrerequisite extends Prerequisite {
  final String ref;
  final String rank;

  const MinProficiencyPrerequisite({required this.ref, required this.rank});
}

final class MinLevelPrerequisite extends Prerequisite {
  final int value;

  const MinLevelPrerequisite({required this.value});
}

final class HasChoicePrerequisite extends Prerequisite {
  final String optionId;

  const HasChoicePrerequisite({required this.optionId});
}

final class HasTraitPrerequisite extends Prerequisite {
  final String ref;

  const HasTraitPrerequisite({required this.ref});
}
