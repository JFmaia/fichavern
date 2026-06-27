import 'step_id.dart';

final class SlotSource {
  final String type;
  final StepId step;
  final String? belongsTo;

  const SlotSource({
    required this.type,
    required this.step,
    this.belongsTo,
  });
}

final class Slot {
  final StepId step;
  final String label;
  final SlotSource source;
  final bool required;
  final int cardinality;

  const Slot({
    required this.step,
    required this.label,
    required this.source,
    required this.required,
    required this.cardinality,
  });
}
