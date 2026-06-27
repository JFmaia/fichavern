import 'package:fichavern/catalog/dnd5e/dnd5e_catalog.dart';
import 'package:fichavern/domain/domain.dart';

/// Plugin D&D 5e. Implementa [SistemaDeRPG] sem que o motor genérico
/// precise conhecer nenhuma regra de D&D.
final class Dnd5ePlugin implements SistemaDeRPG {
  const Dnd5ePlugin([this._catalog = dnd5eCatalog]);

  final List<CatalogOption> _catalog;

  @override
  String get systemId => 'dnd5e';

  @override
  List<StepDefinition> steps() => const [
        StepDefinition(id: 'race', label: 'Escolha sua raça'),
        StepDefinition(id: 'class', label: 'Escolha sua classe'),
      ];

  @override
  List<CatalogOption> listOptions(StepId step, Sheet sheet) =>
      _catalog.where((o) => o.step == step).toList();

  @override
  List<Slot> choicesForLevel(Sheet sheet, int newLevel) => [];

  @override
  ValidationResult validate(Choice choice, Sheet sheet) {
    final option = _catalog.where((o) => o.id == choice.optionId).firstOrNull;
    if (option == null) {
      return const ValidationResult(isValid: false, unmetConditions: []);
    }

    final derived = derive(sheet);
    final unmet = option.prerequisites
        .map((p) => _evaluate(p, sheet, derived))
        .whereType<UnmetCondition>()
        .toList();

    return unmet.isEmpty
        ? ValidationResult.valid()
        : ValidationResult(isValid: false, unmetConditions: unmet);
  }

  /// Avaliador de pré-requisito. Retorna [UnmetCondition] se não cumprido, null se ok.
  UnmetCondition? _evaluate(
    Prerequisite prereq,
    Sheet sheet,
    DerivedValues derived,
  ) =>
      switch (prereq) {
        MinAbilityPrerequisite(:final ability, :final value) =>
          (derived.abilities[ability] ?? 0) >= value
              ? null
              : UnmetCondition(
                  prerequisite: prereq,
                  currentValue: derived.abilities[ability],
                ),
        MinLevelPrerequisite(:final value) => sheet.level >= value
            ? null
            : UnmetCondition(
                prerequisite: prereq,
                currentValue: sheet.level,
              ),
        HasChoicePrerequisite(:final optionId) =>
          sheet.choices.any((c) => c.optionId == optionId)
              ? null
              : UnmetCondition(prerequisite: prereq),
        HasTraitPrerequisite(:final ref) =>
          derived.grantedTraits.contains(ref)
              ? null
              : UnmetCondition(prerequisite: prereq),
        // Rank de proficiência é conceito de PF2e — M7.
        MinProficiencyPrerequisite() => null,
      };

  /// Calcula todos os valores derivados seguindo o grafo de cálculo do roadmap (seção 5).
  /// Função pura: mesma ficha → mesmo resultado. Nunca grava nada.
  @override
  DerivedValues derive(Sheet sheet) {
    final allEffects = _collectEffects(sheet.choices);

    // Fase 1 — atributos base (rolados e gravados na ficha como entrada)
    final abilities = Map<String, int>.from(sheet.baseAbilities);

    // Fase 2 — modificadores de raça/background (abilityBonus / abilityPenalty)
    for (final effect in allEffects) {
      switch (effect) {
        case AbilityBonusEffect(:final ability, :final value):
          abilities[ability] = (abilities[ability] ?? 0) + value;
        case AbilityPenaltyEffect(:final ability, :final value):
          abilities[ability] = (abilities[ability] ?? 0) - value;
        default:
          break;
      }
    }

    // Fase 3 — atributos finais → modificadores
    final modifiers = abilities.map((k, v) => MapEntry(k, (v - 10) ~/ 2));

    // Fase 4 — valores dependentes de atributos finais
    var hpPerLevel = 0;
    var speed = 30;

    for (final effect in allEffects) {
      switch (effect) {
        case SetHpEffect(:final perLevel):
          hpPerLevel = perLevel;
        case SetSpeedEffect(:final value):
          speed = value;
        default:
          break;
      }
    }

    final conMod = modifiers['constitution'] ?? 0;
    final dexMod = modifiers['dexterity'] ?? 0;
    final profBonus = _proficiencyBonus(sheet.level);

    // Fase 5 — proficiências e traços concedidos
    final proficiencies = <String>[];
    final grantedTraits = <String>[];
    final skills = <String, int>{};

    for (final effect in allEffects) {
      switch (effect) {
        case GrantsProficiencyEffect(:final ref):
          proficiencies.add(ref);
          // Refs de perícia computam bônus com modificador de atributo + profBonus
          final abilityRef = _skillAbilityMap[ref];
          if (abilityRef != null) {
            skills[ref] = (modifiers[abilityRef] ?? 0) + profBonus;
          }
        case GrantsTraitEffect(:final ref):
          grantedTraits.add(ref);
        case GrantsSkillEffect(:final ref):
          final abilityRef = _skillAbilityMap[ref];
          skills[ref] = (modifiers[abilityRef ?? ''] ?? 0) + profBonus;
        default:
          break;
      }
    }

    return DerivedValues(
      abilities: abilities,
      modifiers: modifiers,
      // PV = (dado de vida + mod. Constituição) × nível
      // Usa dado máximo em todos os níveis (simplificação do MVP; PHB usa média nos níveis 2+)
      hitPoints: (hpPerLevel + conMod) * sheet.level,
      armorClass: 10 + dexMod,
      skills: skills,
      proficiencies: proficiencies,
      grantedTraits: grantedTraits,
      speed: speed,
    );
  }

  /// Percorre a árvore de escolhas recursivamente e coleta todos os efeitos.
  List<Effect> _collectEffects(List<Choice> choices) {
    final effects = <Effect>[];
    for (final choice in choices) {
      final option = _catalog.where((o) => o.id == choice.optionId).firstOrNull;
      if (option != null) {
        effects.addAll(option.effects);
        effects.addAll(_collectEffects(choice.children));
      }
    }
    return effects;
  }

  /// Bônus de proficiência D&D 5e: +2 nos níveis 1–4, +3 nos 5–8, etc.
  static int _proficiencyBonus(int level) => 2 + ((level - 1) ~/ 4);
}

/// Mapa perícia → atributo base (D&D 5e PHB).
const _skillAbilityMap = {
  'dnd5e.skill.acrobatics': 'dexterity',
  'dnd5e.skill.animal_handling': 'wisdom',
  'dnd5e.skill.arcana': 'intelligence',
  'dnd5e.skill.athletics': 'strength',
  'dnd5e.skill.deception': 'charisma',
  'dnd5e.skill.history': 'intelligence',
  'dnd5e.skill.insight': 'wisdom',
  'dnd5e.skill.intimidation': 'charisma',
  'dnd5e.skill.investigation': 'intelligence',
  'dnd5e.skill.medicine': 'wisdom',
  'dnd5e.skill.nature': 'intelligence',
  'dnd5e.skill.perception': 'wisdom',
  'dnd5e.skill.performance': 'charisma',
  'dnd5e.skill.persuasion': 'charisma',
  'dnd5e.skill.religion': 'intelligence',
  'dnd5e.skill.sleight_of_hand': 'dexterity',
  'dnd5e.skill.stealth': 'dexterity',
  'dnd5e.skill.survival': 'wisdom',
};
