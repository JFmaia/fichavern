import 'package:fichavern/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'sheet_creation_state.dart';

class CreateSheetScreen extends ConsumerWidget {
  const CreateSheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sheetCreationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(state.step)),
        leading: state.step == CreationStep.name
            ? const CloseButton()
            : BackButton(
                onPressed: () =>
                    ref.read(sheetCreationProvider.notifier).previousStep(),
              ),
        automaticallyImplyLeading: false,
      ),
      body: _StepBody(state: state),
    );
  }

  String _stepTitle(CreationStep step) => switch (step) {
        CreationStep.name => 'Nome do personagem',
        CreationStep.rollAbilities => 'Atributos',
        CreationStep.race => 'Raça',
        CreationStep.classChoice => 'Classe',
        CreationStep.summary => 'Resumo',
      };
}

// ---------------------------------------------------------------------------
// Corpo do passo atual
// ---------------------------------------------------------------------------

class _StepBody extends ConsumerWidget {
  const _StepBody({required this.state});
  final SheetCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.step) {
      CreationStep.name => _NameStep(state: state),
      CreationStep.rollAbilities => _RollAbilitiesStep(state: state),
      CreationStep.race => _ChoiceStep(state: state, stepId: 'race'),
      CreationStep.classChoice => _ChoiceStep(state: state, stepId: 'class'),
      CreationStep.summary => _SummaryStep(state: state),
    };
  }
}

// ---------------------------------------------------------------------------
// Passo 1 — Nome
// ---------------------------------------------------------------------------

class _NameStep extends ConsumerStatefulWidget {
  const _NameStep({required this.state});
  final SheetCreationState state;

  @override
  ConsumerState<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<_NameStep> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.characterName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sheetCreationProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onChanged: ref.read(sheetCreationProvider.notifier).setName,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(state.errorMessage!),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () =>
                ref.read(sheetCreationProvider.notifier).nextStep(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Passo 2 — Rolar e atribuir atributos
// ---------------------------------------------------------------------------

const _abilities = [
  ('strength', 'Força'),
  ('dexterity', 'Destreza'),
  ('constitution', 'Constituição'),
  ('intelligence', 'Inteligência'),
  ('wisdom', 'Sabedoria'),
  ('charisma', 'Carisma'),
];

class _RollAbilitiesStep extends ConsumerWidget {
  const _RollAbilitiesStep({required this.state});
  final SheetCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sheetCreationProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.rolledValues.isEmpty)
            const Text(
              'Clique em "Rolar" para gerar 6 valores (4d6, descarta o menor).',
            )
          else ...[
            Text(
              'Valores rolados: ${state.rolledValues.join(', ')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Atribuídos: ${state.assignments.values.whereType<int>().length} / 6',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...List.generate(_abilities.length, (i) {
              final (key, label) = _abilities[i];
              final current = state.assignments[key];
              // Valores disponíveis: todos os rolados ainda não usados por outro atributo,
              // mais o valor já atribuído a este atributo (para manter no dropdown).
              final used = state.assignments.entries
                  .where((e) => e.key != key && e.value != null)
                  .map((e) => e.value!)
                  .toSet();
              final available = state.rolledValues
                  .where((v) => !used.contains(v))
                  .toSet()
                  .toList()
                ..sort((a, b) => b.compareTo(a));

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(label),
                    ),
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          isDense: true,
                        ),
                        child: DropdownButton<int>(
                          value: current,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          hint: const Text('—'),
                          items: [
                            ...available.map(
                              (v) => DropdownMenuItem(
                                  value: v, child: Text('$v')),
                            ),
                            if (current != null &&
                                !available.contains(current))
                              DropdownMenuItem(
                                  value: current, child: Text('$current')),
                          ],
                          onChanged: (v) => notifier.assign(key, v),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(state.errorMessage!),
          ],
          const Spacer(),
          OutlinedButton(
            onPressed: notifier.rollAbilities,
            child: Text(state.rolledValues.isEmpty ? 'Rolar' : 'Rolar novamente'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: state.rolledValues.isEmpty
                ? null
                : () => notifier.nextStep(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Passo 3 & 4 — Seleção de raça / classe
// ---------------------------------------------------------------------------

class _ChoiceStep extends ConsumerWidget {
  const _ChoiceStep({required this.state, required this.stepId});
  final SheetCreationState state;
  final String stepId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.read(engineProvider);
    final partial = Sheet(
      id: '',
      systemId: 'dnd5e',
      level: 1,
      character: Character(
        name: state.characterName,
        story: '',
        characteristics: '',
        traits: [],
      ),
      choices: state.choices,
      baseAbilities: state.finalAbilities,
    );
    final options = engine.optionsFor(stepId, partial);
    final selectedId = state.choices
        .where((c) => c.step == stepId)
        .map((c) => c.optionId)
        .firstOrNull;
    final notifier = ref.read(sheetCreationProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final opt = options[index];
                final selected = opt.id == selectedId;
                return Card(
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(opt.name),
                    subtitle: (opt.description?.isNotEmpty ?? false)
                        ? Text(opt.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: selected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => notifier.makeChoice(opt, stepId),
                  ),
                );
              },
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            _ErrorText(state.errorMessage!),
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => notifier.nextStep(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Passo 5 — Resumo + salvar
// ---------------------------------------------------------------------------

class _SummaryStep extends ConsumerWidget {
  const _SummaryStep({required this.state});
  final SheetCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.read(engineProvider);
    final sheet = ref.read(sheetCreationProvider.notifier).buildFinalSheet();
    final derived = engine.derive(sheet);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.characterName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(height: 24),
          _StatRow('PV', '${derived.hitPoints}'),
          _StatRow('CA', '${derived.armorClass}'),
          _StatRow('Deslocamento', '${derived.speed} ft'),
          const SizedBox(height: 16),
          Text('Atributos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: derived.abilities.entries.map((e) {
              final mod = derived.modifiers[e.key] ?? 0;
              final sign = mod >= 0 ? '+' : '';
              return _AbilityChip(
                label: _shortAbility(e.key),
                value: e.value,
                modifier: '$sign$mod',
              );
            }).toList(),
          ),
          if (derived.proficiencies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Proficiências', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(derived.proficiencies.map(_shortRef).join(', ')),
          ],
          if (derived.grantedTraits.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Traços', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(derived.grantedTraits.map(_shortRef).join(', ')),
          ],
          const Spacer(),
          FilledButton(
            onPressed: () => _save(context, ref, sheet),
            child: const Text('Salvar ficha'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
      BuildContext context, WidgetRef ref, Sheet sheet) async {
    try {
      await ref.read(createSheetUseCaseProvider).execute(sheet);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  String _shortAbility(String key) => switch (key) {
        'strength' => 'FOR',
        'dexterity' => 'DES',
        'constitution' => 'CON',
        'intelligence' => 'INT',
        'wisdom' => 'SAB',
        'charisma' => 'CAR',
        _ => key.substring(0, 3).toUpperCase(),
      };

  String _shortRef(String ref) {
    final parts = ref.split('.');
    return parts.last.replaceAll('_', ' ');
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      );
}

class _AbilityChip extends StatelessWidget {
  const _AbilityChip({
    required this.label,
    required this.value,
    required this.modifier,
  });
  final String label;
  final int value;
  final String modifier;

  @override
  Widget build(BuildContext context) => Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
            Text('$value',
                style: Theme.of(context).textTheme.titleLarge),
            Text(modifier,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
        textAlign: TextAlign.center,
      );
}
