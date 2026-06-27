import 'step_id.dart';

/// Registro de uma decisão tomada pelo usuário em um passo da criação ou level-up.
/// A árvore de Escolhas é a única verdade guardada da ficha — valores derivados
/// são sempre recalculados a partir dela.
final class Choice {
  final StepId step;

  /// Referência à OpçãoDeCatálogo por id (ponteiro, não cópia).
  final String optionId;

  /// Sub-escolhas destravadas por esta escolha-pai (recursão do PF2e).
  /// Em D&D 5e, normalmente vazia.
  final List<Choice> children;

  const Choice({
    required this.step,
    required this.optionId,
    required this.children,
  });

  Choice copyWith({
    StepId? step,
    String? optionId,
    List<Choice>? children,
  }) =>
      Choice(
        step: step ?? this.step,
        optionId: optionId ?? this.optionId,
        children: children ?? this.children,
      );
}
