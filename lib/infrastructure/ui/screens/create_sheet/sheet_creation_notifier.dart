import 'dart:math';

import 'package:fichavern/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'sheet_creation_state.dart';

final class SheetCreationNotifier
    extends StateNotifier<SheetCreationState> {
  SheetCreationNotifier(this._engine)
      : super(SheetCreationState.initial());

  final CharacterCreationEngine _engine;
  static const _uuid = Uuid();
  final _rng = Random();

  void setName(String name) =>
      state = state.copyWith(characterName: name, clearError: true);

  /// Avança para o próximo passo. Valida o passo atual antes de mover.
  void nextStep() {
    switch (state.step) {
      case CreationStep.name:
        if (state.characterName.trim().isEmpty) {
          state = state.copyWith(errorMessage: 'Dê um nome ao personagem.');
          return;
        }
        state = state.copyWith(step: CreationStep.rollAbilities, clearError: true);

      case CreationStep.rollAbilities:
        if (!state.abilitiesFullyAssigned) {
          state = state.copyWith(
            errorMessage: 'Atribua todos os 6 valores antes de continuar.',
          );
          return;
        }
        state = state.copyWith(step: CreationStep.race, clearError: true);

      case CreationStep.race:
        if (!state.hasChoiceForStep('race')) {
          state = state.copyWith(errorMessage: 'Escolha uma raça.');
          return;
        }
        state = state.copyWith(step: CreationStep.classChoice, clearError: true);

      case CreationStep.classChoice:
        if (!state.hasChoiceForStep('class')) {
          state = state.copyWith(errorMessage: 'Escolha uma classe.');
          return;
        }
        state = state.copyWith(step: CreationStep.summary, clearError: true);

      case CreationStep.summary:
        break;
    }
  }

  void previousStep() {
    final prev = switch (state.step) {
      CreationStep.name => CreationStep.name,
      CreationStep.rollAbilities => CreationStep.name,
      CreationStep.race => CreationStep.rollAbilities,
      CreationStep.classChoice => CreationStep.race,
      CreationStep.summary => CreationStep.classChoice,
    };
    state = state.copyWith(step: prev, clearError: true);
  }

  /// Gera 6 valores usando 4d6 descarta o menor, e reseta as atribuições.
  void rollAbilities() {
    final values = List.generate(6, (_) => _roll4d6DropLowest());
    state = state.copyWith(
      rolledValues: values,
      assignments: {
        'strength': null,
        'dexterity': null,
        'constitution': null,
        'intelligence': null,
        'wisdom': null,
        'charisma': null,
      },
      clearError: true,
    );
  }

  /// Atribui [value] ao [ability]. Libera o atributo que já usava esse valor.
  void assign(String ability, int? value) {
    final updated = Map<String, int?>.from(state.assignments);
    if (value != null) {
      updated.forEach((k, v) {
        if (v == value && k != ability) updated[k] = null;
      });
    }
    updated[ability] = value;
    state = state.copyWith(assignments: updated, clearError: true);
  }

  /// Registra uma escolha de catálogo (raça ou classe) na ficha parcial.
  void makeChoice(CatalogOption option, String stepId) {
    final partial = _buildPartialSheet();
    final choice = Choice(step: stepId, optionId: option.id, children: []);
    final result = _engine.validate(choice, partial);
    if (!result.isValid) {
      final msgs = result.unmetConditions
          .map((c) => _prereqLabel(c.prerequisite))
          .join(', ');
      state = state.copyWith(errorMessage: 'Pré-requisito não atendido: $msgs');
      return;
    }
    final updated = [
      ...state.choices.where((c) => c.step != stepId),
      choice,
    ];
    state = state.copyWith(choices: updated, clearError: true);
  }

  Sheet _buildPartialSheet() => Sheet(
        id: _uuid.v4(),
        systemId: 'dnd5e',
        level: 1,
        character: Character(
          name: state.characterName.trim(),
          story: '',
          characteristics: '',
          traits: [],
        ),
        choices: state.choices,
        baseAbilities: state.finalAbilities,
      );

  /// Constrói a ficha final pronta para persistir.
  Sheet buildFinalSheet() => _buildPartialSheet();

  int _roll4d6DropLowest() {
    final rolls = List.generate(4, (_) => _rng.nextInt(6) + 1)..sort();
    return rolls.skip(1).fold(0, (sum, v) => sum + v);
  }

  String _prereqLabel(Prerequisite prereq) => switch (prereq) {
        MinAbilityPrerequisite(:final ability, :final value) =>
          '$ability ≥ $value',
        MinLevelPrerequisite(:final value) => 'nível ≥ $value',
        HasChoicePrerequisite(:final optionId) => 'requer $optionId',
        HasTraitPrerequisite(:final ref) => 'requer traço $ref',
        MinProficiencyPrerequisite(:final ref) => 'proficiência em $ref',
      };
}
