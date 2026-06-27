/// Lado narrativo e livre do personagem — nenhum campo passa por validação ou cálculo.
final class Character {
  final String name;
  final String story;

  /// Descrição física e comportamental: aparência, marcas, maneirismos.
  final String characteristics;

  /// Etiquetas curtas de personalidade ("teimosa", "leal") — boas para chips na UI.
  final List<String> traits;

  const Character({
    required this.name,
    required this.story,
    required this.characteristics,
    required this.traits,
  });

  Character copyWith({
    String? name,
    String? story,
    String? characteristics,
    List<String>? traits,
  }) =>
      Character(
        name: name ?? this.name,
        story: story ?? this.story,
        characteristics: characteristics ?? this.characteristics,
        traits: traits ?? this.traits,
      );
}
