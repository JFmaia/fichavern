import '../model/catalog_option.dart';
import '../model/choice.dart';
import '../model/derived_values.dart';
import '../model/sheet.dart';
import '../model/slot.dart';
import '../model/step_definition.dart';
import '../model/step_id.dart';
import '../model/validation_result.dart';
import '../ports/sistema_de_rpg.dart';

/// Motor genérico de criação de personagem.
/// Orquestra um [SistemaDeRPG] sem conhecer nenhum sistema concreto —
/// toda regra de sistema fica no plugin. Trocar D&D 5e por PF2e não toca aqui.
final class CharacterCreationEngine {
  final SistemaDeRPG system;

  const CharacterCreationEngine(this.system);

  /// Passos de criação definidos pelo plugin, na ordem que ele determina.
  List<StepDefinition> steps() => system.steps();

  /// Opções disponíveis para um passo dado o estado atual da ficha.
  List<CatalogOption> optionsFor(StepId step, Sheet sheet) =>
      system.listOptions(step, sheet);

  /// Avalia se uma escolha é legal. Deve ser chamado antes de [applyChoice].
  ValidationResult validate(Choice choice, Sheet sheet) =>
      system.validate(choice, sheet);

  /// Aplica uma escolha válida à ficha, retornando uma nova ficha imutável.
  /// Não valida — responsabilidade do chamador invocar [validate] antes.
  Sheet applyChoice(Choice choice, Sheet sheet) =>
      sheet.copyWith(choices: [...sheet.choices, choice]);

  /// Passos raiz ainda não respondidos.
  /// Slots filhos destravados por unlocks recursivos (PF2e) são resolvidos em M7.
  List<StepId> pendingSteps(Sheet sheet) {
    final filled = {for (final c in sheet.choices) c.step};
    return system.steps()
        .map((s) => s.id)
        .where((id) => !filled.contains(id))
        .toList();
  }

  /// Retorna true quando todos os passos raiz estão preenchidos.
  bool isComplete(Sheet sheet) => pendingSteps(sheet).isEmpty;

  /// Calcula os valores derivados a partir da árvore inteira de escolhas.
  DerivedValues derive(Sheet sheet) => system.derive(sheet);

  /// Slots filhos destravados por uma opção ao ser escolhida.
  List<Slot> unlockedSlotsFor(CatalogOption option) => option.unlocks;
}
