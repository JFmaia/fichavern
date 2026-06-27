import 'package:fichavern/domain/domain.dart';
import 'package:fichavern/domain/systems/dnd5e/dnd5e_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dnd5ePlugin plugin;
  late Sheet baseSheet;

  setUp(() {
    plugin = const Dnd5ePlugin();
    // Atributos típicos de um personagem D&D nível 1 rolado com 4d6 descarta menor.
    baseSheet = Sheet(
      id: 'test-dnd5e-1',
      systemId: 'dnd5e',
      level: 1,
      character: const Character(
        name: 'Thorin',
        story: '',
        characteristics: '',
        traits: [],
      ),
      choices: const [],
      baseAbilities: const {
        'strength': 15,
        'dexterity': 12,
        'constitution': 14,
        'intelligence': 10,
        'wisdom': 8,
        'charisma': 13,
      },
    );
  });

  // ─── Contrato básico ─────────────────────────────────────────────────────────

  group('systemId', () {
    test('identifica o sistema como dnd5e', () {
      expect(plugin.systemId, 'dnd5e');
    });
  });

  group('steps()', () {
    test('retorna race e class nessa ordem', () {
      final steps = plugin.steps();
      expect(steps.map((s) => s.id), ['race', 'class']);
    });
  });

  group('listOptions()', () {
    test('retorna 2 raças para o passo race', () {
      final options = plugin.listOptions('race', baseSheet);
      expect(options, hasLength(2));
      expect(options.map((o) => o.id), containsAll(['dnd5e.race.dwarf', 'dnd5e.race.elf']));
    });

    test('retorna 2 classes para o passo class', () {
      final options = plugin.listOptions('class', baseSheet);
      expect(options, hasLength(2));
      expect(options.map((o) => o.id), containsAll(['dnd5e.class.fighter', 'dnd5e.class.wizard']));
    });

    test('retorna lista vazia para passo desconhecido', () {
      expect(plugin.listOptions('background', baseSheet), isEmpty);
    });
  });

  // ─── validate() ─────────────────────────────────────────────────────────────

  group('validate()', () {
    test('raças e classes básicas não têm pré-requisitos — sempre válidas', () {
      final choices = [
        'dnd5e.race.dwarf',
        'dnd5e.race.elf',
        'dnd5e.class.fighter',
        'dnd5e.class.wizard',
      ];

      for (final optionId in choices) {
        final step = optionId.contains('.race.') ? 'race' : 'class';
        final choice = Choice(step: step, optionId: optionId, children: []);
        final result = plugin.validate(choice, baseSheet);
        expect(result.isValid, isTrue, reason: '$optionId deve ser válida sem pré-requisitos');
      }
    });

    test('opção inexistente no catálogo retorna inválida', () {
      const choice = Choice(step: 'race', optionId: 'dnd5e.race.goblin', children: []);
      final result = plugin.validate(choice, baseSheet);
      expect(result.isValid, isFalse);
    });
  });

  // ─── derive() — Anão ────────────────────────────────────────────────────────

  group('derive() com Anão', () {
    late Sheet sheetWithDwarf;

    setUp(() {
      sheetWithDwarf = baseSheet.copyWith(choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.dwarf', children: []),
      ]);
    });

    test('aplica +2 Constituição (base 14 → final 16)', () {
      final derived = plugin.derive(sheetWithDwarf);
      expect(derived.abilities['constitution'], 16);
    });

    test('não altera atributos que a raça não modifica', () {
      final derived = plugin.derive(sheetWithDwarf);
      expect(derived.abilities['strength'], 15);
      expect(derived.abilities['dexterity'], 12);
    });

    test('define velocidade como 25 pés', () {
      final derived = plugin.derive(sheetWithDwarf);
      expect(derived.speed, 25);
    });

    test('concede os traços darkvision e dwarven_resilience', () {
      final derived = plugin.derive(sheetWithDwarf);
      expect(derived.grantedTraits, containsAll([
        'dnd5e.trait.darkvision',
        'dnd5e.trait.dwarven_resilience',
      ]));
    });

    test('calcula modificador de Constituição corretamente (16 → +3)', () {
      final derived = plugin.derive(sheetWithDwarf);
      expect(derived.modifiers['constitution'], 3);
    });
  });

  // ─── derive() — Elfo ────────────────────────────────────────────────────────

  group('derive() com Elfo', () {
    late Sheet sheetWithElf;

    setUp(() {
      sheetWithElf = baseSheet.copyWith(choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.elf', children: []),
      ]);
    });

    test('aplica +2 Destreza (base 12 → final 14)', () {
      final derived = plugin.derive(sheetWithElf);
      expect(derived.abilities['dexterity'], 14);
    });

    test('define velocidade como 30 pés', () {
      final derived = plugin.derive(sheetWithElf);
      expect(derived.speed, 30);
    });

    test('concede os traços darkvision e fey_ancestry', () {
      final derived = plugin.derive(sheetWithElf);
      expect(derived.grantedTraits, containsAll([
        'dnd5e.trait.darkvision',
        'dnd5e.trait.fey_ancestry',
      ]));
    });

    test('concede proficiência em Percepção', () {
      final derived = plugin.derive(sheetWithElf);
      expect(derived.proficiencies, contains('dnd5e.skill.perception'));
    });

    test('calcula bônus de Percepção = mod Sabedoria + bônus de proficiência', () {
      final derived = plugin.derive(sheetWithElf);
      // Sabedoria base 8 → mod -1; profBonus nível 1 = +2 → total +1
      expect(derived.skills['dnd5e.skill.perception'], 1);
    });
  });

  // ─── derive() — Guerreiro ────────────────────────────────────────────────────

  group('derive() com Guerreiro', () {
    late Sheet sheetFighter;

    setUp(() {
      sheetFighter = baseSheet.copyWith(choices: const [
        Choice(step: 'class', optionId: 'dnd5e.class.fighter', children: []),
      ]);
    });

    test('concede proficiências de armadura e armas do Guerreiro', () {
      final derived = plugin.derive(sheetFighter);
      expect(derived.proficiencies, containsAll([
        'dnd5e.armor.light',
        'dnd5e.armor.medium',
        'dnd5e.armor.heavy',
        'dnd5e.armor.shields',
        'dnd5e.weapon_group.simple',
        'dnd5e.weapon_group.martial',
      ]));
    });
  });

  // ─── derive() — fluxo completo ───────────────────────────────────────────────

  group('derive() — ficha completa (Anão Guerreiro, nível 1)', () {
    late Sheet completeSheet;

    setUp(() {
      // CON base 14 + bônus Anão +2 = 16 → mod +3
      // PV = (10 + 3) × 1 = 13
      completeSheet = baseSheet.copyWith(choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.dwarf', children: []),
        Choice(step: 'class', optionId: 'dnd5e.class.fighter', children: []),
      ]);
    });

    test('PV = (dado de vida + mod Constituição pós-bônus de raça) × nível', () {
      final derived = plugin.derive(completeSheet);
      expect(derived.hitPoints, 13); // (10 + 3) × 1
    });

    test('CA = 10 + modificador de Destreza (sem armadura)', () {
      final derived = plugin.derive(completeSheet);
      // DEX base 12 → mod +1 → CA = 11
      expect(derived.armorClass, 11);
    });
  });

  group('derive() — ficha completa (Elfo Mago, nível 1)', () {
    late Sheet sheetElfWizard;

    setUp(() {
      // DEX base 12 + bônus Elfo +2 = 14 → mod +2 → CA = 12
      // CON base 14 → mod +2; PV Mago = (6 + 2) × 1 = 8
      sheetElfWizard = baseSheet.copyWith(choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.elf', children: []),
        Choice(step: 'class', optionId: 'dnd5e.class.wizard', children: []),
      ]);
    });

    test('PV do Mago Elfo = (6 + mod CON) × nível', () {
      final derived = plugin.derive(sheetElfWizard);
      expect(derived.hitPoints, 8); // (6 + 2) × 1
    });

    test('CA do Elfo sem armadura usa DEX pós-bônus', () {
      final derived = plugin.derive(sheetElfWizard);
      expect(derived.armorClass, 12); // 10 + 2 (DEX 14 → mod +2)
    });
  });

  // ─── Bônus de proficiência ───────────────────────────────────────────────────

  group('bônus de proficiência D&D 5e', () {
    test('é +2 nos níveis 1–4', () {
      for (var level = 1; level <= 4; level++) {
        final sheet = baseSheet.copyWith(level: level, choices: const [
          Choice(step: 'race', optionId: 'dnd5e.race.elf', children: []),
        ]);
        final derived = plugin.derive(sheet);
        // Percepção: mod WIS(-1) + profBonus(2) = 1
        expect(derived.skills['dnd5e.skill.perception'], 1,
            reason: 'nível $level: profBonus deve ser 2');
      }
    });

    test('sobe para +3 no nível 5', () {
      final sheet = baseSheet.copyWith(level: 5, choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.elf', children: []),
      ]);
      final derived = plugin.derive(sheet);
      // Percepção: mod WIS(-1) + profBonus(3) = 2
      expect(derived.skills['dnd5e.skill.perception'], 2);
    });
  });

  // ─── derive() é função pura ──────────────────────────────────────────────────

  group('pureza de derive()', () {
    test('mesma ficha produz exatamente o mesmo resultado em chamadas consecutivas', () {
      final sheet = baseSheet.copyWith(choices: const [
        Choice(step: 'race', optionId: 'dnd5e.race.dwarf', children: []),
        Choice(step: 'class', optionId: 'dnd5e.class.fighter', children: []),
      ]);

      final first = plugin.derive(sheet);
      final second = plugin.derive(sheet);

      expect(first.hitPoints, second.hitPoints);
      expect(first.abilities, second.abilities);
      expect(first.armorClass, second.armorClass);
    });

    test('não altera a ficha original ao derivar', () {
      final choicesBefore = List.of(baseSheet.choices);
      plugin.derive(baseSheet);
      expect(baseSheet.choices, equals(choicesBefore));
    });
  });
}
