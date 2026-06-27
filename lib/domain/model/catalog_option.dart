import 'effect.dart';
import 'prerequisite.dart';
import 'slot.dart';
import 'step_id.dart';

final class CatalogOption {
  final String id;
  final String systemId;
  final StepId step;

  /// Presente apenas quando a opção pertence a um pai (ex.: feats de ancestralidade).
  final String? belongsTo;

  final String name;
  final String? description;
  final String summary;
  final String whyItMatters;
  final List<String> tags;

  /// Slots que esta opção destrava ao ser escolhida (lido pelo motor genérico).
  final List<Slot> unlocks;

  /// Condições avaliadas pelo plugin contra o estado atual da ficha.
  final List<Prerequisite> prerequisites;

  /// Contribuições desta opção para os valores derivados (lidos por `derive()`).
  final List<Effect> effects;

  const CatalogOption({
    required this.id,
    required this.systemId,
    required this.step,
    this.belongsTo,
    required this.name,
    this.description,
    required this.summary,
    required this.whyItMatters,
    required this.tags,
    required this.unlocks,
    required this.prerequisites,
    required this.effects,
  });
}
