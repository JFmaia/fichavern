import 'package:fichavern/domain/domain.dart';

/// Passos do wizard de criação. A ordem reflete o fluxo do usuário.
enum CreationStep { name, rollAbilities, race, classChoice, summary }

/// Estado imutável do wizard. O [SheetCreationNotifier] sempre devolve
/// uma nova instância — jamais mutação in-place.
final class SheetCreationState {
  final CreationStep step;
  final String characterName;

  /// Os 6 valores rolados (4d6 descarta o menor). Lista vazia = ainda não rolou.
  final List<int> rolledValues;

  /// Mapa atributo → valor atribuído pelo usuário. null = ainda não atribuído.
  final Map<String, int?> assignments;

  /// Escolhas feitas no wizard (raça, classe).
  final List<Choice> choices;

  /// Mensagem de erro temporária (ex.: atributo não atribuído ao tentar avançar).
  final String? errorMessage;

  const SheetCreationState({
    required this.step,
    required this.characterName,
    required this.rolledValues,
    required this.assignments,
    required this.choices,
    this.errorMessage,
  });

  factory SheetCreationState.initial() => const SheetCreationState(
        step: CreationStep.name,
        characterName: '',
        rolledValues: [],
        assignments: {
          'strength': null,
          'dexterity': null,
          'constitution': null,
          'intelligence': null,
          'wisdom': null,
          'charisma': null,
        },
        choices: [],
      );

  bool get abilitiesFullyAssigned =>
      assignments.values.every((v) => v != null) && rolledValues.isNotEmpty;

  /// Constrói o `Map<String, int>` final para gravar na ficha.
  Map<String, int> get finalAbilities =>
      assignments.map((k, v) => MapEntry(k, v ?? 10));

  bool hasChoiceForStep(String stepId) =>
      choices.any((c) => c.step == stepId);

  SheetCreationState copyWith({
    CreationStep? step,
    String? characterName,
    List<int>? rolledValues,
    Map<String, int?>? assignments,
    List<Choice>? choices,
    String? errorMessage,
    bool clearError = false,
  }) =>
      SheetCreationState(
        step: step ?? this.step,
        characterName: characterName ?? this.characterName,
        rolledValues: rolledValues ?? this.rolledValues,
        assignments: assignments ?? this.assignments,
        choices: choices ?? this.choices,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}
