/// Projeção leve da Ficha para listagens — evita carregar a árvore inteira.
final class SheetSummary {
  final String id;
  final String systemId;
  final int level;
  final String characterName;

  const SheetSummary({
    required this.id,
    required this.systemId,
    required this.level,
    required this.characterName,
  });
}
