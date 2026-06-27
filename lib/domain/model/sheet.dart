import 'character.dart';
import 'choice.dart';

/// Ficha de personagem — deliberadamente magra.
/// Guarda systemId, level, o lado narrativo (character), a árvore de escolhas
/// e os atributos base rolados. Nenhum valor derivado é gravado aqui.
final class Sheet {
  final String id;
  final String systemId;
  final int level;
  final Character character;
  final List<Choice> choices;

  /// Atributos base rolados pelo usuário (ex.: {"strength": 15, "dexterity": 12}).
  /// É o único valor numérico guardado diretamente na ficha — `derive()` parte dele.
  final Map<String, int> baseAbilities;

  const Sheet({
    required this.id,
    required this.systemId,
    required this.level,
    required this.character,
    required this.choices,
    required this.baseAbilities,
  });

  Sheet copyWith({
    String? id,
    String? systemId,
    int? level,
    Character? character,
    List<Choice>? choices,
    Map<String, int>? baseAbilities,
  }) =>
      Sheet(
        id: id ?? this.id,
        systemId: systemId ?? this.systemId,
        level: level ?? this.level,
        character: character ?? this.character,
        choices: choices ?? this.choices,
        baseAbilities: baseAbilities ?? this.baseAbilities,
      );
}
