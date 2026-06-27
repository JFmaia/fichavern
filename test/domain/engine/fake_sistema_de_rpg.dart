import 'package:fichavern/domain/domain.dart';

/// Plugin falso usado exclusivamente nos testes do motor genérico.
/// Tem dois passos (race, class), quatro opções e um pré-requisito que falha
/// em nível 1 — o suficiente para exercitar todos os caminhos do motor.
final class FakeSistemaDeRPG implements SistemaDeRPG {
  @override
  String get systemId => 'fake';

  @override
  List<StepDefinition> steps() => const [
        StepDefinition(id: 'race', label: 'Escolha sua raça'),
        StepDefinition(id: 'class', label: 'Escolha sua classe'),
      ];

  @override
  List<CatalogOption> listOptions(StepId step, Sheet sheet) {
    return switch (step) {
      'race' => _raceOptions,
      'class' => _classOptions,
      _ => [],
    };
  }

  @override
  List<Slot> choicesForLevel(Sheet sheet, int newLevel) => [];

  @override
  ValidationResult validate(Choice choice, Sheet sheet) {
    // Mago Arcano exige nível 3 — falha em qualquer ficha de nível < 3.
    if (choice.optionId == 'fake.class.arcane_mage') {
      if (sheet.level < 3) {
        return ValidationResult(
          isValid: false,
          unmetConditions: [
            UnmetCondition(
              prerequisite: const MinLevelPrerequisite(value: 3),
              currentValue: sheet.level,
            ),
          ],
        );
      }
    }
    return ValidationResult.valid();
  }

  @override
  DerivedValues derive(Sheet sheet) {
    final base = Map<String, int>.from(sheet.baseAbilities);

    // Aplica bônus de raça
    for (final choice in sheet.choices) {
      final option = _allOptions.where((o) => o.id == choice.optionId).firstOrNull;
      if (option == null) continue;

      for (final effect in option.effects) {
        switch (effect) {
          case AbilityBonusEffect(:final ability, :final value):
            base[ability] = (base[ability] ?? 10) + value;
          case AbilityPenaltyEffect(:final ability, :final value):
            base[ability] = (base[ability] ?? 10) - value;
          case SetHpEffect():
          case GrantsProficiencyEffect():
          case GrantsTraitEffect():
          case SetSpeedEffect():
          case GrantsSkillEffect():
            break;
        }
      }
    }

    final modifiers = base.map((k, v) => MapEntry(k, (v - 10) ~/ 2));
    final conMod = modifiers['constitution'] ?? 0;

    // PV: hpPerLevel (da classe) × nível + mod. Constituição × nível
    int hpPerLevel = 0;
    for (final choice in sheet.choices) {
      final option = _allOptions.where((o) => o.id == choice.optionId).firstOrNull;
      if (option == null) continue;
      for (final effect in option.effects) {
        if (effect case SetHpEffect(:final perLevel)) {
          hpPerLevel = perLevel;
        }
      }
    }

    return DerivedValues(
      abilities: base,
      modifiers: modifiers,
      hitPoints: (hpPerLevel + conMod) * sheet.level,
      armorClass: 10 + (modifiers['dexterity'] ?? 0),
      skills: {},
      proficiencies: [],
      grantedTraits: [],
      speed: 30,
    );
  }
}

// ─── Catálogo inline do plugin falso ─────────────────────────────────────────

const _raceOptions = [
  CatalogOption(
    id: 'fake.race.elf',
    systemId: 'fake',
    step: 'race',
    name: 'Elfo',
    summary: 'Ágil e com sentidos aguçados.',
    whyItMatters: 'Bônus de Destreza — boa escolha para classes que dependem de agilidade.',
    tags: ['ágil', 'sutil'],
    unlocks: [],
    prerequisites: [],
    effects: [AbilityBonusEffect(ability: 'dexterity', value: 2)],
  ),
  CatalogOption(
    id: 'fake.race.dwarf',
    systemId: 'fake',
    step: 'race',
    name: 'Anão',
    summary: 'Resistente e ligado à pedra.',
    whyItMatters: 'Bônus de Constituição — mais PV e maior resistência.',
    tags: ['resistente', 'tradicional'],
    unlocks: [],
    prerequisites: [],
    effects: [AbilityBonusEffect(ability: 'constitution', value: 2)],
  ),
];

const _classOptions = [
  CatalogOption(
    id: 'fake.class.fighter',
    systemId: 'fake',
    step: 'class',
    name: 'Guerreiro',
    summary: 'Combatente versátil e resistente.',
    whyItMatters: 'Alto PV por nível — ideal para quem fica na linha de frente.',
    tags: ['combate', 'resistente'],
    unlocks: [],
    prerequisites: [],
    effects: [SetHpEffect(perLevel: 10)],
  ),
  CatalogOption(
    id: 'fake.class.arcane_mage',
    systemId: 'fake',
    step: 'class',
    name: 'Mago Arcano',
    summary: 'Conjurador de magias poderosas.',
    whyItMatters: 'Magias de alto impacto, mas requer experiência (nível 3+).',
    tags: ['magia', 'avançado'],
    unlocks: [],
    prerequisites: [MinLevelPrerequisite(value: 3)],
    effects: [SetHpEffect(perLevel: 6)],
  ),
];

const _allOptions = [..._raceOptions, ..._classOptions];
