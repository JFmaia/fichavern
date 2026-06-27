import 'package:fichavern/domain/domain.dart';
import 'package:fichavern/domain/engine/character_creation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_sistema_de_rpg.dart';

void main() {
  late CharacterCreationEngine engine;
  late Sheet emptySheet;

  setUp(() {
    engine = CharacterCreationEngine(FakeSistemaDeRPG());
    emptySheet = Sheet(
      id: 'test-sheet-1',
      systemId: 'fake',
      level: 1,
      character: const Character(
        name: 'Durga',
        story: '',
        characteristics: '',
        traits: [],
      ),
      choices: const [],
      baseAbilities: const {
        'strength': 10,
        'dexterity': 12,
        'constitution': 14,
        'intelligence': 10,
        'wisdom': 10,
        'charisma': 8,
      },
    );
  });

  // ─── steps() ────────────────────────────────────────────────────────────────

  group('steps()', () {
    test('retorna os passos definidos pelo plugin na ordem correta', () {
      final steps = engine.steps();

      expect(steps, hasLength(2));
      expect(steps[0].id, 'race');
      expect(steps[1].id, 'class');
    });
  });

  // ─── optionsFor() ───────────────────────────────────────────────────────────

  group('optionsFor()', () {
    test('retorna opções de raça para o passo "race"', () {
      final options = engine.optionsFor('race', emptySheet);

      expect(options, hasLength(2));
      expect(options.map((o) => o.id), containsAll(['fake.race.elf', 'fake.race.dwarf']));
    });

    test('retorna opções de classe para o passo "class"', () {
      final options = engine.optionsFor('class', emptySheet);

      expect(options, hasLength(2));
      expect(options.map((o) => o.id), containsAll(['fake.class.fighter', 'fake.class.arcane_mage']));
    });

    test('retorna lista vazia para passo inexistente', () {
      final options = engine.optionsFor('unknown_step', emptySheet);

      expect(options, isEmpty);
    });
  });

  // ─── validate() ─────────────────────────────────────────────────────────────

  group('validate()', () {
    test('retorna válido para escolha sem pré-requisitos', () {
      const choice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);

      final result = engine.validate(choice, emptySheet);

      expect(result.isValid, isTrue);
      expect(result.unmetConditions, isEmpty);
    });

    test('retorna inválido quando pré-requisito de nível não é cumprido', () {
      const choice = Choice(step: 'class', optionId: 'fake.class.arcane_mage', children: []);

      final result = engine.validate(choice, emptySheet); // emptySheet é nível 1

      expect(result.isValid, isFalse);
      expect(result.unmetConditions, hasLength(1));
      expect(result.unmetConditions.first.prerequisite, isA<MinLevelPrerequisite>());
      expect(result.unmetConditions.first.currentValue, 1);
    });

    test('retorna válido para Mago Arcano quando ficha está em nível 3', () {
      final sheet3 = emptySheet.copyWith(level: 3);
      const choice = Choice(step: 'class', optionId: 'fake.class.arcane_mage', children: []);

      final result = engine.validate(choice, sheet3);

      expect(result.isValid, isTrue);
    });
  });

  // ─── applyChoice() ──────────────────────────────────────────────────────────

  group('applyChoice()', () {
    test('adiciona a escolha à ficha e retorna nova instância', () {
      const choice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);

      final updated = engine.applyChoice(choice, emptySheet);

      expect(updated.choices, hasLength(1));
      expect(updated.choices.first.optionId, 'fake.race.elf');
    });

    test('não modifica a ficha original (imutabilidade)', () {
      const choice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);

      engine.applyChoice(choice, emptySheet);

      expect(emptySheet.choices, isEmpty);
    });

    test('acumula múltiplas escolhas em sequência', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      const classChoice = Choice(step: 'class', optionId: 'fake.class.fighter', children: []);

      final afterRace = engine.applyChoice(raceChoice, emptySheet);
      final afterClass = engine.applyChoice(classChoice, afterRace);

      expect(afterClass.choices, hasLength(2));
    });
  });

  // ─── pendingSteps() ─────────────────────────────────────────────────────────

  group('pendingSteps()', () {
    test('retorna todos os passos quando nenhuma escolha foi feita', () {
      final pending = engine.pendingSteps(emptySheet);

      expect(pending, containsAll(['race', 'class']));
    });

    test('exclui o passo já preenchido da lista de pendentes', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      final afterRace = engine.applyChoice(raceChoice, emptySheet);

      final pending = engine.pendingSteps(afterRace);

      expect(pending, isNot(contains('race')));
      expect(pending, contains('class'));
    });

    test('retorna lista vazia quando todos os passos estão preenchidos', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      const classChoice = Choice(step: 'class', optionId: 'fake.class.fighter', children: []);
      final complete = engine.applyChoice(classChoice, engine.applyChoice(raceChoice, emptySheet));

      final pending = engine.pendingSteps(complete);

      expect(pending, isEmpty);
    });
  });

  // ─── isComplete() ───────────────────────────────────────────────────────────

  group('isComplete()', () {
    test('retorna false quando há passos pendentes', () {
      expect(engine.isComplete(emptySheet), isFalse);
    });

    test('retorna false quando apenas parte dos passos está preenchida', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      final partial = engine.applyChoice(raceChoice, emptySheet);

      expect(engine.isComplete(partial), isFalse);
    });

    test('retorna true quando todos os passos estão preenchidos', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      const classChoice = Choice(step: 'class', optionId: 'fake.class.fighter', children: []);
      final complete = engine.applyChoice(classChoice, engine.applyChoice(raceChoice, emptySheet));

      expect(engine.isComplete(complete), isTrue);
    });
  });

  // ─── derive() ───────────────────────────────────────────────────────────────

  group('derive()', () {
    test('aplica bônus de raça Elfo (+2 Destreza) nos atributos finais', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      final sheet = engine.applyChoice(raceChoice, emptySheet);

      final derived = engine.derive(sheet);

      // Base Destreza = 12, bônus Elfo = +2 → final = 14
      expect(derived.abilities['dexterity'], 14);
    });

    test('aplica bônus de raça Anão (+2 Constituição) nos atributos finais', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.dwarf', children: []);
      final sheet = engine.applyChoice(raceChoice, emptySheet);

      final derived = engine.derive(sheet);

      // Base Constituição = 14, bônus Anão = +2 → final = 16
      expect(derived.abilities['constitution'], 16);
    });

    test('calcula PV correto com Guerreiro (10 por nível) e Constituição 14 (+2 mod)', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      const classChoice = Choice(step: 'class', optionId: 'fake.class.fighter', children: []);
      final complete = engine.applyChoice(classChoice, engine.applyChoice(raceChoice, emptySheet));

      final derived = engine.derive(complete);

      // PV = (10 + 2) × 1 = 12 (Constituição base 14 → mod +2)
      expect(derived.hitPoints, 12);
    });

    test('calcula CA corretamente a partir do modificador de Destreza', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      final sheet = engine.applyChoice(raceChoice, emptySheet);

      final derived = engine.derive(sheet);

      // Destreza 14 → mod +2 → CA = 10 + 2 = 12
      expect(derived.armorClass, 12);
    });

    test('calcula modificadores a partir dos atributos finais', () {
      const raceChoice = Choice(step: 'race', optionId: 'fake.race.elf', children: []);
      final sheet = engine.applyChoice(raceChoice, emptySheet);

      final derived = engine.derive(sheet);

      // Destreza 14 → (14 - 10) ~/ 2 = 2
      expect(derived.modifiers['dexterity'], 2);
      // Carisma 8 → (8 - 10) ~/ 2 = -1
      expect(derived.modifiers['charisma'], -1);
    });
  });

  // ─── unlockedSlotsFor() ─────────────────────────────────────────────────────

  group('unlockedSlotsFor()', () {
    test('retorna lista vazia para opção sem unlocks (caso D&D — escolha plana)', () {
      const option = CatalogOption(
        id: 'fake.race.elf',
        systemId: 'fake',
        step: 'race',
        name: 'Elfo',
        summary: '',
        whyItMatters: '',
        tags: [],
        unlocks: [],
        prerequisites: [],
        effects: [],
      );

      final slots = engine.unlockedSlotsFor(option);

      expect(slots, isEmpty);
    });
  });
}
