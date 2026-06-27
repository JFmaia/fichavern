import 'prerequisite.dart';

/// Condição não cumprida retornada por `validate()`.
/// Carrega o pré-requisito estruturado e o valor atual do personagem —
/// a UI usa isso para gerar "precisa de Força 14, você tem 12" sem texto escrito à mão.
final class UnmetCondition {
  final Prerequisite prerequisite;
  final Object? currentValue;

  const UnmetCondition({required this.prerequisite, this.currentValue});
}

final class ValidationResult {
  final bool isValid;
  final List<UnmetCondition> unmetConditions;

  const ValidationResult({
    required this.isValid,
    required this.unmetConditions,
  });

  factory ValidationResult.valid() => const ValidationResult(
        isValid: true,
        unmetConditions: [],
      );
}
