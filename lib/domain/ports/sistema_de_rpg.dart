import '../model/catalog_option.dart';
import '../model/choice.dart';
import '../model/derived_values.dart';
import '../model/sheet.dart';
import '../model/slot.dart';
import '../model/step_definition.dart';
import '../model/step_id.dart';
import '../model/validation_result.dart';

/// Porta motor↔plugin. O motor depende DESTA interface, nunca de um sistema concreto.
/// Adicionar um 4º sistema = nova implementação, motor intacto.
abstract interface class SistemaDeRPG {
  /// Identificador do sistema ("dnd5e" | "pf2e" | "a5e").
  String get systemId;

  /// Passos do esqueleto que ESTE sistema expõe, na ordem.
  /// O motor não tem uma lista global fixa — pergunta ao plugin.
  List<StepDefinition> steps();

  /// Opções disponíveis para um passo, filtradas pelo contexto atual da ficha.
  List<CatalogOption> listOptions(StepId step, Sheet sheet);

  /// Slots que um nível abre no level-up.
  /// Mesma estrutura `unlocks` da criação, disparada por nível em vez de por escolha-pai.
  List<Slot> choicesForLevel(Sheet sheet, int newLevel);

  /// Avalia se uma escolha é legal contra o estado atual da ficha.
  /// Retorna o resultado + as condições não cumpridas (para a UI explicar ao leigo).
  ValidationResult validate(Choice choice, Sheet sheet);

  /// Calcula todos os valores derivados a partir da árvore inteira de escolhas.
  /// Função pura: mesma ficha → mesmo resultado. Nunca grava nada.
  DerivedValues derive(Sheet sheet);
}
