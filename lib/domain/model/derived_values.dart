/// Valores derivados calculados por `SistemaDeRPG.derive()`.
/// Nunca guardados — sempre recalculados a partir da árvore de Escolhas.
/// Mesma Ficha → mesmo resultado (função pura).
final class DerivedValues {
  /// Atributos finais após todos os bônus e penalidades.
  final Map<String, int> abilities;

  /// Modificadores de atributo derivados dos atributos finais.
  final Map<String, int> modifiers;

  final int hitPoints;
  final int armorClass;

  /// Bônus total de cada perícia (modificador de atributo + bônus de proficiência).
  final Map<String, int> skills;

  /// Refs de proficiências concedidas (armas, armaduras, ferramentas, etc.).
  final List<String> proficiencies;

  /// Refs de traços/features concedidos pelas escolhas.
  final List<String> grantedTraits;

  final int speed;

  const DerivedValues({
    required this.abilities,
    required this.modifiers,
    required this.hitPoints,
    required this.armorClass,
    required this.skills,
    required this.proficiencies,
    required this.grantedTraits,
    required this.speed,
  });
}
